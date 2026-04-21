import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/features/terminal/ui/widgets/command_history_panel.dart';

class FunctionPanel extends StatefulWidget {
  final String? sessionId;
  final void Function(String command) onCommandSelected;
  final VoidCallback onSwitchToAbc;

  const FunctionPanel({
    super.key,
    required this.sessionId,
    required this.onCommandSelected,
    required this.onSwitchToAbc,
  });

  @override
  State<FunctionPanel> createState() => _FunctionPanelState();
}

class _FunctionPanelState extends State<FunctionPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 3) {
        widget.onSwitchToAbc();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F5);

    return Container(
      height: 260,
      color: bgColor,
      child: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF181825) : const Color(0xFFE0E0EA),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.white : Colors.black87,
              unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                Tab(icon: const Text('{}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), text: l.function_tabCode),
                Tab(icon: const Icon(Icons.history, size: 18), text: l.function_tabHistory),
                Tab(icon: const Icon(Icons.help_outline, size: 18), text: l.function_tabHelp),
                Tab(icon: const Icon(Icons.keyboard, size: 18), text: l.function_tabKeyboard),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SnippetsPlaceholder(),
                widget.sessionId != null
                    ? CommandHistoryPanel(
                        sessionId: widget.sessionId!,
                        onCommandSelected: widget.onCommandSelected,
                      )
                    : _EmptyTab(message: l.function_noActiveSession),
                _HelpTab(),
                _EmptyTab(message: l.function_switchToKeyboard),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SnippetsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.code, size: 40, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 8),
          Text(
            l.function_comingSoon,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final dimColor = isDark ? Colors.white38 : Colors.black45;

    final shortcuts = [
      ('Ctrl+C', l.function_helpCtrlC),
      ('Ctrl+D', l.function_helpCtrlD),
      ('Ctrl+Z', l.function_helpCtrlZ),
      ('Ctrl+L', l.function_helpCtrlL),
      ('Ctrl+R', l.function_helpCtrlR),
      ('Ctrl+A', l.function_helpCtrlA),
      ('Ctrl+E', l.function_helpCtrlE),
      ('Tab', l.function_helpTab),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: shortcuts.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark ? Colors.white10 : Colors.black12,
      ),
      itemBuilder: (context, index) {
        final (key, desc) = shortcuts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  key,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(desc, style: TextStyle(fontSize: 13, color: dimColor)),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String message;
  const _EmptyTab({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 14,
        ),
      ),
    );
  }
}
