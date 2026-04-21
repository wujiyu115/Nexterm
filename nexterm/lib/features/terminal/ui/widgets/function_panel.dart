import 'package:flutter/material.dart';
import 'package:nexterm/features/terminal/ui/widgets/command_history_panel.dart';

/// The function-key mode panel displayed when the system keyboard is hidden.
///
/// Contains a bottom [TabBar] with four tabs:
///   1. **代码** `{}` — Code snippets (placeholder)
///   2. **历史** `⏱` — Command history
///   3. **帮助** `?` — Quick-reference help
///   4. **键盘** `⌨` — Switch back to ABC (system keyboard) mode
class FunctionPanel extends StatefulWidget {
  final String? sessionId;

  /// Called when the user taps a command from the history panel.
  final void Function(String command) onCommandSelected;

  /// Called when the user taps the "键盘" tab to switch back to ABC mode.
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
      // If the user taps the "键盘" tab (index 3), switch to ABC mode.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F5);

    return Container(
      height: 260,
      color: bgColor,
      child: Column(
        children: [
          // Tab bar at the top of the panel.
          Container(
            color: isDark ? const Color(0xFF181825) : const Color(0xFFE0E0EA),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.white : Colors.black87,
              unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Text('{}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), text: '代码'),
                Tab(icon: Icon(Icons.history, size: 18), text: '历史'),
                Tab(icon: Icon(Icons.help_outline, size: 18), text: '帮助'),
                Tab(icon: Icon(Icons.keyboard, size: 18), text: '键盘'),
              ],
            ),
          ),
          // Tab content.
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
                    : _EmptyTab(message: '无活动会话'),
                _HelpTab(),
                // The keyboard tab triggers onSwitchToAbc via the listener,
                // so we just show a brief message here.
                _EmptyTab(message: '切换到系统键盘…'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab content widgets
// ---------------------------------------------------------------------------

class _SnippetsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.code, size: 40, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 8),
          Text(
            '代码片段（即将推出）',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final dimColor = isDark ? Colors.white38 : Colors.black45;

    final shortcuts = [
      ('Ctrl+C', '中断当前进程'),
      ('Ctrl+D', '发送 EOF / 退出'),
      ('Ctrl+Z', '挂起当前进程'),
      ('Ctrl+L', '清屏'),
      ('Ctrl+R', '反向搜索历史'),
      ('Ctrl+A', '光标移到行首'),
      ('Ctrl+E', '光标移到行尾'),
      ('Tab', '自动补全'),
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
