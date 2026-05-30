import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/shared/widgets/section_label.dart';
import 'package:nexterm/shared/widgets/outdoor_search_bar.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_context_menu.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_list_tile.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';

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
        context.push('/vaults/hosts/edit/${host.id}');
      case HostContextAction.select:
        _enterSelectionMode(host.id);
      case HostContextAction.delete:
        await _confirmDelete([host.id]);
    }
  }

  Future<void> _connectSftp(HostEntity host) async {
    final l = AppLocalizations.of(context)!;
    final sessionId = await ref
        .read(terminalActionsProvider)
        .connectHost(host.id);
    if (!mounted) return;
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.hosts_sftpConnectFailed)),
      );
      return;
    }
    context.push('/sftp/$sessionId');
  }

  Future<void> _showMoveToGroupDialog(List<String> hostIds) async {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.read(hostsStreamProvider);
    final allHosts = hostsAsync.valueOrNull ?? [];

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
        title: Text(l.hosts_moveToGroup),
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
              title: Text(l.hosts_ungrouped),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            const Divider(),
            TextField(
              controller: newGroupController,
              decoration: InputDecoration(
                labelText: l.hosts_newGroup,
                hintText: l.hosts_newGroupHint,
              ),
              onSubmitted: (value) => Navigator.pop(ctx, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, newGroupController.text),
            child: Text(l.common_confirm),
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
    final l = AppLocalizations.of(context)!;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.hosts_deleteConfirm),
        content: Text(ids.length == 1 ? l.hosts_deleteConfirmSingle : l.hosts_deleteConfirmMultiple(ids.length)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.common_delete),
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final notifier = ref.read(hostsNotifierProvider.notifier);

    Widget buildContent() {
      if (_searchQuery.isNotEmpty) {
        final searchAsync = ref.watch(hostSearchProvider(_searchQuery));
        return searchAsync.when(
          data: (hosts) => _buildHostList(hosts, notifier),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
        );
      }

      final hostsAsync = ref.watch(hostsStreamProvider);
      return hostsAsync.when(
        data: (hosts) => _buildHostList(hosts, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      );
    }

    return DecorativeBackground(
      showRidge: false,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              ),
              title: Text(l.hosts_selectedCount(_selectedIds.length)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: l.hosts_selectAll,
                  onPressed: () {
                    final hostsAsync = ref.read(hostsStreamProvider);
                    final allHosts = hostsAsync.valueOrNull ?? [];
                    _selectAll(allHosts);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.drive_file_move_outline),
                  tooltip: l.hosts_moveToGroup,
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _showMoveToGroupDialog(_selectedIds.toList()),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l.hosts_deleteTooltip,
                  onPressed: _selectedIds.isEmpty
                      ? null
                      : () => _confirmDelete(_selectedIds.toList()),
                ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(l.hosts_title),
              actions: [
                IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: OutdoorColors.accentDim),
                    child: const Icon(Icons.add, size: 16, color: OutdoorColors.accent),
                  ),
                  tooltip: l.hosts_addTooltip,
                  onPressed: () => context.push('/vaults/hosts/add'),
                ),
              ],
            ),
      body: Column(
        children: [
          OutdoorSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            hintText: l.hosts_search,
          ),
          Expanded(child: buildContent()),
        ],
      ),
    ),
    );
  }

  Widget _buildHostList(List<HostEntity> hosts, HostsNotifier notifier) {
    if (hosts.isEmpty) {
      return _buildEmptyState();
    }

    final l = AppLocalizations.of(context)!;
    final favorites = hosts.where((h) => h.isFavorite).toList();
    final others = hosts.where((h) => !h.isFavorite).toList();

    final groups = <String?, List<HostEntity>>{};
    for (final host in others) {
      groups.putIfAbsent(host.group, () => []).add(host);
    }

    // Compute active connection counts per hostId from the tab manager.
    final tabManager = ref.watch(tabManagerProvider);
    final activeCounts = <String, int>{};
    for (final tab in tabManager.tabs) {
      activeCounts[tab.hostId] = (activeCounts[tab.hostId] ?? 0) + 1;
    }

    return ListView(
      children: [
        if (favorites.isNotEmpty) ...[
          SectionLabel(title: l.hosts_favorites, padding: const EdgeInsets.fromLTRB(16, 12, 16, 4)),
          ...favorites
              .map((host) => _buildTile(host, notifier, activeCounts)),
        ],
        ...groups.entries.expand((entry) => [
          SectionLabel(title: entry.key ?? l.hosts_ungrouped, padding: const EdgeInsets.fromLTRB(16, 12, 16, 4)),
          ...entry.value
              .map((host) => _buildTile(host, notifier, activeCounts)),
        ]),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTile(
    HostEntity host,
    HostsNotifier notifier,
    Map<String, int> activeCounts,
  ) {
    return HostListTile(
      key: ValueKey(host.id),
      host: host,
      onTap: () => context.push('/terminal/connect/${host.id}'),
      onLongPress: () => _showContextMenu(host),
      onToggleFavorite: () => notifier.toggleFavorite(host),
      isSelectionMode: _isSelectionMode,
      isSelected: _selectedIds.contains(host.id),
      onSelectionToggle: () => _toggleSelection(host.id),
      activeConnectionCount: activeCounts[host.id] ?? 0,
    );
  }

  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dns_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(l.hosts_noHosts, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/vaults/hosts/add'),
            icon: const Icon(Icons.add),
            label: Text(l.hosts_add),
          ),
        ],
      ),
    );
  }
}

