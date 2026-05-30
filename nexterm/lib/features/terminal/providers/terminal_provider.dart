import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/forwarding/providers/forwarding_provider.dart';
import 'package:nexterm/features/forwarding/services/port_forward_service.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';
import 'package:nexterm/features/snippets/utils/variable_parser.dart';
import 'package:nexterm/features/terminal/providers/command_history_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_scrollback_provider.dart';
import 'package:nexterm/features/terminal/providers/toolbar_modifier_provider.dart';
import 'package:nexterm/features/terminal/services/reconnect_service.dart';
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

/// Singleton PortForwardService shared across the app lifetime.
final portForwardServiceProvider = Provider<PortForwardService>((ref) {
  final service = PortForwardService();
  ref.onDispose(() => service.stopAll());
  return service;
});

/// Singleton ReconnectService shared across the app lifetime.
final reconnectServiceProvider = Provider<ReconnectService>((ref) {
  final service = ReconnectService();
  ref.onDispose(() => service.cancelAll());
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
  PortForwardService get _portForwardService => _ref.read(portForwardServiceProvider);
  ReconnectService get _reconnectService => _ref.read(reconnectServiceProvider);

  void _writeWithModifiers(String sessionId, String data) {
    final modifier = _ref.read(toolbarModifierProvider);
    if (modifier.isActive && data.length == 1) {
      final code = data.codeUnitAt(0);
      if (modifier.ctrl) {
        if (code >= 0x61 && code <= 0x7A) {
          _sshService.writeBytes(sessionId, Uint8List.fromList([code - 0x60]));
        } else if (code >= 0x41 && code <= 0x5A) {
          _sshService.writeBytes(sessionId, Uint8List.fromList([code - 0x40]));
        } else if (code >= 0x5B && code <= 0x5F) {
          _sshService.writeBytes(sessionId, Uint8List.fromList([code - 0x40]));
        } else {
          _sshService.write(sessionId, data);
        }
      } else if (modifier.alt) {
        _sshService.writeBytes(sessionId, Uint8List.fromList([0x1B, code]));
      }
      _ref.read(toolbarModifierProvider.notifier).reset();
    } else {
      _sshService.write(sessionId, data);
    }
  }

  /// Opens a new tab for [hostId] and starts the SSH connection.
  ///
  /// Looks up the host (and key if needed) from providers.
  /// Returns the SSH session ID on success, or null on failure.
  Future<String?> connectHost(String hostId) async {
    // Look up host entity.
    final hostAsync = await _ref.read(hostByIdProvider(hostId).future);
    if (hostAsync == null) {
      debugPrint('TerminalActions.connectHost: host $hostId not found');
      return null;
    }
    final host = hostAsync;

    // Create tab.
    final tab = _tabManager.addTab(hostId: hostId, title: host.name);
    _tabManager.updateTabStatus(tab.id, ConnectionStatus.connecting);

    // Create a Terminal instance for this tab.
    final scrollback = _ref.read(terminalScrollbackProvider);
    final terminal = Terminal(maxLines: scrollback);
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

      // --- Gap 1: update lastConnected timestamp ---
      _ref.read(hostsNotifierProvider.notifier).updateLastConnected(hostId);

      // Wire terminal output and resize BEFORE listening to stdout, so that
      // any autoResize triggered by TerminalView is forwarded to the remote
      // PTY immediately.
      terminal.onOutput = (data) {
        _writeWithModifiers(sessionId, data);
        _ref.read(commandHistoryServiceProvider).onUserInput(sessionId, data);
      };
      terminal.onResize = (w, h, pw, ph) =>
          _sshService.resizePty(sessionId, w, h);

      // If TerminalView has already resized the Terminal (via autoResize)
      // before we set onResize, the remote PTY still thinks it's 80x24.
      // Sync the actual terminal dimensions to the remote PTY now.
      if (terminal.viewWidth != 80 || terminal.viewHeight != 24) {
        _sshService.resizePty(sessionId, terminal.viewWidth, terminal.viewHeight);
      }

      // Wire stdout to terminal input.
      active.stdout.listen(
        (data) => terminal.write(utf8.decode(data, allowMalformed: true)),
        onDone: () {
          _tabManager.updateTabStatus(tab.id, ConnectionStatus.disconnected);
          // --- Gap 4: schedule reconnect on disconnect ---
          _reconnectService.scheduleReconnect(
            sessionId: sessionId,
            reconnectFn: () async {
              try {
                final newSessionId = _uuid.v4();
                final freshHost =
                    await _ref.read(hostByIdProvider(hostId).future);
                if (freshHost == null) return false;
                final freshConfig = await _buildConfig(freshHost);
                final newActive =
                    await _sshService.connect(newSessionId, freshConfig);
                _tabManager.updateTabSessionId(tab.id, newSessionId);
                _tabManager.updateTabStatus(
                    tab.id, ConnectionStatus.connected);
                // Wire resize and output before stdout to avoid PTY size mismatch.
                terminal.onOutput =
                    (data) => _writeWithModifiers(newSessionId, data);
                terminal.onResize = (w, h, pw, ph) =>
                    _sshService.resizePty(newSessionId, w, h);
                // Sync current terminal size to the new PTY.
                _sshService.resizePty(
                    newSessionId, terminal.viewWidth, terminal.viewHeight);
                // Re-wire stdout.
                newActive.stdout.listen(
                  (data) =>
                      terminal.write(utf8.decode(data, allowMalformed: true)),
                  onDone: () => _tabManager.updateTabStatus(
                      tab.id, ConnectionStatus.disconnected),
                  onError: (_) => _tabManager.updateTabStatus(
                      tab.id, ConnectionStatus.error),
                );
                return true;
              } catch (_) {
                return false;
              }
            },
            onRetrying: (attempt, delay) {
              terminal.write(
                  '\r\n[reconnecting, attempt ${attempt + 1} in ${delay.inSeconds}s…]\r\n');
            },
            onReconnected: () {
              terminal.write('\r\n[reconnected]\r\n');
            },
            onGaveUp: () {
              _tabManager.updateTabStatus(tab.id, ConnectionStatus.error);
              terminal.write('\r\n[connection lost — gave up reconnecting]\r\n');
            },
          );
        },
        onError: (_) {
          _tabManager.updateTabStatus(tab.id, ConnectionStatus.error);
        },
      );

      // --- Gap 2: execute startup command/snippet ---
      final snippetId = host.startupSnippetId;
      final startupCmd = host.startupCommand;

      if (snippetId != null) {
        final snippet =
            await _ref.read(snippetByIdProvider(snippetId).future);
        if (snippet != null) {
          final defaults = {
            for (final v in snippet.variables)
              if (v.defaultValue != null) v.name: v.defaultValue!,
          };
          final substituted =
              VariableParser.substitute(snippet.command, defaults);
          final lines = VariableParser.splitLines(substituted);
          for (final line in lines) {
            _sshService.write(sessionId, '$line\n');
          }
        }
      } else if (startupCmd != null && startupCmd.isNotEmpty) {
        final lines = VariableParser.splitLines(startupCmd);
        for (final line in lines) {
          _sshService.write(sessionId, '$line\n');
        }
      }

      // --- Gap 3: start autoStart port forwards ---
      final portForwardRepo =
          _ref.read(portForwardRepositoryProvider);
      final autoForwards =
          await portForwardRepo.getAutoStartByHostId(hostId);
      for (final forward in autoForwards) {
        final client = _sshService.getClient(sessionId);
        if (client == null) break;
        try {
          switch (forward.type) {
            case ForwardType.local:
              await _portForwardService.startLocalForward(
                  client: client, entity: forward);
            case ForwardType.remote:
              await _portForwardService.startRemoteForward(
                  client: client, entity: forward);
            case ForwardType.dynamic:
              await _portForwardService.startDynamicForward(
                  client: client, entity: forward);
          }
        } catch (e) {
          debugPrint('autoStart forward ${forward.id} failed: $e');
        }
      }
      return sessionId;
    } catch (e, st) {
      debugPrint('TerminalActions.connectHost error: $e\n$st');
      _tabManager.updateTabStatus(tab.id, ConnectionStatus.error);

      // Write a user-friendly error message into the terminal.
      final friendlyMessage = _friendlyErrorMessage(e);
      terminal.write('\r\n\x1B[1;31m连接失败\x1B[0m: $friendlyMessage\r\n');
      terminal.write('\r\n\x1B[90m按关闭按钮关闭此标签页，或从主机列表重新连接。\x1B[0m\r\n');
      return null;
    }
  }

  /// Converts a raw exception into a user-friendly Chinese error message.
  String _friendlyErrorMessage(Object error) {
    final message = error.toString();
    if (error is TimeoutException || message.contains('TimeoutException')) {
      return '连接超时，请检查主机地址和端口是否正确，以及网络是否可达。';
    }
    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      return '无法连接到主机，请确认主机地址、端口是否正确，以及目标主机是否已开启 SSH 服务。';
    }
    if (message.contains('Authentication') ||
        message.contains('auth') ||
        message.contains('password') ||
        message.contains('publickey')) {
      return '认证失败，请检查用户名、密码或 SSH 密钥是否正确。';
    }
    if (message.contains('Host key') || message.contains('host key')) {
      return '主机密钥验证失败，目标主机的密钥可能已变更。';
    }
    if (message.contains('No route') || message.contains('Network is unreachable')) {
      return '网络不可达，请检查设备的网络连接。';
    }
    if (message.contains('DNS') || message.contains('resolve') || message.contains('getaddrinfo')) {
      return '域名解析失败，请检查主机地址是否正确。';
    }
    return '${error.runtimeType}: $message';
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
    // Build configs for each jump host in the chain (preserving order).
    final jumpChain = <SSHConnectionConfig>[];
    for (final jumpId in (host.jumpHosts as List<String>)) {
      final jumpHost = await _ref.read(hostByIdProvider(jumpId).future);
      if (jumpHost == null) {
        debugPrint('_buildConfig: jump host $jumpId not found, skipping');
        continue;
      }
      jumpChain.add(await _buildConfigForHost(jumpHost));
    }

    return _buildConfigForHost(host, jumpChain: jumpChain);
  }

  /// Looks up any required SSH key and returns a [SSHConnectionConfig] for
  /// [host].  Does NOT resolve jump-host chains — call [_buildConfig] for that.
  Future<SSHConnectionConfig> _buildConfigForHost(
    dynamic host, {
    List<SSHConnectionConfig> jumpChain = const [],
  }) async {
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

    return sshService.buildConnectionConfig(
      host,
      sshKey: sshKey,
      jumpChain: jumpChain,
    );
  }
}

/// Provider for [TerminalActions].
final terminalActionsProvider = Provider<TerminalActions>((ref) {
  return TerminalActions(ref);
});
