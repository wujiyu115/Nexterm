import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                const SnackBar(
                  content: Text('已复制，前往目标文件夹粘贴'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.doc_on_doc, size: 20),
                SizedBox(width: 8),
                Text('复制'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _showRenameDialog(file);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.pencil, size: 20),
                SizedBox(width: 8),
                Text('重命名'),
              ],
            ),
          ),
          if (!file.isDirectory)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _notifier?.downloadFile(file);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.cloud_download, size: 20),
                  SizedBox(width: 8),
                  Text('下载'),
                ],
              ),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              Clipboard.setData(ClipboardData(text: file.path));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已复制路径: ${file.path}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.link, size: 20),
                SizedBox(width: 8),
                Text('复制路径'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDelete(file);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.trash, size: 20, color: CupertinoColors.destructiveRed),
                SizedBox(width: 8),
                Text('删除'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
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
    final state = _sftpState;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('排序方式'),
        actions: [
          _sortAction(ctx, '按名称', SortField.name, state),
          _sortAction(ctx, '按大小', SortField.size, state),
          _sortAction(ctx, '按日期', SortField.date, state),
          _sortAction(ctx, '按类型', SortField.type, state),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
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
    final controller = TextEditingController(text: file.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '新名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != file.name) {
                _notifier?.rename(file.path, newName);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(RemoteFileInfo file) {
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${file.name}" 吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              _notifier?.delete(file.path, isDirectory: file.isDirectory);
            },
            child: const Text('删除'),
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
        title: const Text('新建文件夹'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '文件夹名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _notifier?.createDirectory(name);
              }
            },
            child: const Text('确定'),
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
              Text('连接失败: $_initError'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = null;
                  });
                  _initialize();
                },
                child: const Text('重试'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('SFTP'),
        actions: [
          if (state.hasCopiedFiles)
            IconButton(
              icon: const Icon(Icons.paste),
              tooltip: '粘贴',
              onPressed: notifier.pasteFiles,
            ),
          IconButton(
            icon: Icon(
              state.showHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            tooltip: state.showHidden ? '隐藏隐藏文件' : '显示隐藏文件',
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
              const PopupMenuItem(
                value: 'upload',
                child: ListTile(
                  leading: Icon(Icons.upload_outlined),
                  title: Text('上传'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem(
                value: 'newFolder',
                child: ListTile(
                  leading: Icon(Icons.create_new_folder_outlined),
                  title: Text('新建文件夹'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: ListTile(
                  leading: Icon(Icons.sort),
                  title: Text('排序'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('刷新'),
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
                              child: const Text('重试'),
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
