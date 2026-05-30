import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
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
  final VoidCallback? onGoToHosts;
  final VoidCallback? onUploadFile;
  final VoidCallback? onDetectPorts;

  const TerminalTabBar({
    super.key,
    this.onAddTab,
    this.isFunctionMode = false,
    this.onToggleMode,
    this.onCustomizeTap,
    this.onHideKeyboard,
    this.onShowHelp,
    this.onGoToHosts,
    this.onUploadFile,
    this.onDetectPorts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabManager = ref.watch(tabManagerProvider);
    final tabs = tabManager.tabs;
    final activeIndex = tabManager.activeTabIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg = isDark ? OutdoorColors.darkBgElevated : OutdoorColors.lightBgElevated;
    final barFg = isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg;
    final menuBg = isDark ? OutdoorColors.darkBgElevated : OutdoorColors.lightBgElevated;

    return Container(
      height: 40,
      color: barBg,
      child: Row(
        children: [
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
              color: barFg,
            ),
            padding: EdgeInsets.zero,
            color: menuBg,
            surfaceTintColor: Colors.transparent,
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
                case 'hosts':
                  onGoToHosts?.call();
                case 'help':
                  onShowHelp?.call();
                case 'upload':
                  onUploadFile?.call();
                case 'detect_ports':
                  onDetectPorts?.call();
              }
            },
            itemBuilder: (ctx) {
              final l = AppLocalizations.of(ctx)!;
              final theme = Theme.of(ctx);
              final menuDark = theme.brightness == Brightness.dark;
              final iconColor = menuDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary;
              final textColor = menuDark ? OutdoorColors.darkFg : OutdoorColors.lightFg;
              final dividerColor = menuDark ? OutdoorColors.darkBorder : OutdoorColors.lightBorder;

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

              final hasTerminalItems = onToggleMode != null || onCustomizeTap != null;
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
                if (hasTerminalItems) divider(),
                menuItem(
                  value: 'add',
                  icon: Icons.add,
                  label: l.terminal_newTab,
                ),
                if (onUploadFile != null)
                  menuItem(
                    value: 'upload',
                    icon: Icons.upload_file_outlined,
                    label: l.terminal_uploadFile,
                  ),
                if (onDetectPorts != null)
                  menuItem(
                    value: 'detect_ports',
                    icon: Icons.radar,
                    label: l.portDetect_tooltip,
                  ),
                if (onGoToHosts != null)
                  menuItem(
                    value: 'hosts',
                    icon: Icons.dns_outlined,
                    label: l.terminal_backToHosts,
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
    final color = isActive
        ? OutdoorColors.accentDim
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
                  ? OutdoorColors.accent
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (status) {
      ConnectionStatus.connected => isDark ? OutdoorColors.darkStatusOnline : OutdoorColors.lightStatusOnline,
      ConnectionStatus.connecting => OutdoorColors.accent,
      ConnectionStatus.disconnected => isDark ? OutdoorColors.darkStatusOffline : OutdoorColors.lightStatusOffline,
      ConnectionStatus.error => isDark ? OutdoorColors.darkStatusError : OutdoorColors.lightStatusError,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: status == ConnectionStatus.connected
            ? [BoxShadow(color: OutdoorColors.accentGlow, blurRadius: 6)]
            : null,
      ),
    );
  }
}

