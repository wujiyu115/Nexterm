import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/sftp/providers/sftp_provider.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_breadcrumb.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_list_view.dart';
import 'package:nexterm/features/sftp/ui/widgets/permission_dialog.dart';
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

      // Listen to state changes and reflect them in widget state.
      notifier.addListener((state) {
        if (mounted) setState(() => _sftpState = state);
      }, fireImmediately: true);

      setState(() {
        _notifier = notifier;
        _isInitializing = false;
      });

      // Navigate to home directory.
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
  // Helpers
  // ---------------------------------------------------------------------------

  void _onFileTap(RemoteFileInfo file) {
    final notifier = _notifier;
    if (notifier == null) return;

    if (file.isDirectory) {
      notifier.navigateTo(file.path);
    } else {
      _showFileActionSheet(file);
    }
  }

  void _onLongPress(RemoteFileInfo file) {
    _notifier?.toggleSelection(file.path);
  }

  void _showFileActionSheet(RemoteFileInfo file) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.of(ctx).pop();
                _notifier?.downloadFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.push(
                  '/sftp/edit',
                  extra: {
                    'sessionId': widget.sessionId,
                    'path': file.path,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showRenameDialog(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Permissions'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final initial = file.permissions ?? 0x1A4;
                final result = await showPermissionDialog(
                  context,
                  initialPermissions: initial,
                );
                if (result != null) {
                  await _notifier?.chmod(file.path, result);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDelete(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(RemoteFileInfo file) {
    final controller = TextEditingController(text: file.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != file.name) {
                _notifier?.rename(file.path, newName);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(RemoteFileInfo file) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _notifier?.delete(file.path, isDirectory: file.isDirectory);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected() {
    final count = _sftpState.selectedPaths.length;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected'),
        content: Text('Delete $count item(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              _notifier?.deleteSelected();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _notifier?.createDirectory(name);
              }
            },
            child: const Text('Create'),
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
      return Scaffold(
        appBar: AppBar(title: const Text('SFTP')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to connect: $_initError'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = null;
                  });
                  _initialize();
                },
                child: const Text('Retry'),
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
    final isMultiSelect = state.isMultiSelectMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SFTP'),
        actions: isMultiSelect
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete selected',
                  onPressed: _confirmDeleteSelected,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear selection',
                  onPressed: notifier.clearSelection,
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    state.showHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  tooltip: state.showHidden
                      ? 'Hide hidden files'
                      : 'Show hidden files',
                  onPressed: notifier.toggleHidden,
                ),
                IconButton(
                  icon: const Icon(Icons.upload_outlined),
                  tooltip: 'Upload',
                  onPressed: notifier.uploadFiles,
                ),
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined),
                  tooltip: 'New folder',
                  onPressed: _showCreateFolderDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: notifier.refresh,
                ),
              ],
      ),
      body: Column(
        children: [
          // Breadcrumb navigation bar.
          Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: FileBreadcrumb(
              path: state.currentPath,
              onNavigate: notifier.navigateTo,
            ),
          ),
          const Divider(height: 1),

          // File listing.
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(state.error!),
                            TextButton(
                              onPressed: notifier.refresh,
                              child: const Text('Retry'),
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

          // Transfer progress bar.
          const TransferQueueBar(),
        ],
      ),
    );
  }
}
