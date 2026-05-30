import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/widgets/function_panel.dart';
import 'package:nexterm/features/terminal/ui/widgets/keyboard_toolbar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_tab_bar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_view.dart';
import 'package:nexterm/shared/widgets/dashed_divider.dart';

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

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _toggleKeyboard() {
    final hasFocus = FocusScope.of(context).hasFocus;
    if (hasFocus) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).requestFocus();
    }
  }

  void _showHelpDialog() {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg;
    final dimColor = isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary;

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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.function_tabHelp),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: shortcuts.map((entry) {
            final (key, desc) = entry;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? OutdoorColors.darkInputBg : OutdoorColors.lightInputBg,
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
                  Expanded(child: Text(desc, style: TextStyle(fontSize: 13, color: dimColor))),
                ],
              ),
            );
          }).toList(),
        ),
        ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.common_cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showHostPickerDialog() async {
    final selectedHostId = await showDialog<String>(
      context: context,
      builder: (ctx) => const _HostPickerDialog(),
    );
    if (selectedHostId == null || !mounted) return;
    await ref.read(terminalActionsProvider).connectHost(selectedHostId);
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
          context.go('/vaults/hosts');
        }
      });
    }
    _hadTabs = hasTabs;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = hasTabs ? OutdoorColors.darkTerminalBg : (isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),

          Theme(
            data: hasTabs ? AppTheme.dark() : Theme.of(context),
            child: TerminalTabBar(
              onAddTab: _showHostPickerDialog,
              isFunctionMode: _isFunctionMode,
              onToggleMode: activeTab != null ? _toggleKeyboardMode : null,
              onCustomizeTap: activeTab != null
                  ? () => context.push('/terminal/customize-keyboard')
                  : null,
              onHideKeyboard: activeTab != null ? _toggleKeyboard : null,
              onShowHelp: activeTab != null ? _showHelpDialog : null,
              onGoToHosts: () => context.go('/vaults/hosts'),
            ),
          ),

          Expanded(
            child: ClipRect(
              child: activeTab == null
                  ? _EmptyState(
                      isConnecting: widget.hostId != null && !_didAutoConnect,
                    )
                  : TerminalViewWidget(
                      tab: activeTab,
                      hardwareKeyboardOnly: _isFunctionMode,
                    ),
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
                onKeyInput: (data) {
                  final sshService = ref.read(sshServiceProvider);
                  if (activeTab.sessionId != null) {
                    sshService.writeBytes(activeTab.sessionId!, data);
                  }
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
                onHideKeyboard: _hideKeyboard,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg;
    final fgSecondary = isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary;
    final fgTertiary = isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary;

    if (isConnecting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l.terminal_connecting, style: TextStyle(color: fgColor)),
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
            color: fgTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l.terminal_noTabs,
            style: TextStyle(color: fgSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            l.terminal_noTabsHint,
            style: TextStyle(color: fgTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Modal dialog that lists all available hosts and lets the user pick one to
/// open in a new terminal tab.
class _HostPickerDialog extends ConsumerWidget {
  const _HostPickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.watch(hostsStreamProvider);
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.hosts_selectToConnect,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            DashedDivider(
              color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkBorder : OutdoorColors.lightBorder,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Flexible(
              child: hostsAsync.when(
                data: (hosts) {
                  if (hosts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.dns_outlined,
                            size: 48,
                            color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.hosts_noHosts,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  return _HostPickerList(hosts: hosts);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.common_error(e.toString())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostPickerList extends ConsumerWidget {
  final List<HostEntity> hosts;

  const _HostPickerList({required this.hosts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tabManager = ref.watch(tabManagerProvider);

    final activeCounts = <String, int>{};
    for (final tab in tabManager.tabs) {
      activeCounts[tab.hostId] = (activeCounts[tab.hostId] ?? 0) + 1;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? OutdoorColors.darkBorder : OutdoorColors.lightBorder;
    return ListView.separated(
      shrinkWrap: true,
      itemCount: hosts.length,
      separatorBuilder: (_, __) => DashedDivider(
        color: dividerColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      itemBuilder: (context, index) {
        final host = hosts[index];
        final activeCount = activeCounts[host.id] ?? 0;
        return ListTile(
          leading: Icon(
            host.isFavorite ? Icons.star : Icons.dns_outlined,
            color: OutdoorColors.accent,
          ),
          title: Text(
            host.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${host.username}@${host.hostname}:${host.port}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary),
          ),
          trailing: activeCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: OutdoorColors.accentDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l.hosts_activeConnections(activeCount),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: OutdoorColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
          onTap: () => Navigator.of(context).pop(host.id),
        );
      },
    );
  }
}
