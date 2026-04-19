import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/features/terminal/services/ssh_service.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:xterm/xterm.dart';

// ---------------------------------------------------------------------------
// Core providers
// ---------------------------------------------------------------------------

/// Singleton SSHService shared across the app lifetime.
final sshServiceProvider = Provider<SSHService>((ref) {
  final service = SSHService();
  ref.onDispose(() => service.disconnectAll());
  return service;
});

/// ChangeNotifierProvider for the tab manager.
final tabManagerProvider = ChangeNotifierProvider<TabManager>((ref) {
  return TabManager();
});

/// Map of terminal instances keyed by tab ID.
final terminalControllersProvider =
    StateProvider<Map<String, Terminal>>((ref) => {});

// ---------------------------------------------------------------------------
// TerminalActions
// ---------------------------------------------------------------------------

/// Encapsulates async operations that affect SSH sessions and tabs together.
class TerminalActions {
  TerminalActions(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  SSHService get _sshService => _ref.read(sshServiceProvider);
  TabManager get _tabManager => _ref.read(tabManagerProvider);

  /// Opens a new tab for [hostId] and starts the SSH connection.
  ///
  /// Looks up the host (and key if needed) from providers.
  Future<void> connectHost(String hostId) async {
    // Look up host entity.
    final hostAsync = await _ref.read(hostByIdProvider(hostId).future);
    if (hostAsync == null) {
      debugPrint('TerminalActions.connectHost: host $hostId not found');
      return;
    }
    final host = hostAsync;

    // Create tab.
    final tab = _tabManager.addTab(hostId: hostId, title: host.name);
    _tabManager.updateTabStatus(tab.id, ConnectionStatus.connecting);

    // Create a Terminal instance for this tab.
    final terminal = Terminal(maxLines: 10000);
    _ref.read(terminalControllersProvider.notifier).update(
          (state) => Map.unmodifiable({...state, tab.id: terminal}),
        );

    // Build connection config — look up key if needed.
    final config = await _buildConfig(host);

    // Generate a session ID.
    final sessionId = _uuid.v4();

    try {
      final active = await _sshService.connect(sessionId, config);
      _tabManager.updateTabStatus(tab.id, ConnectionStatus.connected);
      _tabManager.updateTabSessionId(tab.id, sessionId);

      // Wire stdout to terminal input.
      active.stdout.listen(
        (data) => terminal.write(utf8.decode(data, allowMalformed: true)),
        onDone: () {
          _tabManager.updateTabStatus(tab.id, ConnectionStatus.disconnected);
        },
        onError: (_) {
          _tabManager.updateTabStatus(tab.id, ConnectionStatus.error);
        },
      );

      // Terminal output goes to SSH stdin.
      terminal.onOutput = (data) => _sshService.write(sessionId, data);

      // PTY resize.
      terminal.onResize = (w, h, pw, ph) =>
          _sshService.resizePty(sessionId, w, h);
    } catch (e, st) {
      debugPrint('TerminalActions.connectHost error: $e\n$st');
      _tabManager.updateTabStatus(tab.id, ConnectionStatus.error);
    }
  }

  /// Disconnects the SSH session for [tabId] and removes the tab.
  Future<void> disconnectTab(String tabId) async {
    final tab = _tabManager.tabs.firstWhere(
      (t) => t.id == tabId,
      orElse: () => throw StateError('Tab $tabId not found'),
    );

    if (tab.sessionId != null) {
      await _sshService.disconnect(tab.sessionId!);
    }

    _tabManager.updateTabStatus(tabId, ConnectionStatus.disconnected);
    _tabManager.removeTab(tabId);

    // Remove the Terminal instance.
    _ref.read(terminalControllersProvider.notifier).update(
          (state) => Map.unmodifiable(
            Map.fromEntries(state.entries.where((e) => e.key != tabId)),
          ),
        );
  }

  Future<SSHConnectionConfig> _buildConfig(
    dynamic host, // HostEntity
  ) async {
    final sshService = _sshService;
    dynamic sshKey;

    if (host.authMethod == AuthMethod.key && host.keyId != null) {
      final keys = await _ref.read(keysStreamProvider.future);
      try {
        sshKey = keys.firstWhere((k) => k.id == host.keyId);
      } catch (_) {
        // Key not found; will fail at auth.
      }
    }

    return sshService.buildConnectionConfig(host, sshKey: sshKey);
  }
}

/// Provider for [TerminalActions].
final terminalActionsProvider = Provider<TerminalActions>((ref) {
  return TerminalActions(ref);
});
