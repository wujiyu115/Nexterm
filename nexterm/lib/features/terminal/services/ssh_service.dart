import 'dart:async';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

/// Configuration data needed to open an SSH connection.
class SSHConnectionConfig {
  final String host;
  final int port;
  final String username;
  final AuthMethod authMethod;
  final String? password;
  final String? privateKeyPem;
  final String? passphrase;

  /// Ordered list of jump-host configs to tunnel through before reaching this
  /// host.  The first entry is the outermost (directly reachable) jump host;
  /// the last entry is the one that forwards to the final target.
  final List<SSHConnectionConfig> jumpChain;

  const SSHConnectionConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.authMethod,
    this.password,
    this.privateKeyPem,
    this.passphrase,
    this.jumpChain = const [],
  });

  /// Returns a copy of this config with the given fields replaced.
  SSHConnectionConfig copyWith({
    String? host,
    int? port,
    String? username,
    AuthMethod? authMethod,
    String? password,
    String? privateKeyPem,
    String? passphrase,
    List<SSHConnectionConfig>? jumpChain,
  }) {
    return SSHConnectionConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      password: password ?? this.password,
      privateKeyPem: privateKeyPem ?? this.privateKeyPem,
      passphrase: passphrase ?? this.passphrase,
      jumpChain: jumpChain ?? this.jumpChain,
    );
  }
}

/// Holds all runtime state for one active SSH session.
class SSHActiveSession {
  final String sessionId;
  final SSHClient client;
  final SSHSession session;

  /// Intermediate jump-host clients that must be closed when this session ends.
  /// Stored in connection order (first = outermost jump host).
  final List<SSHClient> jumpClients;

  const SSHActiveSession({
    required this.sessionId,
    required this.client,
    required this.session,
    this.jumpClients = const [],
  });

  /// stdout bytes from the remote shell.
  Stream<Uint8List> get stdout => session.stdout;

  /// stderr bytes from the remote shell.
  Stream<Uint8List> get stderr => session.stderr;
}

/// Manages SSH connections on behalf of the terminal feature.
///
/// Actual network connections are only established by [connect]; tests should
/// call [buildConnectionConfig] which does no I/O.
class SSHService {
  /// Active sessions keyed by their session ID.
  final Map<String, SSHActiveSession> _sessions = {};

  /// Build a [SSHConnectionConfig] from domain entities — pure, no I/O.
  SSHConnectionConfig buildConnectionConfig(
    HostEntity host, {
    SSHKeyEntity? sshKey,
    List<SSHConnectionConfig> jumpChain = const [],
  }) {
    return SSHConnectionConfig(
      host: host.hostname,
      port: host.port,
      username: host.username,
      authMethod: host.authMethod,
      password: host.authMethod == AuthMethod.password ? host.password : null,
      privateKeyPem:
          host.authMethod == AuthMethod.key ? sshKey?.privateKey : null,
      passphrase:
          host.authMethod == AuthMethod.key ? sshKey?.passphrase : null,
      jumpChain: jumpChain,
    );
  }

  /// Open a connection and interactive shell. Returns the [SSHActiveSession].
  ///
  /// Throws on network or authentication errors.
  ///
  /// If [config.jumpChain] is non-empty the connection is tunnelled through
  /// the listed jump hosts in order before reaching the target.
  Future<SSHActiveSession> connect(
    String sessionId,
    SSHConnectionConfig config,
  ) async {
    final jumpClients = <SSHClient>[];

    final SSHClient targetClient;

    if (config.jumpChain.isEmpty) {
      // Direct connection (no jump hosts).
      final socket = await SSHSocket.connect(
        config.host,
        config.port,
        timeout: const Duration(seconds: 6),
      );
      targetClient = _createClient(socket, config);
    } else {
      // -----------------------------------------------------------------------
      // Tunnelled connection through one or more jump hosts.
      // -----------------------------------------------------------------------

      // 1. Connect directly to the first (outermost) jump host.
      var currentConfig = config.jumpChain.first;
      var currentSocket = await SSHSocket.connect(
        currentConfig.host,
        currentConfig.port,
        timeout: const Duration(seconds: 6),
      );
      var currentClient = _createClient(currentSocket, currentConfig);
      jumpClients.add(currentClient);

      // 2. Chain through any remaining jump hosts.
      for (var i = 1; i < config.jumpChain.length; i++) {
        currentConfig = config.jumpChain[i];
        final forwarded = await currentClient.forwardLocal(
          currentConfig.host,
          currentConfig.port,
        );
        currentClient = _createClient(forwarded, currentConfig);
        jumpClients.add(currentClient);
      }

      // 3. Reach the final target through the last jump host.
      final forwarded = await currentClient.forwardLocal(
        config.host,
        config.port,
      );
      targetClient = _createClient(forwarded, config);
    }

    // Open an interactive shell on the target host.
    final session = await targetClient.shell(
      pty: const SSHPtyConfig(
        type: 'xterm-256color',
        width: 80,
        height: 24,
      ),
    );

    final active = SSHActiveSession(
      sessionId: sessionId,
      client: targetClient,
      session: session,
      jumpClients: jumpClients,
    );
    _sessions[sessionId] = active;
    return active;
  }

  /// Creates an [SSHClient] on top of [socket] using credentials from [config].
  ///
  /// [socket] can be any [SSHSocket]-compatible object — a raw [SSHSocket] for
  /// direct connections or an [SSHForwardChannel] for tunnelled hops.
  SSHClient _createClient(SSHSocket socket, SSHConnectionConfig config) {
    List<SSHKeyPair>? identities;
    if (config.authMethod == AuthMethod.key && config.privateKeyPem != null) {
      identities = SSHKeyPair.fromPem(config.privateKeyPem!, config.passphrase);
    }

    return SSHClient(
      socket,
      username: config.username,
      identities: identities,
      onPasswordRequest:
          config.authMethod == AuthMethod.password && config.password != null
              ? () => config.password
              : null,
      onUserInfoRequest: config.authMethod == AuthMethod.keyboardInteractive
          ? (request) => List.filled(request.prompts.length, '')
          : null,
      keepAliveInterval: const Duration(seconds: 30),
    );
  }

  /// Disconnect a specific session by ID.
  ///
  /// Closes the target client and then the jump clients in reverse order
  /// (innermost to outermost) so that each underlying tunnel is still alive
  /// when the layer above it is shut down.
  Future<void> disconnect(String sessionId) async {
    final active = _sessions.remove(sessionId);
    if (active == null) return;
    active.session.close();
    active.client.close();
    // Close jump clients from innermost to outermost.
    for (final jumpClient in active.jumpClients.reversed) {
      jumpClient.close();
    }
    await active.client.done.catchError((_) {});
  }

  /// Disconnect all active sessions.
  Future<void> disconnectAll() async {
    final ids = List<String>.from(_sessions.keys);
    for (final id in ids) {
      await disconnect(id);
    }
  }

  /// Resize the PTY for the given session.
  void resizePty(String sessionId, int width, int height) {
    final active = _sessions[sessionId];
    if (active == null) return;
    active.session.resizeTerminal(width, height);
  }

  /// Send raw bytes to the shell stdin.
  void write(String sessionId, String data) {
    final active = _sessions[sessionId];
    if (active == null) return;
    active.session.write(Uint8List.fromList(data.codeUnits));
  }

  /// Send a raw [Uint8List] directly to the shell stdin.
  ///
  /// Use this for control characters, ANSI escape sequences, and other data
  /// that must not go through String encoding (e.g. from the keyboard toolbar).
  void writeBytes(String sessionId, Uint8List data) {
    final active = _sessions[sessionId];
    if (active == null) return;
    active.session.write(data);
  }

  /// Returns the stdout stream for a session, or null if unknown.
  Stream<Uint8List>? stdout(String sessionId) => _sessions[sessionId]?.stdout;

  /// Returns the stderr stream for a session, or null if unknown.
  Stream<Uint8List>? stderr(String sessionId) => _sessions[sessionId]?.stderr;

  /// Returns true if the session ID is currently active.
  bool isActive(String sessionId) => _sessions.containsKey(sessionId);

  /// The set of currently active session IDs.
  Set<String> get activeSessionIds => Set.unmodifiable(_sessions.keys);

  /// Returns the [SSHClient] for [sessionId], or null if not found.
  SSHClient? getClient(String sessionId) => _sessions[sessionId]?.client;
}
