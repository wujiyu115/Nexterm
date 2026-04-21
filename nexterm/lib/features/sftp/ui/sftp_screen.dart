import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/providers/sftp_provider.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_breadcrumb.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_list_view.dart';
import 'package:nexterm/features/sftp/ui/widgets/transfer_queue_bar.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';

class SftpScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SftpScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SftpScreen> createState() => _SftpScreenState();
}

class _SftpScreenState extends ConsumerState<SftpScreen> {
  SftpNotifier? _notifier;
  SftpState _sftpState = const SftpState();
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final sshService = ref.read(sshServiceProvider);
      final client = sshService.getClient(widget.sessionId);
      if (client == null) {
        throw StateError('No active SSH session for id: ${widget.sessionId}');
      }

      final sftpService = SftpService();
      await sftpService.connect(client);

      final transferQueue = ref.read(transferQueueProvider.notifier);
      final notifier = SftpNotifier(sftpService, transferQueue);

      if (!mounted) {
        sftpService.disconnect();
        return;
      }

      notifier.addListener((state) {
        if (mounted) setState(() => _sftpState = state);
      }, fireImmediately: true);

      setState(() {
        _notifier = notifier;
        _isInitializing = false;
      });

      await notifier.navigateTo('/home');
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notifier?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // File tap / long-press
  // ---------------------------------------------------------------------------

  void _onFileTap(RemoteFileInfo file) {
    final notifier = _notifier;
    if (notifier == null) return;

    if (file.isDirectory) {
      notifier.navigateTo(file.path);
    } else {
      _showFileContextMenu(file);
    }
  }

  void _onLongPress(RemoteFileInfo file) {
    _showFileContextMenu(file);
  }

  // ---------------------------------------------------------------------------
  // File context menu (long press)
  // ---------------------------------------------------------------------------

  void _showFileContextMenu(RemoteFileInfo file) {
    final l = AppLocalizations.of(context)!;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(file.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _notifier?.copyPaths([file.path]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.sftp_copied),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.doc_on_doc, size: 20),
                const SizedBox(width: 8),
                Text(l.sftp_copy),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _showRenameDialog(file);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.pencil, size: 20),
                const SizedBox(width: 8),
                Text(l.sftp_rename),
              ],
            ),
          ),
          if (!file.isDirectory)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _notifier?.downloadFile(file);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.cloud_download, size: 20),
                  const SizedBox(width: 8),
                  Text(l.sftp_download),
                ],
              ),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              Clipboard.setData(ClipboardData(text: file.path));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.sftp_pathCopied(file.path)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.link, size: 20),
                const SizedBox(width: 8),
                Text(l.sftp_copyPath),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDelete(file);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.trash, size: 20, color: CupertinoColors.destructiveRed),
                const SizedBox(width: 8),
                Text(l.common_delete),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.common_cancel),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // "..." menu actions
  // ---------------------------------------------------------------------------

  void _showSortMenu() {
    final notifier = _notifier;
    if (notifier == null) return;
    final l = AppLocalizations.of(context)!;
    final state = _sftpState;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l.sftp_sortTitle),
        actions: [
          _sortAction(ctx, l.sftp_sortByName, SortField.name, state),
          _sortAction(ctx, l.sftp_sortBySize, SortField.size, state),
          _sortAction(ctx, l.sftp_sortByDate, SortField.date, state),
          _sortAction(ctx, l.sftp_sortByType, SortField.type, state),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.common_cancel),
        ),
      ),
    );
  }

  CupertinoActionSheetAction _sortAction(
    BuildContext ctx,
    String label,
    SortField field,
    SftpState state,
  ) {
    final isActive = state.sortField == field;
    final arrow = isActive ? (state.sortAscending ? ' ↑' : ' ↓') : '';
    return CupertinoActionSheetAction(
      onPressed: () {
        Navigator.pop(ctx);
        _notifier?.setSort(field);
      },
      child: Text(
        '$label$arrow',
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _showRenameDialog(RemoteFileInfo file) {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: file.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.sftp_renameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l.sftp_renameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != file.name) {
                _notifier?.rename(file.path, newName);
              }
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(RemoteFileInfo file) {
    final l = AppLocalizations.of(context)!;
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.sftp_deleteConfirmTitle),
        content: Text(l.sftp_deleteConfirmContent(file.name)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              _notifier?.delete(file.path, isDirectory: file.isDirectory);
            },
            child: Text(l.common_delete),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog() {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.sftp_newFolderTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l.sftp_newFolderLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _notifier?.createDirectory(name);
              }
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_initError != null) {
      final l = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(title: const Text('SFTP')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l.sftp_connectionFailed(_initError!)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = null;
                  });
                  _initialize();
                },
                child: Text(l.common_retry),
              ),
            ],
          ),
        ),
      );
    }

    return _buildMain(context);
  }

  Widget _buildMain(BuildContext context) {
    final notifier = _notifier!;
    final state = _sftpState;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SFTP'),
        actions: [
          if (state.hasCopiedFiles)
            IconButton(
              icon: const Icon(Icons.paste),
              tooltip: l.sftp_paste,
              onPressed: notifier.pasteFiles,
            ),
          IconButton(
            icon: Icon(
              state.showHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            tooltip: state.showHidden ? l.sftp_hideHidden : l.sftp_showHidden,
            onPressed: notifier.toggleHidden,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 'upload':
                  notifier.uploadFiles();
                case 'newFolder':
                  _showCreateFolderDialog();
                case 'sort':
                  _showSortMenu();
                case 'refresh':
                  notifier.refresh();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'upload',
                child: ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: Text(l.sftp_upload),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              PopupMenuItem(
                value: 'newFolder',
                child: ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined),
                  title: Text(l.sftp_newFolder),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              PopupMenuItem(
                value: 'sort',
                child: ListTile(
                  leading: const Icon(Icons.sort),
                  title: Text(l.sftp_sort),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: const Icon(Icons.refresh),
                  title: Text(l.sftp_refresh),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: FileBreadcrumb(
              path: state.currentPath,
              onNavigate: notifier.navigateTo,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(state.error!),
                            TextButton(
                              onPressed: notifier.refresh,
                              child: Text(l.common_retry),
                            ),
                          ],
                        ),
                      )
                    : FileListView(
                        files: state.visibleFiles,
                        selectedPaths: state.selectedPaths,
                        onTap: _onFileTap,
                        onLongPress: _onLongPress,
                        onToggleSelect: (file) =>
                            notifier.toggleSelection(file.path),
                      ),
          ),
          const TransferQueueBar(),
        ],
      ),
    );
  }
}
