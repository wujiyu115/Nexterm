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

  const SSHConnectionConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.authMethod,
    this.password,
    this.privateKeyPem,
    this.passphrase,
  });
}

/// Holds all runtime state for one active SSH session.
class SSHActiveSession {
  final String sessionId;
  final SSHClient client;
  final SSHSession session;

  const SSHActiveSession({
    required this.sessionId,
    required this.client,
    required this.session,
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
    );
  }

  /// Open a connection and interactive shell. Returns the [SSHActiveSession].
  ///
  /// Throws on network or authentication errors.
  Future<SSHActiveSession> connect(
    String sessionId,
    SSHConnectionConfig config,
  ) async {
    final socket = await SSHSocket.connect(
      config.host,
      config.port,
      timeout: const Duration(seconds: 30),
    );

    List<SSHKeyPair>? identities;
    if (config.authMethod == AuthMethod.key &&
        config.privateKeyPem != null) {
      identities = SSHKeyPair.fromPem(
        config.privateKeyPem!,
        config.passphrase,
      );
    }

    final client = SSHClient(
      socket,
      username: config.username,
      identities: identities,
      onPasswordRequest: config.authMethod == AuthMethod.password &&
              config.password != null
          ? () => config.password
          : null,
      onUserInfoRequest: config.authMethod == AuthMethod.keyboardInteractive
          ? (request) => List.filled(request.prompts.length, '')
          : null,
      keepAliveInterval: const Duration(seconds: 30),
    );

    final session = await client.shell(
      pty: const SSHPtyConfig(
        type: 'xterm-256color',
        width: 80,
        height: 24,
      ),
    );

    final active = SSHActiveSession(
      sessionId: sessionId,
      client: client,
      session: session,
    );
    _sessions[sessionId] = active;
    return active;
  }

  /// Disconnect a specific session by ID.
  Future<void> disconnect(String sessionId) async {
    final active = _sessions.remove(sessionId);
    if (active == null) return;
    active.session.close();
    active.client.close();
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

  /// Returns the stdout stream for a session, or null if unknown.
  Stream<Uint8List>? stdout(String sessionId) => _sessions[sessionId]?.stdout;

  /// Returns the stderr stream for a session, or null if unknown.
  Stream<Uint8List>? stderr(String sessionId) => _sessions[sessionId]?.stderr;

  /// Returns true if the session ID is currently active.
  bool isActive(String sessionId) => _sessions.containsKey(sessionId);

  /// The set of currently active session IDs.
  Set<String> get activeSessionIds => Set.unmodifiable(_sessions.keys);
}
