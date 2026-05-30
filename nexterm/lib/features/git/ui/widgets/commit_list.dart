import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
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
      separatorBuilder: (_, __) => const Divider(height: 1),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      title: Text(commit.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 14,
              color:
                  isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg)),
      subtitle: Row(children: [
        Text(commit.shortSha,
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
                color: OutdoorColors.accent)),
        const SizedBox(width: 8),
        Text(commit.authorName,
            style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? OutdoorColors.darkFgSecondary
                    : OutdoorColors.lightFgSecondary)),
        const Spacer(),
        Text(_timeAgo(commit.timestamp),
            style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? OutdoorColors.darkFgTertiary
                    : OutdoorColors.lightFgTertiary)),
      ]),
    );
  }
}
