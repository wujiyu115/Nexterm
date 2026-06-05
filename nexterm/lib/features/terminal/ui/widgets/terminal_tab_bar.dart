import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:nexterm/shared/widgets/dashed_divider.dart';  // used in menu sheet

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
  final VoidCallback? onOpenSftp;
  final VoidCallback? onOpenGit;
  final VoidCallback? onOpenWeb;
  final VoidCallback? onOpenMux;

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
    this.onOpenSftp,
    this.onOpenGit,
    this.onOpenWeb,
    this.onOpenMux,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabManager = ref.watch(tabManagerProvider);
    final tabs = tabManager.tabs;
    final activeIndex = tabManager.activeTabIndex;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final barBg = p.bgElevated;
    final barFg = p.fg;

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

          _MenuButton(
            color: barFg,
            onAddTab: onAddTab,
            onGoToHosts: onGoToHosts,
            onShowHelp: onShowHelp,
            onOpenSftp: onOpenSftp,
            onUploadFile: onUploadFile,
            onOpenGit: onOpenGit,
            onOpenWeb: onOpenWeb,
            onOpenMux: onOpenMux,
            onDetectPorts: onDetectPorts,
            onToggleMode: onToggleMode,
            onCustomizeTap: onCustomizeTap,
            isFunctionMode: isFunctionMode,
          ),
        ],
      ),
    );
  }

}

class _MenuButton extends StatefulWidget {
  final Color color;
  final VoidCallback? onAddTab;
  final VoidCallback? onGoToHosts;
  final VoidCallback? onShowHelp;
  final VoidCallback? onOpenSftp;
  final VoidCallback? onUploadFile;
  final VoidCallback? onOpenGit;
  final VoidCallback? onOpenWeb;
  final VoidCallback? onOpenMux;
  final VoidCallback? onDetectPorts;
  final VoidCallback? onToggleMode;
  final VoidCallback? onCustomizeTap;
  final bool isFunctionMode;

  const _MenuButton({
    required this.color,
    this.onAddTab,
    this.onGoToHosts,
    this.onShowHelp,
    this.onOpenSftp,
    this.onUploadFile,
    this.onOpenGit,
    this.onOpenWeb,
    this.onOpenMux,
    this.onDetectPorts,
    this.onToggleMode,
    this.onCustomizeTap,
    this.isFunctionMode = false,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  String? _expandedGroup;
  OverlayEntry? _overlay;

  void _show() {
    _expandedGroup = null;
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlay = OverlayEntry(builder: (ctx) {
      return Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismiss,
            child: const SizedBox.expand(),
          ),
          Positioned(
            right: MediaQuery.of(ctx).size.width - offset.dx - size.width,
            top: offset.dy + size.height + 4,
            child: _MenuPopup(
              expandedGroup: _expandedGroup,
              onGroupTap: (key) {
                setState(() {
                  _expandedGroup = _expandedGroup == key ? null : key;
                });
                _overlay?.markNeedsBuild();
              },
              onItemTap: (cb) {
                _dismiss();
                HapticFeedback.lightImpact();
                cb?.call();
              },
              onAddTab: widget.onAddTab,
              onGoToHosts: widget.onGoToHosts,
              onShowHelp: widget.onShowHelp,
              onOpenSftp: widget.onOpenSftp,
              onUploadFile: widget.onUploadFile,
              onOpenGit: widget.onOpenGit,
              onOpenWeb: widget.onOpenWeb,
              onOpenMux: widget.onOpenMux,
              onDetectPorts: widget.onDetectPorts,
              onToggleMode: widget.onToggleMode,
              onCustomizeTap: widget.onCustomizeTap,
              isFunctionMode: widget.isFunctionMode,
            ),
          ),
        ],
      );
    });
    Overlay.of(context).insert(_overlay!);
  }

  void _dismiss() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.more_horiz, size: 18, color: widget.color),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40),
      onPressed: _show,
    );
  }
}

class _MenuPopup extends StatelessWidget {
  final String? expandedGroup;
  final void Function(String key) onGroupTap;
  final void Function(VoidCallback? cb) onItemTap;
  final VoidCallback? onAddTab;
  final VoidCallback? onGoToHosts;
  final VoidCallback? onShowHelp;
  final VoidCallback? onOpenSftp;
  final VoidCallback? onUploadFile;
  final VoidCallback? onOpenGit;
  final VoidCallback? onOpenWeb;
  final VoidCallback? onOpenMux;
  final VoidCallback? onDetectPorts;
  final VoidCallback? onToggleMode;
  final VoidCallback? onCustomizeTap;
  final bool isFunctionMode;

  const _MenuPopup({
    this.expandedGroup,
    required this.onGroupTap,
    required this.onItemTap,
    this.onAddTab,
    this.onGoToHosts,
    this.onShowHelp,
    this.onOpenSftp,
    this.onUploadFile,
    this.onOpenGit,
    this.onOpenWeb,
    this.onOpenMux,
    this.onDetectPorts,
    this.onToggleMode,
    this.onCustomizeTap,
    this.isFunctionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;

    final hasFileItems = onOpenSftp != null;
    final hasToolItems = onOpenGit != null || onOpenWeb != null || onOpenMux != null || onDetectPorts != null;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: p.bgElevated,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _item(context, Icons.add, l.terminal_newTab, () => onItemTap(onAddTab)),
              if (onGoToHosts != null)
                _item(context, Icons.dns_outlined, l.terminal_backToHosts, () => onItemTap(onGoToHosts)),
              if (hasFileItems) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DashedDivider(color: p.border),
                ),
                if (onOpenSftp != null) _item(context, Icons.folder_outlined, l.terminal_openSftp, () => onItemTap(onOpenSftp)),
              ],
              if (hasToolItems)
                _group(context, Icons.build_outlined, l.terminal_menuTools, 'tools', [
                  if (onOpenGit != null) _item(context, Icons.account_tree_outlined, l.terminal_openGit, () => onItemTap(onOpenGit)),
                  if (onOpenWeb != null) _item(context, Icons.language, l.terminal_openWeb, () => onItemTap(onOpenWeb)),
                  if (onOpenMux != null) _item(context, Icons.view_week_outlined, l.terminal_openMux, () => onItemTap(onOpenMux)),
                  if (onDetectPorts != null) _item(context, Icons.radar, l.portDetect_tooltip, () => onItemTap(onDetectPorts)),
                ]),
              if (onCustomizeTap != null)
                _group(context, Icons.settings_outlined, l.terminal_menuSettings, 'settings', [
                  _item(context, Icons.settings, l.toolbar_customize, () => onItemTap(onCustomizeTap)),
                ]),
              if (onToggleMode != null || onShowHelp != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DashedDivider(color: p.border),
                ),
                if (onToggleMode != null) _item(
                  context,
                  isFunctionMode ? Icons.keyboard : Icons.grid_view_rounded,
                  isFunctionMode ? l.terminal_switchToAbc : l.terminal_switchToFunction,
                  () => onItemTap(onToggleMode),
                ),
                if (onShowHelp != null)
                  _item(context, Icons.help_outline, l.function_tabHelp, () => onItemTap(onShowHelp)),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: p.fgSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.fg))),
          ],
        ),
      ),
    );
  }

  Widget _group(BuildContext context, IconData icon, String label, String key, List<Widget> children) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final isExpanded = expandedGroup == key;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => onGroupTap(key),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: p.fgSecondary),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.fg))),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.chevron_right, size: 16, color: p.fgTertiary),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
      ],
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
    final p = Theme.of(context).extension<ThemePalette>()!;
    final color = isActive
        ? p.accentDim
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
                  ? p.accent
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (tab.connectionType) {
                ConnectionType.sftp => Icons.folder_outlined,
                ConnectionType.webdav => Icons.cloud_outlined,
                ConnectionType.smb => Icons.folder_shared_outlined,
                ConnectionType.webPreview => Icons.language,
                _ => Icons.terminal,
              },
              size: 14,
              color: isActive ? p.accent : null,
            ),
            const SizedBox(width: 4),
            _StatusDot(status: tab.status),
            const SizedBox(width: 6),
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
    final p = Theme.of(context).extension<ThemePalette>()!;
    final color = switch (status) {
      ConnectionStatus.connected => p.statusOnline,
      ConnectionStatus.connecting => p.accent,
      ConnectionStatus.disconnected => p.statusOffline,
      ConnectionStatus.error => p.statusError,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: status == ConnectionStatus.connected
            ? [BoxShadow(color: p.accentGlow, blurRadius: 6)]
            : null,
      ),
    );
  }
}

