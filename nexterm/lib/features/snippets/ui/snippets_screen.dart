import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';
import 'package:nexterm/features/snippets/ui/widgets/snippet_list_tile.dart';

class SnippetsScreen extends ConsumerWidget {
  const SnippetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final notifier = ref.read(snippetsNotifierProvider.notifier);
    final snippetsAsync = ref.watch(snippetsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.snippets_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l.snippets_addTooltip,
            onPressed: () => context.push('/snippets/add'),
          ),
        ],
      ),
      body: snippetsAsync.when(
        data: (snippets) => _buildContent(context, snippets, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SnippetEntity> snippets, SnippetsNotifier notifier) {
    if (snippets.isEmpty) {
      return _buildEmptyState(context);
    }

    final l = AppLocalizations.of(context)!;
    final favorites = snippets.where((s) => s.isFavorite).toList();
    final others = snippets.where((s) => !s.isFavorite).toList();

    final groups = <String?, List<SnippetEntity>>{};
    for (final snippet in others) {
      groups.putIfAbsent(snippet.group, () => []).add(snippet);
    }

    return ListView(
      children: [
        if (favorites.isNotEmpty) ...[
          _SectionHeader(title: l.snippets_favorites),
          ...favorites.map((s) => _buildTile(context, s, notifier)),
        ],
        ...groups.entries.expand((entry) => [
          _SectionHeader(title: entry.key ?? l.snippets_ungrouped),
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
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(l.snippets_noSnippets, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/snippets/add'),
            icon: const Icon(Icons.add),
            label: Text(l.snippets_add),
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
