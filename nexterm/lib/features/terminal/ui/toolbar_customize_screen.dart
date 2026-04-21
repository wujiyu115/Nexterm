import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/models/toolbar_key_definition.dart';
import 'package:nexterm/features/terminal/providers/toolbar_config_provider.dart';

/// Screen for customising the keyboard toolbar layout.
///
/// Shows a live preview of the toolbar at the top, followed by a reorderable
/// list of key groups. Each group can be removed, and removed groups can be
/// re-added via the "+" button. A "Restore Defaults" option is available in
/// the overflow menu.
class ToolbarCustomizeScreen extends ConsumerWidget {
  const ToolbarCustomizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(toolbarConfigProvider);
    final notifier = ref.read(toolbarConfigProvider.notifier);
    final removedGroups = notifier.removedGroups;
    final visibleCount = ref.watch(visibleGroupCountProvider);
    final visibleCountNotifier = ref.read(visibleGroupCountProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义键盘'),
        actions: [
          if (removedGroups.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '添加按键组',
              onPressed: () => _showAddGroupSheet(context, notifier, removedGroups),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'restore') {
                _confirmRestore(context, notifier, visibleCountNotifier);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'restore',
                child: Text('恢复默认'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Live preview bar.
          _ToolbarPreview(groups: groups, visibleCount: visibleCount),
          const Divider(height: 1),
          // Visible group count setting.
          _VisibleCountSetting(
            value: visibleCount,
            max: groups.length,
            onChanged: (v) => visibleCountNotifier.setCount(v),
          ),
          const Divider(height: 1),
          // Reorderable group list.
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: groups.length,
              onReorder: (oldIndex, newIndex) {
                notifier.reorderGroup(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final group = groups[index];
                final isVisible = index < visibleCount;
                return _GroupTile(
                  key: ValueKey(group.id),
                  group: group,
                  index: index,
                  isVisible: isVisible,
                  onRemove: () => notifier.removeGroup(group.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGroupSheet(
    BuildContext context,
    ToolbarConfigNotifier notifier,
    List<ToolbarKeyGroup> removedGroups,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('添加按键组'),
        actions: removedGroups
            .map((g) => CupertinoActionSheetAction(
                  onPressed: () {
                    notifier.addGroup(g.id);
                    Navigator.pop(ctx);
                  },
                  child: Text('${g.name}  (${g.keys.map((k) => k.label).join(", ")})'),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _confirmRestore(
    BuildContext context,
    ToolbarConfigNotifier notifier,
    VisibleGroupCountNotifier visibleCountNotifier,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('恢复默认'),
        content: const Text('确定要恢复默认的键盘布局吗？自定义的排序和显示组数将被重置。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              notifier.restoreDefaults();
              visibleCountNotifier.setCount(defaultVisibleGroupCount);
              Navigator.pop(ctx);
            },
            child: const Text('恢复'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Visible group count setting
// ---------------------------------------------------------------------------

class _VisibleCountSetting extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _VisibleCountSetting({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '显示组数',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '工具栏最多显示 $value 组快捷键',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 22),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            onPressed: value < max ? () => onChanged(value + 1) : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live preview
// ---------------------------------------------------------------------------

class _ToolbarPreview extends StatelessWidget {
  final List<ToolbarKeyGroup> groups;
  final int visibleCount;
  const _ToolbarPreview({required this.groups, required this.visibleCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE8E8F0);
    final btnColor = isDark ? const Color(0xFF313244) : const Color(0xFFD0D0E0);
    final txtColor = isDark ? const Color(0xFFCDD6F4) : const Color(0xFF1C1C2E);
    final divColor = isDark ? Colors.white12 : Colors.black12;

    final visible = groups.take(visibleCount).toList();

    return Container(
      height: 44,
      color: bg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            for (int i = 0; i < visible.length; i++) ...[
              for (final key in visible[i].keys)
                Container(
                  constraints: const BoxConstraints(minWidth: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    key.label,
                    style: TextStyle(color: txtColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              if (i < visible.length - 1)
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  color: divColor,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group tile
// ---------------------------------------------------------------------------

class _GroupTile extends StatelessWidget {
  final ToolbarKeyGroup group;
  final int index;
  final bool isVisible;
  final VoidCallback onRemove;

  const _GroupTile({
    super.key,
    required this.group,
    required this.index,
    required this.isVisible,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keysPreview = group.keys.map((k) => k.label).join('  ');

    return Opacity(
      opacity: isVisible ? 1.0 : 0.45,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              // Remove button.
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 22),
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
              ),
              // Group info.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          group.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (!isVisible) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(隐藏)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      keysPreview,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Drag handle.
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.drag_handle, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
