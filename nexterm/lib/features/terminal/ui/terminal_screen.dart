import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/snippets/ui/snippet_execute_sheet.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/widgets/keyboard_toolbar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_tab_bar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_view.dart';

/// Full terminal screen with tab bar at top and the active terminal below.
///
/// If [hostId] is provided (e.g., navigated via `/terminal/connect/:hostId`),
/// the screen automatically opens a connection to that host on first build.
class TerminalScreen extends ConsumerStatefulWidget {
  final String? hostId;

  const TerminalScreen({super.key, this.hostId});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  bool _didAutoConnect = false;

  @override
  void initState() {
    super.initState();
    // Schedule auto-connect after first frame so providers are ready.
    if (widget.hostId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoConnect();
      });
    }
  }

  Future<void> _autoConnect() async {
    if (_didAutoConnect) return;
    _didAutoConnect = true;
    await ref
        .read(terminalActionsProvider)
        .connectHost(widget.hostId!);
  }

  void _showSnippetSheet(String sessionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SnippetExecuteSheet(
        onExecute: (command) {
          final sshService = ref.read(sshServiceProvider);
          sshService.write(sessionId, command);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabManager = ref.watch(tabManagerProvider);
    final activeTab = tabManager.activeTab;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Reserve space for the system status bar.
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Tab bar at top.
          TerminalTabBar(
            onAddTab: () {
              // In a full app this would show a host picker dialog.
              // For now it is a no-op placeholder.
            },
          ),

          // Terminal area.
          Expanded(
            child: activeTab == null
                ? _EmptyState(
                    isConnecting: widget.hostId != null && !_didAutoConnect,
                  )
                : TerminalViewWidget(tab: activeTab),
          ),

          // Keyboard toolbar — only shown when a terminal tab is active.
          if (activeTab != null)
            KeyboardToolbar(
              onKeyInput: (data) {
                final sshService = ref.read(sshServiceProvider);
                if (activeTab.sessionId != null) {
                  sshService.writeBytes(activeTab.sessionId!, data);
                }
              },
              onSnippetsTap: activeTab.sessionId != null
                  ? () => _showSnippetSheet(activeTab.sessionId!)
                  : null,
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isConnecting;

  const _EmptyState({required this.isConnecting});

  @override
  Widget build(BuildContext context) {
    if (isConnecting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在连接…', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.terminal,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            '没有打开的终端',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '从主机列表中选择一台主机以开始连接',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
