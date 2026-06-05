import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/features/git/providers/git_repos_provider.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';
import 'package:nexterm/shared/widgets/outdoor_search_bar.dart';
import 'package:nexterm/shared/widgets/swipe_delete_glass_card.dart';
import 'package:nexterm/shared/widgets/swipe_to_delete_wrapper.dart';

class GitReposScreen extends ConsumerStatefulWidget {
  const GitReposScreen({super.key});

  @override
  ConsumerState<GitReposScreen> createState() => _GitReposScreenState();
}

class _GitReposScreenState extends ConsumerState<GitReposScreen> {
  final _searchController = TextEditingController();
  final _swipeController = SwipeToDeleteController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(GitRepoEntity repo) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.git_deleteRepo),
        content: Text(l.git_deleteRepoConfirm(repo.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.common_delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(gitRepoRepositoryProvider).delete(repo.id);
    }
  }

  Future<void> _connect(GitRepoEntity repo) async {
    final l = AppLocalizations.of(context)!;
    final actions = ref.read(terminalActionsProvider);

    // Try to reuse an existing active SSH session for this host.
    var sessionId = actions.findActiveSessionForHost(repo.hostId);

    if (sessionId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.git_connecting)));
      try {
        sessionId = await actions.connectHost(repo.hostId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l.common_error(e.toString()))));
        }
        return;
      }
    }

    if (sessionId != null && mounted) {
      context.push(
          '/git/$sessionId?path=${Uri.encodeComponent(repo.remotePath)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;

    Widget buildContent() {
      if (_searchQuery.isNotEmpty) {
        final searchAsync = ref.watch(gitRepoSearchProvider(_searchQuery));
        return searchAsync.when(
          data: (repos) => _buildList(repos),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
        );
      }

      final reposAsync = ref.watch(gitReposStreamProvider);
      return reposAsync.when(
        data: (repos) => _buildList(repos),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      );
    }

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
          title: Text(l.git_repos),
          actions: [
            IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.accentDim),
                child: Icon(Icons.add, size: 16, color: p.accent),
              ),
              tooltip: l.git_addRepo,
              onPressed: () => context.push('/vaults/git/add'),
            ),
          ],
        ),
        body: Column(
          children: [
            OutdoorSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              hintText: l.git_search,
            ),
            Expanded(child: buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<GitRepoEntity> repos) {
    if (repos.isEmpty) {
      return _buildEmptyState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _swipeController.closeAny();
        return false;
      },
      child: ListView(
        children: [
          ...repos.map((repo) => _buildTile(repo)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTile(GitRepoEntity repo) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final hostAsync = ref.watch(hostByIdProvider(repo.hostId));

    return SwipeDeleteGlassCard(
      swipeController: _swipeController,
      onTap: () => _connect(repo),
      onDelete: () => _confirmDelete(repo),
      child: Row(
        children: [
          Icon(Icons.account_tree_outlined, size: 24, color: p.fgSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  repo.displayName,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                hostAsync.when(
                  data: (host) => Text(
                    host != null
                        ? '${host.name} · ${repo.remotePath}'
                        : repo.remotePath,
                    style: theme.textTheme.bodyMedium!.copyWith(color: p.fgSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => Text(
                    repo.remotePath,
                    style: theme.textTheme.bodyMedium!.copyWith(color: p.fgSecondary),
                  ),
                  error: (_, __) => Text(
                    repo.remotePath,
                    style: theme.textTheme.bodyMedium!.copyWith(color: p.fgSecondary),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: p.fgTertiary),
            onPressed: () => context.push('/vaults/git/edit/${repo.id}'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 64, color: p.fgTertiary),
          const SizedBox(height: 16),
          Text(l.git_reposEmpty, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/vaults/git/add'),
            icon: const Icon(Icons.add),
            label: Text(l.git_addRepo),
          ),
        ],
      ),
    );
  }
}
