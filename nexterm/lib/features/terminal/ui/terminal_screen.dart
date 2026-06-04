import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/widgets/function_panel.dart';
import 'package:nexterm/features/terminal/ui/widgets/dpad_panel.dart';
import 'package:nexterm/features/terminal/ui/widgets/keyboard_toolbar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_tab_bar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_view.dart';
import 'package:nexterm/features/sftp/ui/widgets/sftp_content.dart';
import 'package:nexterm/features/forwarding/ui/port_detection_sheet.dart';
import 'package:nexterm/features/forwarding/ui/widgets/web_preview_content.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/shared/widgets/dashed_divider.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  final String? hostId;
  final String? tabId;

  const TerminalScreen({super.key, this.hostId, this.tabId});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  bool _didAutoConnect = false;
  bool _hadTabs = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hostId != null) {
        _autoConnect();
      } else if (widget.tabId != null) {
        _resumeTab();
      }
    });
  }

  Future<void> _autoConnect() async {
    if (_didAutoConnect) return;
    _didAutoConnect = true;
    await ref.read(terminalActionsProvider).connectHost(widget.hostId!);
  }

  void _resumeTab() {
    final tabManager = ref.read(tabManagerProvider);
    final index = tabManager.tabs.indexWhere((t) => t.id == widget.tabId);
    if (index >= 0) {
      tabManager.setActiveTab(index);
    }
  }

  bool _isFunctionMode = false;
  bool _isDpadVisible = false;

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
    if (_isDpadVisible) setState(() => _isDpadVisible = false);
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
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final dimColor = p.fgSecondary;

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
                      color: p.inputBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      key,
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontFamily: AppFonts.mono,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(desc, style: theme.textTheme.bodyMedium!.copyWith(color: dimColor))),
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

  Future<void> _uploadFile() async {
    final tabManager = ref.read(tabManagerProvider);
    final activeTab = tabManager.activeTab;
    if (activeTab?.sessionId == null) return;

    final l = AppLocalizations.of(context)!;
    final sshService = ref.read(sshServiceProvider);
    final client = sshService.getClient(activeTab!.sessionId!);
    if (client == null) return;

    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty || !mounted) return;

    final file = result.files.single;
    final localPath = file.path;
    if (localPath == null) return;

    final sftp = SftpService();
    try {
      await sftp.connect(client);
      final homePath = await sftp.homePath();
      final remotePath = '$homePath/${file.name}';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.terminal_uploading(file.name)),
          duration: const Duration(minutes: 5),
        ),
      );

      await sftp.uploadFile(localPath, remotePath);
      sftp.disconnect();

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      _showUploadCompleteDialog(remotePath);
    } catch (e) {
      sftp.disconnect();
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.terminal_uploadFailed(e.toString()))),
      );
    }
  }

  void _showUploadCompleteDialog(String remotePath) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.terminal_uploadComplete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.terminal_remotePath, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            SelectableText(
              remotePath,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontFamily: AppFonts.mono),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: remotePath));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.terminal_pathCopied)),
              );
            },
            child: Text(l.terminal_copyPath),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final tabManager = ref.read(tabManagerProvider);
              final tab = tabManager.activeTab;
              if (tab?.sessionId != null) {
                ref.read(sshServiceProvider).write(tab!.sessionId!, remotePath);
              }
            },
            child: Text(l.terminal_pasteToTerminal),
          ),
        ],
      ),
    );
  }

  void _showPortDetection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PortDetectionSheet(),
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

  Future<void> _openSftpTab() async {
    final tabManager = ref.read(tabManagerProvider);
    final activeTab = tabManager.activeTab;
    if (activeTab == null) return;
    await ref.read(terminalActionsProvider).connectHost(
      activeTab.hostId,
      connectionType: ConnectionType.sftp,
    );
  }

  Future<void> _openGitTab() async {
    final tabManager = ref.read(tabManagerProvider);
    final activeTab = tabManager.activeTab;
    if (activeTab == null || activeTab.sessionId == null) return;

    final sshService = ref.read(sshServiceProvider);
    final client = sshService.getClient(activeTab.sessionId!);
    if (client == null) return;

    String remotePath = '.';
    try {
      // Find the PTY shell's cwd via /proc: the exec channel and PTY shell
      // share the same sshd parent process.
      final session = await client.execute(
        r"p=$(cat /proc/$$/status 2>/dev/null | grep PPid | awk '{print $2}');"
        r" c=$(ps --ppid $p -o pid=,tty= 2>/dev/null | grep pts | head -1 | awk '{print $1}');"
        r' readlink /proc/${c:-$$}/cwd 2>/dev/null || pwd',
      );
      final stdoutBytes = await session.stdout.toList();
      final pwd = String.fromCharCodes(stdoutBytes.expand((b) => b)).trim();
      await session.done;
      if (pwd.isNotEmpty) remotePath = pwd;
    } catch (_) {}

    if (!mounted) return;
    context.push('/git/${activeTab.sessionId}?path=${Uri.encodeComponent(remotePath)}');
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
        }
      });
    }
    _hadTabs = hasTabs;

    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final terminalBg = ref.watch(paletteProvider).terminal.background;

    return Scaffold(
      backgroundColor: terminalBg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),

          TerminalTabBar(
            onAddTab: _showHostPickerDialog,
            isFunctionMode: _isFunctionMode,
            onToggleMode: activeTab != null && activeTab.connectionType == ConnectionType.ssh ? _toggleKeyboardMode : null,
            onCustomizeTap: activeTab != null && activeTab.connectionType == ConnectionType.ssh
                ? () => context.push('/terminal/customize-keyboard')
                : null,
            onHideKeyboard: activeTab != null && activeTab.connectionType == ConnectionType.ssh ? _toggleKeyboard : null,
            onShowHelp: activeTab != null && activeTab.connectionType == ConnectionType.ssh ? _showHelpDialog : null,
            onUploadFile: activeTab != null && activeTab.connectionType == ConnectionType.ssh ? _uploadFile : null,
            onDetectPorts: activeTab != null && activeTab.connectionType == ConnectionType.ssh ? _showPortDetection : null,
            onOpenSftp: activeTab != null && activeTab.connectionType == ConnectionType.ssh ? _openSftpTab : null,
            onOpenGit: activeTab != null && activeTab.connectionType == ConnectionType.ssh ? _openGitTab : null,
            onGoToHosts: () {
              if (context.canPop()) context.pop();
            },
          ),

          Expanded(
            child: ClipRect(
              child: activeTab == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(l.terminal_connecting, style: TextStyle(color: p.fg)),
                        ],
                      ),
                    )
                  : activeTab.connectionType == ConnectionType.sftp && activeTab.sessionId != null
                      ? SftpContentWidget(sessionId: activeTab.sessionId!)
                      : activeTab.connectionType == ConnectionType.webPreview && activeTab.localPort != null
                          ? WebPreviewContent(localPort: activeTab.localPort!, title: activeTab.title)
                          : (activeTab.connectionType == ConnectionType.webdav || activeTab.connectionType == ConnectionType.smb)
                              ? SftpContentWidget(service: ref.read(fileServicesProvider)[activeTab.id])
                              : TerminalViewWidget(
                              tab: activeTab,
                              hardwareKeyboardOnly: _isFunctionMode,
                            ),
            ),
          ),

          if (activeTab != null && activeTab.connectionType == ConnectionType.ssh) ...[
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
            else ...[
              if (_isDpadVisible)
                DPadPanel(
                  onKeyInput: (data) {
                    final sshService = ref.read(sshServiceProvider);
                    if (activeTab.sessionId != null) {
                      sshService.writeBytes(activeTab.sessionId!, data);
                    }
                  },
                ),
              KeyboardToolbar(
                onKeyInput: (data) {
                  final sshService = ref.read(sshServiceProvider);
                  if (activeTab.sessionId != null) {
                    sshService.writeBytes(activeTab.sessionId!, data);
                  }
                },
                onHideKeyboard: _hideKeyboard,
                onToggleDpad: () => setState(() => _isDpadVisible = !_isDpadVisible),
                isDpadVisible: _isDpadVisible,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _HostPickerDialog extends ConsumerWidget {
  const _HostPickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.watch(hostsStreamProvider);
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;

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
              color: p.border,
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
                            color: p.fgTertiary,
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
    final p = theme.extension<ThemePalette>()!;
    final tabManager = ref.watch(tabManagerProvider);

    final activeCounts = <String, int>{};
    for (final tab in tabManager.tabs) {
      activeCounts[tab.hostId] = (activeCounts[tab.hostId] ?? 0) + 1;
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: hosts.length,
      separatorBuilder: (_, __) => DashedDivider(
        color: p.border,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      itemBuilder: (context, index) {
        final host = hosts[index];
        final activeCount = activeCounts[host.id] ?? 0;
        return ListTile(
          leading: Icon(
            host.isFavorite ? Icons.star : Icons.dns_outlined,
            color: p.accent,
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
            style: TextStyle(color: p.fgSecondary),
          ),
          trailing: activeCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.accentDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l.hosts_activeConnections(activeCount),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: p.accent,
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
