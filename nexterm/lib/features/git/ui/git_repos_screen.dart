import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/features/git/providers/git_repos_provider.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GitReposScreen extends ConsumerWidget {
  const GitReposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final reposAsync = ref.watch(gitReposStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.git_repos), actions: [
        IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/vaults/git/add')),
      ]),
      body: reposAsync.when(
        data: (repos) {
          if (repos.isEmpty) return Center(child: Text(l.git_reposEmpty));
          return ListView.separated(
            itemCount: repos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _RepoTile(repo: repos[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _RepoTile extends ConsumerWidget {
  final GitRepoEntity repo;
  const _RepoTile({required this.repo});

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.git_connecting)));
    try {
      final sessionId =
          await ref.read(terminalActionsProvider).connectHost(repo.hostId);
      if (sessionId != null && context.mounted) {
        context.push(
            '/git/$sessionId?path=${Uri.encodeComponent(repo.remotePath)}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.common_error(e.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hostAsync = ref.watch(hostByIdProvider(repo.hostId));
    return ListTile(
      leading: Icon(Icons.source_outlined,
          size: 24,
          color: isDark
              ? OutdoorColors.darkFgSecondary
              : OutdoorColors.lightFgSecondary),
      title: Text(repo.displayName),
      subtitle: hostAsync.when(
        data: (host) => Text(
            host != null
                ? '${host.name} · ${repo.remotePath}'
                : repo.remotePath,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? OutdoorColors.darkFgTertiary
                    : OutdoorColors.lightFgTertiary)),
        loading: () => Text(repo.remotePath),
        error: (_, __) => Text(repo.remotePath),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () => _connect(context, ref),
    );
  }
}
