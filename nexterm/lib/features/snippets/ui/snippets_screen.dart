import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';
import 'package:nexterm/features/snippets/ui/widgets/snippet_list_tile.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';
import 'package:nexterm/shared/widgets/section_label.dart';

class SnippetsScreen extends ConsumerWidget {
  const SnippetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final notifier = ref.read(snippetsNotifierProvider.notifier);
    final snippetsAsync = ref.watch(snippetsStreamProvider);

    return DecorativeBackground(
      showRidge: false,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.snippets_title),
        actions: [
          IconButton(
            tooltip: l.snippets_addTooltip,
            onPressed: () => context.push('/vaults/snippets/add'),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.accentDim,
              ),
              child: Icon(Icons.add, size: 16, color: p.accent),
            ),
          ),
        ],
      ),
      body: snippetsAsync.when(
        data: (snippets) => _buildContent(context, snippets, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      ),
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
          SectionLabel(title: l.snippets_favorites),
          ...favorites.map((s) => _buildTile(context, s, notifier)),
        ],
        ...groups.entries.expand((entry) => [
          SectionLabel(title: entry.key ?? l.snippets_ungrouped),
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
      onTap: () => context.push('/vaults/snippets/edit/${snippet.id}'),
      onEdit: () => context.push('/vaults/snippets/edit/${snippet.id}'),
      onToggleFavorite: () => notifier.toggleFavorite(snippet),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt_outlined, size: 64, color: p.fgTertiary),
          const SizedBox(height: 16),
          Text(l.snippets_noSnippets, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/vaults/snippets/add'),
            icon: const Icon(Icons.add),
            label: Text(l.snippets_add),
          ),
        ],
      ),
    );
  }
}

