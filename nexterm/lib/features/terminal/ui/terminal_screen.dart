import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/widgets/function_panel.dart';
import 'package:nexterm/features/terminal/ui/widgets/keyboard_toolbar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_tab_bar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_view.dart';

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

  bool _isFunctionMode = false;

  void _toggleKeyboardMode() {
    setState(() {
      _isFunctionMode = !_isFunctionMode;
    });
    if (_isFunctionMode) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabManager = ref.watch(tabManagerProvider);
    final activeTab = tabManager.activeTab;
    final hasTabs = tabManager.tabs.isNotEmpty;

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
          SizedBox(height: MediaQuery.of(context).padding.top),

          TerminalTabBar(
            onAddTab: () => context.go('/hosts'),
            isFunctionMode: _isFunctionMode,
            onToggleMode: activeTab != null ? _toggleKeyboardMode : null,
            onCustomizeTap: activeTab != null
                ? () => context.push('/terminal/customize-keyboard')
                : null,
          ),

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

          if (activeTab != null) ...[
            if (_isFunctionMode)
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

class _EmptyState extends StatelessWidget {
  final bool isConnecting;

  const _EmptyState({required this.isConnecting});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (isConnecting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l.terminal_connecting, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.terminal,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            l.terminal_noTabs,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            l.terminal_noTabsHint,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
