import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/widgets/function_panel.dart';
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
  bool _hadTabs = false;

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

  /// Current keyboard mode: `abc` shows system keyboard + toolbar,
  /// `function` hides system keyboard and shows the function panel.
  bool _isFunctionMode = false;

  void _toggleKeyboardMode() {
    setState(() {
      _isFunctionMode = !_isFunctionMode;
    });
    // If switching to function mode, dismiss the system keyboard.
    if (_isFunctionMode) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabManager = ref.watch(tabManagerProvider);
    final activeTab = tabManager.activeTab;
    final hasTabs = tabManager.tabs.isNotEmpty;

    // Navigate back to hosts when all tabs have been closed.
    if (_hadTabs && !hasTabs) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) {
          context.pop();
        } else if (mounted) {
          context.go('/hosts');
        }
      });
    }
    _hadTabs = hasTabs;

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
                : TerminalViewWidget(
                    tab: activeTab,
                    hardwareKeyboardOnly: _isFunctionMode,
                  ),
          ),

          // Bottom area — depends on keyboard mode.
          if (activeTab != null) ...[
            // ABC/Function mode toggle button.
            _ModeToggleBar(
              isFunctionMode: _isFunctionMode,
              onToggle: _toggleKeyboardMode,
              onCustomizeTap: () => context.push('/terminal/customize-keyboard'),
            ),

            if (_isFunctionMode)
              // Function panel (replaces system keyboard).
              FunctionPanel(
                sessionId: activeTab.sessionId,
                onCommandSelected: (command) {
                  final sshService = ref.read(sshServiceProvider);
                  if (activeTab.sessionId != null) {
                    sshService.write(activeTab.sessionId!, '$command\n');
                  }
                },
                onSwitchToAbc: () {
                  setState(() => _isFunctionMode = false);
                },
              )
            else
              // Keyboard toolbar (ABC mode).
              KeyboardToolbar(
                onKeyInput: (data) {
                  final sshService = ref.read(sshServiceProvider);
                  if (activeTab.sessionId != null) {
                    sshService.writeBytes(activeTab.sessionId!, data);
                  }
                },
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mode toggle bar
// ---------------------------------------------------------------------------

class _ModeToggleBar extends StatelessWidget {
  final bool isFunctionMode;
  final VoidCallback onToggle;
  final VoidCallback? onCustomizeTap;

  const _ModeToggleBar({
    required this.isFunctionMode,
    required this.onToggle,
    this.onCustomizeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181825) : const Color(0xFFDDDDE5);
    final textColor = isDark ? Colors.white70 : Colors.black54;
    final activeColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: 32,
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onToggle();
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFunctionMode ? Icons.keyboard : Icons.grid_view_rounded,
                    size: 16,
                    color: activeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFunctionMode ? '切换到 ABC 键盘' : '切换到功能面板',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onCustomizeTap != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onCustomizeTap!();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.settings,
                  size: 16,
                  color: activeColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

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
