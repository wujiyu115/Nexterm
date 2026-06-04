import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';

/// Holds runtime state for one active port forward.
class ActiveForward {
  final PortForwardEntity entity;
  final ServerSocket? serverSocket;
  final SSHRemoteForward? remoteForward;
  final List<StreamSubscription> subscriptions;

  ActiveForward({
    required this.entity,
    this.serverSocket,
    this.remoteForward,
    List<StreamSubscription>? subscriptions,
  }) : subscriptions = subscriptions ?? [];
}

/// Manages local, remote, and dynamic SSH port forwards.
///
/// [startLocalForward] and [startDynamicForward] bind a local [ServerSocket]
/// and tunnel each accepted connection through an SSH channel.
/// [startRemoteForward] instructs the SSH server to open a remote listener.
///
/// This service uses `dart:io` and therefore only works on native platforms
/// (mobile / desktop) — not on the web.
class PortForwardService extends ChangeNotifier {
  final Map<String, ActiveForward> _active = {};

  /// Returns the live status of a forward rule.
  ForwardStatus getStatus(String forwardId) {
    return _active.containsKey(forwardId)
        ? ForwardStatus.active
        : ForwardStatus.inactive;
  }

  /// Returns true if the given forward ID is currently active.
  bool isActive(String forwardId) => _active.containsKey(forwardId);

  /// Returns all currently active forward IDs.
  Set<String> get activeForwardIds => Set.unmodifiable(_active.keys);

  /// Returns the forward ID if a local port is already being forwarded, or null.
  String? findByLocalPort(int port) {
    for (final entry in _active.entries) {
      if (entry.value.entity.localPort == port) return entry.key;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Local forward: local port → SSH server → remote host:port
  // ---------------------------------------------------------------------------

  /// Binds a local [ServerSocket] and tunnels each connection through SSH.
  ///
  /// Each accepted TCP connection on `entity.localPort` is forwarded through
  /// [client] to `entity.remoteHost:entity.remotePort` on the remote side.
  Future<void> startLocalForward({
    required SSHClient client,
    required PortForwardEntity entity,
  }) async {
    if (_active.containsKey(entity.id)) return;

    final remoteHost = entity.remoteHost ?? 'localhost';
    final remotePort = entity.remotePort ?? entity.localPort;

    final server = await ServerSocket.bind(
      entity.bindAddress,
      entity.localPort,
    );

    final active = ActiveForward(entity: entity, serverSocket: server);
    _active[entity.id] = active;
    notifyListeners();

    final sub = server.listen(
      (socket) async {
        try {
          final channel = await client.forwardLocal(remoteHost, remotePort);
          socket.cast<List<int>>().pipe(channel.sink);
          channel.stream.cast<List<int>>().pipe(socket);
        } catch (_) {
          await socket.close();
        }
      },
      onError: (_) => _cleanupLocal(entity.id),
      onDone: () { _active.remove(entity.id); notifyListeners(); },
    );

    active.subscriptions.add(sub);
  }

  // ---------------------------------------------------------------------------
  // Remote forward: remote port → SSH client → local host:port
  // ---------------------------------------------------------------------------

  /// Registers a remote port forward on the SSH server.
  ///
  /// Connections arriving at the remote port are forwarded back to
  /// `entity.bindAddress:entity.localPort` on the local machine.
  Future<void> startRemoteForward({
    required SSHClient client,
    required PortForwardEntity entity,
  }) async {
    if (_active.containsKey(entity.id)) return;

    final remotePort = entity.remotePort ?? entity.localPort;
    final localPort = entity.localPort;
    final localHost = entity.bindAddress;

    final forward = await client.forwardRemote(port: remotePort);
    if (forward == null) {
      throw StateError('Remote port forward refused by server for port $remotePort');
    }

    final active = ActiveForward(entity: entity, remoteForward: forward);
    _active[entity.id] = active;
    notifyListeners();

    final sub = forward.connections.listen(
      (connection) async {
        try {
          final socket = await Socket.connect(localHost, localPort);
          connection.stream.cast<List<int>>().pipe(socket);
          socket.cast<List<int>>().pipe(connection.sink);
        } catch (_) {}
      },
      onDone: () { _active.remove(entity.id); notifyListeners(); },
    );

    active.subscriptions.add(sub);
  }

  // ---------------------------------------------------------------------------
  // Dynamic forward (SOCKS5 placeholder): local SOCKS5 port → SSH
  // ---------------------------------------------------------------------------

  /// Binds a local SOCKS5 proxy on `entity.localPort`.
  ///
  /// Full SOCKS5 negotiation is a placeholder — each accepted connection is
  /// closed immediately until a complete SOCKS5 implementation is added.
  /// The socket is bound so that the forward shows as [ForwardStatus.active].
  Future<void> startDynamicForward({
    required SSHClient client,
    required PortForwardEntity entity,
  }) async {
    if (_active.containsKey(entity.id)) return;

    final server = await ServerSocket.bind(
      entity.bindAddress,
      entity.localPort,
    );

    final active = ActiveForward(entity: entity, serverSocket: server);
    _active[entity.id] = active;
    notifyListeners();

    final sub = server.listen(
      (socket) async {
        // TODO: implement full SOCKS5 negotiation and SSH channel opening.
        await socket.close();
      },
      onError: (_) { _cleanupLocal(entity.id); notifyListeners(); },
      onDone: () { _active.remove(entity.id); notifyListeners(); },
    );

    active.subscriptions.add(sub);
  }

  // ---------------------------------------------------------------------------
  // Stop
  // ---------------------------------------------------------------------------

  /// Stops a specific active forward.
  Future<void> stop(String forwardId) async {
    final active = _active.remove(forwardId);
    if (active == null) return;
    await _teardown(active);
    notifyListeners();
  }

  /// Stops all active forwards.
  Future<void> stopAll() async {
    final ids = List<String>.from(_active.keys);
    for (final id in ids) {
      final active = _active.remove(id);
      if (active != null) await _teardown(active);
    }
    notifyListeners();
  }

  /// Returns a snapshot of all currently active forwards.
  List<ActiveForward> get activeForwards => List.unmodifiable(_active.values);

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Future<void> _teardown(ActiveForward active) async {
    for (final sub in active.subscriptions) {
      await sub.cancel();
    }
    await active.serverSocket?.close();
  }

  void _cleanupLocal(String forwardId) {
    _active.remove(forwardId);
  }
}
