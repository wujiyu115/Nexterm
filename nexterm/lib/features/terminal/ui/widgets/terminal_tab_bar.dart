import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:nexterm/shared/widgets/dashed_divider.dart';

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

  const TerminalTabBar({
    super.key,
    this.onAddTab,
    this.isFunctionMode = false,
    this.onToggleMode,
    this.onCustomizeTap,
    this.onHideKeyboard,
    this.onShowHelp,
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
            icon: Icon(
              Icons.more_horiz,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            padding: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) {
              HapticFeedback.lightImpact();
              switch (value) {
                case 'toggle':
                  onToggleMode?.call();
                case 'customize':
                  onCustomizeTap?.call();
                case 'add':
                  onAddTab?.call();
                case 'help':
                  onShowHelp?.call();
              }
            },
            itemBuilder: (ctx) {
              final l = AppLocalizations.of(ctx)!;
              final theme = Theme.of(ctx);
              final iconColor = theme.colorScheme.onSurfaceVariant;
              final textColor = theme.colorScheme.onSurface;
              final dividerColor =
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.4);

              PopupMenuItem<String> menuItem({
                required String value,
                required IconData icon,
                required String label,
              }) {
                return PopupMenuItem<String>(
                  value: value,
                  height: 40,
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: iconColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              PopupMenuItem<String> divider() => PopupMenuItem<String>(
                    enabled: false,
                    height: 9,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DashedDivider(color: dividerColor),
                  );

              return <PopupMenuEntry<String>>[
                if (onToggleMode != null)
                  menuItem(
                    value: 'toggle',
                    icon: isFunctionMode
                        ? Icons.keyboard
                        : Icons.grid_view_rounded,
                    label: isFunctionMode
                        ? l.terminal_switchToAbc
                        : l.terminal_switchToFunction,
                  ),
                if (onCustomizeTap != null)
                  menuItem(
                    value: 'customize',
                    icon: Icons.settings,
                    label: l.toolbar_customize,
                  ),
                divider(),
                menuItem(
                  value: 'add',
                  icon: Icons.add,
                  label: l.terminal_newTab,
                ),
                if (onShowHelp != null) ...[
                  divider(),
                  menuItem(
                    value: 'help',
                    icon: Icons.help_outline,
                    label: l.function_tabHelp,
                  ),
                ],
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

