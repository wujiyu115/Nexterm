import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';

/// Horizontal tab bar showing all open terminal tabs with:
/// - Status indicator dot (color by [ConnectionStatus])
/// - Tab title
/// - Close button
/// - "+" button to open a new connection
class TerminalTabBar extends ConsumerWidget {
  /// Called when the user taps the "+" button to add a new tab.
  final VoidCallback? onAddTab;

  final bool isFunctionMode;
  final VoidCallback? onToggleMode;
  final VoidCallback? onCustomizeTap;
  final VoidCallback? onHideKeyboard;
  final VoidCallback? onShowHelp;
  final VoidCallback? onGoToHosts;

  const TerminalTabBar({
    super.key,
    this.onAddTab,
    this.isFunctionMode = false,
    this.onToggleMode,
    this.onCustomizeTap,
    this.onHideKeyboard,
    this.onShowHelp,
    this.onGoToHosts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabManager = ref.watch(tabManagerProvider);
    final tabs = tabManager.tabs;
    final activeIndex = tabManager.activeTabIndex;

    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Scrollable tab list.
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = index == activeIndex;
                return _TabItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () =>
                      ref.read(tabManagerProvider).setActiveTab(index),
                  onClose: () => ref
                      .read(terminalActionsProvider)
                      .disconnectTab(tab.id),
                );
              },
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, size: 18),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              HapticFeedback.lightImpact();
              switch (value) {
                case 'toggle':
                  onToggleMode?.call();
                case 'customize':
                  onCustomizeTap?.call();
                case 'add':
                  onAddTab?.call();
                case 'hide_keyboard':
                  onHideKeyboard?.call();
                case 'help':
                  onShowHelp?.call();
                case 'hosts':
                  onGoToHosts?.call();
              }
            },
            itemBuilder: (ctx) {
              final l = AppLocalizations.of(ctx)!;
              return [
                if (onToggleMode != null)
                  PopupMenuItem(
                    value: 'toggle',
                    child: ListTile(
                      leading: Icon(
                        isFunctionMode ? Icons.keyboard : Icons.grid_view_rounded,
                      ),
                      title: Text(
                        isFunctionMode
                            ? l.terminal_switchToAbc
                            : l.terminal_switchToFunction,
                      ),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (onCustomizeTap != null)
                  PopupMenuItem(
                    value: 'customize',
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(l.toolbar_customize),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (onHideKeyboard != null)
                  PopupMenuItem(
                    value: 'hide_keyboard',
                    child: ListTile(
                      leading: const Icon(Icons.keyboard_hide),
                      title: Text(l.terminal_hideKeyboard),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (onShowHelp != null)
                  PopupMenuItem(
                    value: 'help',
                    child: ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(l.function_tabHelp),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (onGoToHosts != null)
                  PopupMenuItem(
                    value: 'hosts',
                    child: ListTile(
                      leading: const Icon(Icons.dns_outlined),
                      title: Text(l.terminal_backToHosts),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                PopupMenuItem(
                  value: 'add',
                  child: ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(l.terminal_newTab),
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final TerminalTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primaryContainer
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
        decoration: BoxDecoration(
          color: color,
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator.
            _StatusDot(status: tab.status),
            const SizedBox(width: 6),
            // Title — truncated if too long.
            Flexible(
              child: Text(
                tab.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            // Close button.
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final ConnectionStatus status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ConnectionStatus.connected => Colors.green,
      ConnectionStatus.connecting => Colors.orange,
      ConnectionStatus.disconnected => Colors.grey,
      ConnectionStatus.error => Colors.red,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
