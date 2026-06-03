import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/git/models/git_status.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class StatusFileList extends StatelessWidget {
  final GitStatus status;
  final void Function(GitStatusEntry entry, bool staged) onFileTap;
  const StatusFileList({super.key, required this.status, required this.onFileTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    if (!status.isDirty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_outline, size: 48, color: p.fgTertiary),
        const SizedBox(height: 12),
        Text(l.git_noChanges, style: TextStyle(color: p.fgSecondary)),
      ]));
    }
    return ListView(children: [
      if (status.staged.isNotEmpty) ...[
        _SectionHeader(title: l.git_staged, count: status.staged.length),
        ...status.staged.map((e) => _FileRow(entry: e, staged: true, onTap: () => onFileTap(e, true))),
      ],
      if (status.unstaged.isNotEmpty) ...[
        _SectionHeader(title: l.git_unstaged, count: status.unstaged.length),
        ...status.unstaged.map((e) => _FileRow(entry: e, staged: false, onTap: () => onFileTap(e, false))),
      ],
      if (status.untracked.isNotEmpty) ...[
        _SectionHeader(title: l.git_untracked, count: status.untracked.length),
        ...status.untracked.map((e) => _FileRow(entry: e, staged: false, onTap: () => onFileTap(e, false))),
      ],
    ]);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: p.fgSecondary)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: p.fgTertiary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8)),
          child: Text('$count', style: TextStyle(fontSize: 11,
              color: p.fgSecondary)),
        ),
      ]),
    );
  }
}

class _FileRow extends StatelessWidget {
  final GitStatusEntry entry;
  final bool staged;
  final VoidCallback onTap;
  const _FileRow({required this.entry, required this.staged, required this.onTap});

  IconData _statusIcon(FileStatusCode code) => switch (code) {
    FileStatusCode.modified => Icons.edit_outlined,
    FileStatusCode.added => Icons.add_circle_outline,
    FileStatusCode.deleted => Icons.remove_circle_outline,
    FileStatusCode.renamed => Icons.drive_file_rename_outline,
    FileStatusCode.untracked => Icons.help_outline,
    _ => Icons.circle_outlined,
  };

  Color _statusColor(FileStatusCode code) => switch (code) {
    FileStatusCode.modified => const Color(0xFFE5A84B),
    FileStatusCode.added => const Color(0xFF6BCB77),
    FileStatusCode.deleted => const Color(0xFFE06C75),
    FileStatusCode.renamed => const Color(0xFF4A9EEA),
    FileStatusCode.untracked => const Color(0xFF888888),
    _ => const Color(0xFF888888),
  };

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final code = staged ? entry.indexStatus : entry.workTreeStatus;
    final fileName = entry.path.split('/').last;
    final dirPath = entry.path.contains('/') ? entry.path.substring(0, entry.path.lastIndexOf('/')) : '';
    return ListTile(
      dense: true, visualDensity: VisualDensity.compact,
      leading: Icon(_statusIcon(code), size: 18, color: _statusColor(code)),
      title: Text(fileName, style: TextStyle(fontSize: 14, color: p.fg), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: dirPath.isNotEmpty ? Text(dirPath, style: TextStyle(fontSize: 11, color: p.fgTertiary), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
      onTap: onTap,
    );
  }
}
