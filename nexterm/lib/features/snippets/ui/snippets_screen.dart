import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';
import 'package:nexterm/features/snippets/ui/widgets/snippet_list_tile.dart';

class SnippetsScreen extends ConsumerWidget {
  const SnippetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(snippetsNotifierProvider.notifier);
    final snippetsAsync = ref.watch(snippetsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('代码片段'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加片段',
            onPressed: () => context.push('/snippets/add'),
          ),
        ],
      ),
      body: snippetsAsync.when(
        data: (snippets) => _buildContent(context, snippets, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('错误: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SnippetEntity> snippets, SnippetsNotifier notifier) {
    if (snippets.isEmpty) {
      return _buildEmptyState(context);
    }

    final favorites = snippets.where((s) => s.isFavorite).toList();
    final others = snippets.where((s) => !s.isFavorite).toList();

    final groups = <String?, List<SnippetEntity>>{};
    for (final snippet in others) {
      groups.putIfAbsent(snippet.group, () => []).add(snippet);
    }

    return ListView(
      children: [
        if (favorites.isNotEmpty) ...[
          _SectionHeader(title: '收藏'),
          ...favorites.map((s) => _buildTile(context, s, notifier)),
        ],
        ...groups.entries.expand((entry) => [
          _SectionHeader(title: entry.key ?? '未分组'),
          ...entry.value.map((s) => _buildTile(context, s, notifier)),
        ]),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTile(BuildContext context, SnippetEntity snippet, SnippetsNotifier notifier) {
    return SnippetListTile(
      key: ValueKey(snippet.id),
      snippet: snippet,
      onTap: () => context.push('/snippets/edit/${snippet.id}'),
      onEdit: () => context.push('/snippets/edit/${snippet.id}'),
      onToggleFavorite: () => notifier.toggleFavorite(snippet),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('暂无代码片段', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/snippets/add'),
            icon: const Icon(Icons.add),
            label: const Text('添加片段'),
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
