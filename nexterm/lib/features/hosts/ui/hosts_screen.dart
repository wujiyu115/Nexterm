import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_context_menu.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_list_tile.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_search_bar.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';

class HostsScreen extends ConsumerStatefulWidget {
  const HostsScreen({super.key});

  @override
  ConsumerState<HostsScreen> createState() => _HostsScreenState();
}

class _HostsScreenState extends ConsumerState<HostsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Selection mode helpers
  // ---------------------------------------------------------------------------

  void _enterSelectionMode(String hostId) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(hostId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String hostId) {
    setState(() {
      if (_selectedIds.contains(hostId)) {
        _selectedIds.remove(hostId);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(hostId);
      }
    });
  }

  void _selectAll(List<HostEntity> hosts) {
    setState(() {
      _selectedIds.addAll(hosts.map((h) => h.id));
    });
  }

  // ---------------------------------------------------------------------------
  // Context menu handler
  // ---------------------------------------------------------------------------

  Future<void> _showContextMenu(HostEntity host) async {
    final action = await showHostContextMenu(context: context, host: host);
    if (action == null || !mounted) return;

    final notifier = ref.read(hostsNotifierProvider.notifier);

    switch (action) {
      case HostContextAction.connect:
        context.push('/terminal/connect/${host.id}');
      case HostContextAction.sftpConnect:
        _connectSftp(host);
      case HostContextAction.duplicate:
        await notifier.duplicateHost(host.id);
      case HostContextAction.moveToGroup:
        await _showMoveToGroupDialog([host.id]);
      case HostContextAction.edit:
        context.push('/hosts/edit/${host.id}');
      case HostContextAction.select:
        _enterSelectionMode(host.id);
      case HostContextAction.delete:
        await _confirmDelete([host.id]);
    }
  }

  Future<void> _connectSftp(HostEntity host) async {
    final sessionId = await ref
        .read(terminalActionsProvider)
        .connectHost(host.id);
    if (!mounted) return;
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SSH 连接失败，无法打开 SFTP')),
      );
      return;
    }
    context.push('/sftp/$sessionId');
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _showMoveToGroupDialog(List<String> hostIds) async {
    final hostsAsync = ref.read(hostsStreamProvider);
    final allHosts = hostsAsync.valueOrNull ?? [];

    // Collect existing group names.
    final existingGroups = allHosts
        .map((h) => h.group)
        .where((g) => g != null && g.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final newGroupController = TextEditingController();

    final selected = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移动到组'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (existingGroups.isNotEmpty) ...[
              ...existingGroups.map((g) => ListTile(
                    title: Text(g!),
                    onTap: () => Navigator.pop(ctx, g),
                  )),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('未分组'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            const Divider(),
            TextField(
              controller: newGroupController,
              decoration: const InputDecoration(
                labelText: '新建分组',
                hintText: '输入分组名称',
              ),
              onSubmitted: (value) => Navigator.pop(ctx, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, newGroupController.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (selected == null || !mounted) return;

    final notifier = ref.read(hostsNotifierProvider.notifier);
    final group = selected.isEmpty ? null : selected;

    if (hostIds.length == 1) {
      await notifier.moveToGroup(hostIds.first, group);
    } else {
      await notifier.moveMultipleToGroup(hostIds, group);
    }

    if (_isSelectionMode) _exitSelectionMode();
  }

  Future<void> _confirmDelete(List<String> ids) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: Text(ids.length == 1 ? '确定要删除此主机吗？' : '确定要删除选中的 ${ids.length} 台主机吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final notifier = ref.read(hostsNotifierProvider.notifier);
    if (ids.length == 1) {
      await notifier.deleteHost(ids.first);
    } else {
      await notifier.deleteMultiple(ids);
    }

    if (_isSelectionMode) _exitSelectionMode();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(hostsNotifierProvider.notifier);

    Widget buildContent() {
      if (_searchQuery.isNotEmpty) {
        final searchAsync = ref.watch(hostSearchProvider(_searchQuery));
        return searchAsync.when(
          data: (hosts) => _buildHostList(hosts, notifier),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('错误: $e')),
        );
      }

      final hostsAsync = ref.watch(hostsStreamProvider);
      return hostsAsync.when(
        data: (hosts) => _buildHostList(hosts, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
      );
    }

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text('已选择 ${_selectedIds.length} 项'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: '全选',
                  onPressed: () {
                    final hostsAsync = ref.read(hostsStreamProvider);
                    final allHosts = hostsAsync.valueOrNull ?? [];
                    _selectAll(allHosts);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.drive_file_move_outline),
                  tooltip: '移动到组',
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _showMoveToGroupDialog(_selectedIds.toList()),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除',
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _confirmDelete(_selectedIds.toList()),
                ),
              ],
            )
          : AppBar(
              title: const Text('主机'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: '添加主机',
                  onPressed: () => context.push('/hosts/add'),
                ),
              ],
            ),
      body: Column(
        children: [
          HostSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          Expanded(child: buildContent()),
        ],
      ),
    );
  }

  Widget _buildHostList(List<HostEntity> hosts, HostsNotifier notifier) {
    if (hosts.isEmpty) {
      return _buildEmptyState();
    }

    final favorites = hosts.where((h) => h.isFavorite).toList();
    final others = hosts.where((h) => !h.isFavorite).toList();

    // Group non-favorites by group name
    final groups = <String?, List<HostEntity>>{};
    for (final host in others) {
      groups.putIfAbsent(host.group, () => []).add(host);
    }

    return ListView(
      children: [
        if (favorites.isNotEmpty) ...[
          _SectionHeader(title: '收藏'),
          ...favorites.map((host) => _buildTile(host, notifier)),
        ],
        ...groups.entries.expand((entry) => [
          _SectionHeader(title: entry.key ?? '未分组'),
          ...entry.value.map((host) => _buildTile(host, notifier)),
        ]),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTile(HostEntity host, HostsNotifier notifier) {
    return HostListTile(
      key: ValueKey(host.id),
      host: host,
      onTap: () => context.push('/terminal/connect/${host.id}'),
      onLongPress: () => _showContextMenu(host),
      onToggleFavorite: () => notifier.toggleFavorite(host),
      isSelectionMode: _isSelectionMode,
      isSelected: _selectedIds.contains(host.id),
      onSelectionToggle: () => _toggleSelection(host.id),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dns_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('暂无主机', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/hosts/add'),
            icon: const Icon(Icons.add),
            label: const Text('添加主机'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
