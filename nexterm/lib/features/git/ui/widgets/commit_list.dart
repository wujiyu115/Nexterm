import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class CommitList extends StatelessWidget {
  final List<GitCommit> commits;
  final void Function(GitCommit commit) onCommitTap;
  const CommitList(
      {super.key, required this.commits, required this.onCommitTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (commits.isEmpty) return Center(child: Text(l.git_noCommits));
    return ListView.separated(
      itemCount: commits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final commit = commits[index];
        return _CommitRow(commit: commit, onTap: () => onCommitTap(commit));
      },
    );
  }
}

class _CommitRow extends StatelessWidget {
  final GitCommit commit;
  final VoidCallback onTap;
  const _CommitRow({required this.commit, required this.onTap});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().toUtc().difference(dt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      title: Text(commit.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge!.copyWith(
              color: p.fg)),
      subtitle: Row(children: [
        Text(commit.shortSha,
            style: theme.textTheme.bodySmall!.copyWith(
                fontFamily: AppFonts.mono,
                color: p.accent)),
        const SizedBox(width: 8),
        Text(commit.authorName,
            style: theme.textTheme.bodySmall!.copyWith(
                color: p.fgSecondary)),
        const Spacer(),
        Text(_timeAgo(commit.timestamp),
            style: theme.textTheme.labelSmall!.copyWith(
                color: p.fgTertiary)),
      ]),
    );
  }
}
