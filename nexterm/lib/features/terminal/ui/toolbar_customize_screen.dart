import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/models/toolbar_key_definition.dart';
import 'package:nexterm/features/terminal/providers/toolbar_config_provider.dart';

class ToolbarCustomizeScreen extends ConsumerWidget {
  const ToolbarCustomizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final groups = ref.watch(toolbarConfigProvider);
    final notifier = ref.read(toolbarConfigProvider.notifier);
    final removedGroups = notifier.removedGroups;
    final visibleCount = ref.watch(visibleGroupCountProvider);
    final visibleCountNotifier = ref.read(visibleGroupCountProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.toolbar_customize),
        actions: [
          if (removedGroups.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l.toolbar_addGroupTooltip,
              onPressed: () => _showAddGroupSheet(context, l, notifier, removedGroups),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'restore') {
                _confirmRestore(context, l, notifier, visibleCountNotifier);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'restore',
                child: Text(l.toolbar_restoreDefaults),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _ToolbarPreview(groups: groups, visibleCount: visibleCount),
          const Divider(height: 1),
          _VisibleCountSetting(
            value: visibleCount,
            max: groups.length,
            onChanged: (v) => visibleCountNotifier.setCount(v),
          ),
          const Divider(height: 1),
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
    AppLocalizations l,
    ToolbarConfigNotifier notifier,
    List<ToolbarKeyGroup> removedGroups,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l.toolbar_addGroupTitle),
        actions: removedGroups
            .map((g) => CupertinoActionSheetAction(
                  onPressed: () {
                    notifier.addGroup(g.id);
                    Navigator.pop(ctx);
                  },
                  child: Text('${toolbarGroupName(g.id, l)}  (${g.keys.map((k) => k.label).join(", ")})'),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.common_cancel),
        ),
      ),
    );
  }

  void _confirmRestore(
    BuildContext context,
    AppLocalizations l,
    ToolbarConfigNotifier notifier,
    VisibleGroupCountNotifier visibleCountNotifier,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.toolbar_restoreConfirmTitle),
        content: Text(l.toolbar_restoreConfirmContent),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              notifier.restoreDefaults();
              visibleCountNotifier.setCount(defaultVisibleGroupCount);
              Navigator.pop(ctx);
            },
            child: Text(l.toolbar_restoreButton),
          ),
        ],
      ),
    );
  }
}

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
    final l = AppLocalizations.of(context)!;
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
                  l.toolbar_visibleGroups,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.toolbar_visibleGroupsHint(value),
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
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final keysPreview = group.keys.map((k) => k.label).join('  ');
    final groupName = toolbarGroupName(group.id, l);

    return Opacity(
      opacity: isVisible ? 1.0 : 0.45,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 22),
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          groupName,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (!isVisible) ...[
                          const SizedBox(width: 6),
                          Text(
                            l.toolbar_hidden,
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
