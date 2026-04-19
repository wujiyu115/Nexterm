import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_list_tile.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_search_bar.dart';

class HostsScreen extends ConsumerStatefulWidget {
  const HostsScreen({super.key});

  @override
  ConsumerState<HostsScreen> createState() => _HostsScreenState();
}

class _HostsScreenState extends ConsumerState<HostsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
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
      onEdit: () => context.push('/hosts/edit/${host.id}'),
      onToggleFavorite: () => notifier.toggleFavorite(host),
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
