import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
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
import 'package:nexterm/shared/widgets/dashed_divider.dart';
import 'package:nexterm/shared/widgets/swipe_to_delete_wrapper.dart';

class SftpContentWidget extends ConsumerStatefulWidget {
  final String? sessionId;
  final RemoteFileService? service;
  final String? initialPath;

  const SftpContentWidget({super.key, this.sessionId, this.service, this.initialPath})
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
  String _homePath = '/';
  final _swipeController = SwipeToDeleteController();

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
      final startPath = widget.initialPath ?? home;
      if (mounted) setState(() => _homePath = home);
      await notifier.navigateTo(startPath);
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
    _swipeController.dispose();
    _notifier?.dispose();
    super.dispose();
  }

  List<RemoteFileInfo> get _filteredFiles {
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      return _sftpState.visibleFiles.where((f) => f.name.toLowerCase().contains(lower)).toList();
    }
    return _sftpState.displayFiles;
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
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: p.fgTertiary, borderRadius: BorderRadius.circular(2)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(file.name, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: p.border),
              if (!file.isDirectory && isVideoFile(file.name))
                _menuTile(ctx, Icons.play_circle_outline, l.video_play, p.fg, () {
                  context.push('/sftp/video', extra: <String, dynamic>{'sessionId': widget.sessionId, 'path': file.path, 'service': widget.service});
                }),
              if (!file.isDirectory && isImageFile(file.name))
                _menuTile(ctx, Icons.image_outlined, l.sftp_viewImage, p.fg, () {
                  context.push('/sftp/image', extra: <String, dynamic>{'sessionId': widget.sessionId, 'path': file.path, 'service': widget.service});
                }),
              if (!file.isDirectory && isEditableFile(file.name)) ...[
                _menuTile(ctx, Icons.visibility_outlined, l.sftp_view, p.fg, () {
                  context.push('/sftp/edit', extra: <String, dynamic>{'sessionId': widget.sessionId, 'path': file.path, 'viewOnly': 'true', 'service': widget.service});
                }),
                _menuTile(ctx, Icons.edit_outlined, l.sftp_edit, p.fg, () {
                  context.push('/sftp/edit', extra: <String, dynamic>{'sessionId': widget.sessionId, 'path': file.path, 'viewOnly': 'false', 'service': widget.service});
                }),
              ],
              _menuTile(ctx, Icons.copy_outlined, l.sftp_copy, p.fg, () {
                _notifier?.copyPaths([file.path]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.sftp_copied), duration: const Duration(seconds: 2)),
                );
              }),
              _menuTile(ctx, Icons.drive_file_rename_outline, l.sftp_rename, p.fg, () {
                _showRenameDialog(file);
              }),
              if (!file.isDirectory)
                _menuTile(ctx, Icons.cloud_download_outlined, l.sftp_download, p.fg, () {
                  _notifier?.downloadFile(file);
                }),
              _menuTile(ctx, Icons.link, l.sftp_copyPath, p.fg, () {
                Clipboard.setData(ClipboardData(text: file.path));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.sftp_pathCopied(file.path)), duration: const Duration(seconds: 2)),
                );
              }),
              if (file.permissions != null)
                _menuTile(ctx, Icons.lock_outlined, l.sftp_permissions, p.fg, () {
                  _showPermissions(file);
                }),
              Divider(height: 1, color: p.border),
              _menuTile(ctx, Icons.delete_outline, l.common_delete, p.statusError, () {
                _confirmDelete(file);
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onTap) {
    final theme = Theme.of(ctx);
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: theme.textTheme.titleMedium!.copyWith(color: color)),
      onTap: () { Navigator.pop(ctx); onTap(); },
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
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
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final state = _sftpState;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: p.fgTertiary, borderRadius: BorderRadius.circular(2)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(l.sftp_sortTitle, style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: p.border),
            _sortTile(ctx, l.sftp_sortByName, SortField.name, state, p),
            _sortTile(ctx, l.sftp_sortBySize, SortField.size, state, p),
            _sortTile(ctx, l.sftp_sortByDate, SortField.date, state, p),
            _sortTile(ctx, l.sftp_sortByType, SortField.type, state, p),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(BuildContext ctx, String label, SortField field, SftpState state, ThemePalette p) {
    final theme = Theme.of(ctx);
    final isActive = state.sortField == field;
    final arrow = isActive ? (state.sortAscending ? ' ↑' : ' ↓') : '';
    return ListTile(
      leading: Icon(Icons.sort, color: isActive ? p.accent : p.fgSecondary, size: 22),
      title: Text('$label$arrow', style: theme.textTheme.titleMedium!.copyWith(
        color: isActive ? p.accent : p.fg,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      )),
      onTap: () { Navigator.pop(ctx); _notifier?.setSort(field); },
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
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
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontFamily: AppFonts.mono),
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
      final p = Theme.of(context).extension<ThemePalette>()!;
      final l = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: p.statusError),
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
    final p = Theme.of(context).extension<ThemePalette>()!;
    final iconColor = p.fgSecondary;

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
                  icon: Icons.account_tree_outlined,
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
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        else
          Container(
            height: 36,
            alignment: Alignment.centerLeft,
            child: FileBreadcrumb(path: state.currentPath, rootPath: _homePath, onNavigate: notifier.navigateTo),
          ),
        DashedDivider(color: p.border.withValues(alpha: 0.4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
        // File list
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: p.statusError),
                          const SizedBox(height: 8),
                          Text(state.error!),
                          TextButton(onPressed: notifier.refresh, child: Text(l.common_retry)),
                        ],
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (_) {
                        _swipeController.closeAny();
                        return false;
                      },
                      child: FileListView(
                        files: _filteredFiles,
                        selectedPaths: state.selectedPaths,
                        onTap: _onFileTap,
                        onLongPress: _onLongPress,
                        onToggleSelect: (file) => notifier.toggleSelection(file.path),
                        onDelete: _confirmDelete,
                        swipeController: _swipeController,
                        hasMore: _searchQuery.isEmpty && state.hasMoreFiles,
                        onLoadMore: notifier.loadMore,
                      ),
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
