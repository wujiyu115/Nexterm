import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/providers/sftp_provider.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/utils/file_icon.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_breadcrumb.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_list_view.dart';
import 'package:nexterm/features/sftp/ui/widgets/permission_dialog.dart';
import 'package:nexterm/features/sftp/ui/widgets/transfer_queue_bar.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:go_router/go_router.dart';

class SftpContentWidget extends ConsumerStatefulWidget {
  final String? sessionId;
  final RemoteFileService? service;

  const SftpContentWidget({super.key, this.sessionId, this.service})
      : assert(sessionId != null || service != null,
            'Either sessionId or service must be provided');

  @override
  ConsumerState<SftpContentWidget> createState() => _SftpContentWidgetState();
}

class _SftpContentWidgetState extends ConsumerState<SftpContentWidget> {
  SftpNotifier? _notifier;
  SftpState _sftpState = const SftpState();
  bool _isInitializing = true;
  String? _initError;

  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final RemoteFileService fileService;
      if (widget.service != null) {
        fileService = widget.service!;
      } else {
        final sshService = ref.read(sshServiceProvider);
        final client = sshService.getClient(widget.sessionId!);
        if (client == null) {
          throw StateError('No active SSH session for id: ${widget.sessionId}');
        }

        final sftpService = SftpService();
        await sftpService.connect(client);
        fileService = sftpService;
      }

      final transferQueue = ref.read(transferQueueProvider.notifier);
      final notifier = SftpNotifier(fileService, transferQueue);

      if (!mounted) {
        fileService.disconnect();
        return;
      }

      notifier.addListener((state) {
        if (mounted) setState(() => _sftpState = state);
      }, fireImmediately: true);

      setState(() {
        _notifier = notifier;
        _isInitializing = false;
      });

      final home = await fileService.homePath();
      await notifier.navigateTo(home);
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
    _searchController.dispose();
    _notifier?.dispose();
    super.dispose();
  }

  List<RemoteFileInfo> get _filteredFiles {
    final files = _sftpState.visibleFiles;
    if (_searchQuery.isEmpty) return files;
    final lower = _searchQuery.toLowerCase();
    return files.where((f) => f.name.toLowerCase().contains(lower)).toList();
  }

  void _onFileTap(RemoteFileInfo file) {
    final notifier = _notifier;
    if (notifier == null) return;

    if (file.isDirectory) {
      notifier.navigateTo(file.path);
      if (_isSearching) {
        setState(() { _isSearching = false; _searchQuery = ''; _searchController.clear(); });
      }
    } else {
      _showFileContextMenu(file);
    }
  }

  void _onLongPress(RemoteFileInfo file) {
    _showFileContextMenu(file);
  }

  void _showFileContextMenu(RemoteFileInfo file) {
    final l = AppLocalizations.of(context)!;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(file.name),
        actions: [
          if (!file.isDirectory && isImageFile(file.name))
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/sftp/image', extra: <String, dynamic>{'sessionId': widget.sessionId, 'path': file.path, 'service': widget.service});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.photo, size: 20),
                  const SizedBox(width: 8),
                  Text(l.sftp_viewImage),
                ],
              ),
            ),
          if (!file.isDirectory && isEditableFile(file.name)) ...[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/sftp/edit', extra: <String, dynamic>{'sessionId': widget.sessionId, 'path': file.path, 'viewOnly': 'true', 'service': widget.service});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.eye, size: 20),
                  const SizedBox(width: 8),
                  Text(l.sftp_view),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/sftp/edit', extra: <String, dynamic>{'sessionId': widget.sessionId, 'path': file.path, 'viewOnly': 'false', 'service': widget.service});
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.pencil_ellipsis_rectangle, size: 20),
                  const SizedBox(width: 8),
                  Text(l.sftp_edit),
                ],
              ),
            ),
          ],
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _notifier?.copyPaths([file.path]);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.sftp_copied), duration: const Duration(seconds: 2)),
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
                SnackBar(content: Text(l.sftp_pathCopied(file.path)), duration: const Duration(seconds: 2)),
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
          if (file.permissions != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _showPermissions(file);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.lock_shield, size: 20),
                  const SizedBox(width: 8),
                  Text(l.sftp_permissions),
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

  void _showPermissions(RemoteFileInfo file) async {
    final result = await showPermissionDialog(context, initialPermissions: file.permissions ?? 0x1A4);
    if (result != null && _notifier != null) {
      await _notifier!.chmod(file.path, result);
      _notifier!.refresh();
    }
  }

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
    BuildContext ctx, String label, SortField field, SftpState state,
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
        style: TextStyle(fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
      ),
    );
  }

  void _showGoToPathDialog() {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _sftpState.currentPath);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.sftp_goToPath),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.sftp_goToPathHint,
            prefixIcon: const Icon(Icons.folder_outlined),
          ),
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final path = controller.text.trim();
              if (path.isNotEmpty) _notifier?.navigateTo(path);
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

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
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
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
          CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final name = controller.text.trim();
              if (name.isNotEmpty) _notifier?.createDirectory(name);
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_initError != null) {
      final l = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: OutdoorColors.darkStatusError),
            const SizedBox(height: 16),
            Text(l.sftp_connectionFailed(_initError!)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() { _isInitializing = true; _initError = null; });
                _initialize();
              },
              child: Text(l.common_retry),
            ),
          ],
        ),
      );
    }

    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final notifier = _notifier!;
    final state = _sftpState;
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary;

    return Column(
      children: [
        // Compact toolbar
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _toolbarIcon(
                icon: _isSearching ? Icons.search_off : Icons.search,
                color: iconColor,
                onTap: () => setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) { _searchQuery = ''; _searchController.clear(); }
                }),
              ),
              if (state.hasCopiedFiles)
                _toolbarIcon(icon: Icons.paste, color: iconColor, onTap: notifier.pasteFiles),
              _toolbarIcon(
                icon: state.showHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: iconColor,
                onTap: notifier.toggleHidden,
              ),
              _toolbarIcon(icon: Icons.upload_outlined, color: iconColor, onTap: notifier.uploadFiles),
              _toolbarIcon(icon: Icons.create_new_folder_outlined, color: iconColor, onTap: _showCreateFolderDialog),
              _toolbarIcon(icon: Icons.drive_file_move_outline, color: iconColor, onTap: _showGoToPathDialog),
              _toolbarIcon(icon: Icons.sort, color: iconColor, onTap: _showSortMenu),
              _toolbarIcon(icon: Icons.refresh, color: iconColor, onTap: notifier.refresh),
              if (widget.sessionId != null && state.files.any((f) => f.isDirectory && f.name == '.git'))
                _toolbarIcon(
                  icon: Icons.source_outlined,
                  color: iconColor,
                  onTap: () => context.push('/git/${widget.sessionId}?path=${Uri.encodeComponent(state.currentPath)}'),
                ),
            ],
          ),
        ),
        // Search bar or breadcrumb
        if (_isSearching)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: l.toolbar_groupSearch,
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() { _searchController.clear(); _searchQuery = ''; }))
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          )
        else
          Container(
            height: 36,
            alignment: Alignment.centerLeft,
            child: FileBreadcrumb(path: state.currentPath, onNavigate: notifier.navigateTo),
          ),
        const Divider(height: 1),
        // File list
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: OutdoorColors.darkStatusError),
                          const SizedBox(height: 8),
                          Text(state.error!),
                          TextButton(onPressed: notifier.refresh, child: Text(l.common_retry)),
                        ],
                      ),
                    )
                  : FileListView(
                      files: _filteredFiles,
                      selectedPaths: state.selectedPaths,
                      onTap: _onFileTap,
                      onLongPress: _onLongPress,
                      onToggleSelect: (file) => notifier.toggleSelection(file.path),
                    ),
        ),
        const TransferQueueBar(),
      ],
    );
  }

  Widget _toolbarIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
