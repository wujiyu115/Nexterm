import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/features/git/models/git_diff.dart';
import 'package:nexterm/features/git/providers/git_provider.dart';
import 'package:nexterm/features/git/services/git_command_service.dart';
import 'package:nexterm/features/git/ui/widgets/diff_view.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class CommitDetailSheet extends StatefulWidget {
  final GitCommit commit;
  final GitNotifier gitNotifier;
  const CommitDetailSheet(
      {super.key, required this.commit, required this.gitNotifier});

  @override
  State<CommitDetailSheet> createState() => _CommitDetailSheetState();
}

class _CommitDetailSheetState extends State<CommitDetailSheet> {
  List<CommitFileChange>? _files;
  List<GitFileDiff>? _diffs;
  bool _isLoading = true;
  bool _showDiff = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final files = await widget.gitNotifier.getCommitFiles(widget.commit.sha);
      if (mounted) {
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openFileDiff(CommitFileChange file) async {
    final diffs = await widget.gitNotifier.getCommitFileDiff(widget.commit.sha, file.path);
    if (!mounted) return;
    final nav = Navigator.of(context, rootNavigator: true);
    nav.pop();
    nav.push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(file.path.split('/').last)),
        body: DiffView(diffs: diffs),
      ),
    ));
  }

  Future<void> _loadDiffs() async {
    setState(() {
      _isLoading = true;
      _showDiff = true;
    });
    try {
      final diffs =
          await widget.gitNotifier.getCommitDiff(widget.commit.sha);
      if (mounted) {
        setState(() {
          _diffs = diffs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commit = widget.commit;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.4, 0.7],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Material(
            color: isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg,
            child: ListView(controller: scrollController, children: [
            Center(
                child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: isDark
                            ? OutdoorColors.darkFgTertiary
                            : OutdoorColors.lightFgTertiary,
                        borderRadius: BorderRadius.circular(2)))),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.git_commitDetail,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? OutdoorColors.darkFg
                            : OutdoorColors.lightFg))),
            const SizedBox(height: 12),
            _DetailRow(
                label: 'SHA',
                value: commit.shortSha,
                onTap: () =>
                    Clipboard.setData(ClipboardData(text: commit.sha))),
            _DetailRow(
                label: l.git_author,
                value: '${commit.authorName} <${commit.authorEmail}>'),
            _DetailRow(
                label: l.git_date,
                value: _formatDate(commit.timestamp)),
            const Divider(height: 24),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.git_message,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? OutdoorColors.darkFgSecondary
                            : OutdoorColors.lightFgSecondary))),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(commit.subject,
                    style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? OutdoorColors.darkFg
                            : OutdoorColors.lightFg))),
            if (commit.body.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(commit.body,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? OutdoorColors.darkFgSecondary
                              : OutdoorColors.lightFgSecondary))),
            const Divider(height: 24),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Text(l.git_changedFiles,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? OutdoorColors.darkFgSecondary
                              : OutdoorColors.lightFgSecondary)),
                  const Spacer(),
                  if (!_showDiff)
                    TextButton(
                        onPressed: _loadDiffs,
                        child: Text(l.git_diff)),
                ])),
            if (_isLoading)
              const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()))
            else if (_showDiff && _diffs != null)
              ..._diffs!.map((d) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FileDiffView(diff: d)))
            else if (_files != null)
              ...(_files!.map((f) => ListTile(
                  dense: true,
                  leading: _statusIcon(f.status),
                  title: Text(f.path,
                      style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'JetBrains Mono')),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => _openFileDiff(f)))),
            const SizedBox(height: 32),
          ]),
        ));
      },
    );
  }

  Widget _statusIcon(String status) {
    final (icon, color) = switch (status) {
      'A' => (Icons.add_circle_outline, const Color(0xFF6BCB77)),
      'D' => (Icons.remove_circle_outline, const Color(0xFFE06C75)),
      'M' => (Icons.edit_outlined, const Color(0xFFE5A84B)),
      _ when status.startsWith('R') => (
        Icons.drive_file_rename_outline,
        const Color(0xFF4A9EEA)
      ),
      _ => (Icons.circle_outlined, const Color(0xFF888888)),
    };
    return Icon(icon, size: 18, color: color);
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _DetailRow({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            SizedBox(
                width: 60,
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? OutdoorColors.darkFgTertiary
                            : OutdoorColors.lightFgTertiary))),
            Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'JetBrains Mono',
                        color: isDark
                            ? OutdoorColors.darkFg
                            : OutdoorColors.lightFg))),
          ]),
        ));
  }
}
