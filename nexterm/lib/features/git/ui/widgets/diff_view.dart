import 'package:flutter/material.dart';
import 'package:nexterm/features/git/models/git_diff.dart';

class DiffView extends StatelessWidget {
  final List<GitFileDiff> diffs;
  const DiffView({super.key, required this.diffs});

  @override
  Widget build(BuildContext context) {
    if (diffs.isEmpty) return const Center(child: Text('No changes'));
    return ListView.builder(
      itemCount: diffs.length,
      itemBuilder: (context, index) => _FileDiffSection(diff: diffs[index]),
    );
  }
}

class FileDiffView extends StatelessWidget {
  final GitFileDiff diff;
  const FileDiffView({super.key, required this.diff});
  @override
  Widget build(BuildContext context) => _FileDiffSection(diff: diff);
}

class _FileDiffSection extends StatelessWidget {
  final GitFileDiff diff;
  const _FileDiffSection({required this.diff});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF2D333B) : const Color(0xFFF6F8FA);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: headerBg,
        child: Row(children: [
          Expanded(child: Text(diff.filePath, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'JetBrains Mono', color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text('+${diff.additions}', style: const TextStyle(fontSize: 12, color: Color(0xFF6BCB77))),
          const SizedBox(width: 4),
          Text('-${diff.deletions}', style: const TextStyle(fontSize: 12, color: Color(0xFFE06C75))),
        ]),
      ),
      for (final hunk in diff.hunks) _HunkView(hunk: hunk),
      const SizedBox(height: 8),
    ]);
  }
}

class _HunkView extends StatelessWidget {
  final DiffHunk hunk;
  const _HunkView({required this.hunk});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hunkHeaderBg = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDF4FF);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: hunkHeaderBg,
        child: Text(
          '@@ -${hunk.oldStart},${hunk.oldCount} +${hunk.newStart},${hunk.newCount} @@${hunk.header != null ? ' ${hunk.header}' : ''}',
          style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', color: isDark ? const Color(0xFF79C0FF) : const Color(0xFF0550AE)),
        ),
      ),
      for (final line in hunk.lines) _DiffLineView(line: line),
    ]);
  }
}

class _DiffLineView extends StatelessWidget {
  final DiffLine line;
  const _DiffLineView({required this.line});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor;
    Color? gutterColor;
    String prefix;
    switch (line.type) {
      case DiffLineType.added:
        bgColor = isDark ? const Color(0xFF1A2F23) : const Color(0xFFE6FFEC);
        gutterColor = isDark ? const Color(0xFF1A3A29) : const Color(0xFFCCFBD5);
        prefix = '+';
      case DiffLineType.deleted:
        bgColor = isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFEBE9);
        gutterColor = isDark ? const Color(0xFF4A2020) : const Color(0xFFFCD5D3);
        prefix = '-';
      case DiffLineType.context:
        bgColor = Colors.transparent;
        gutterColor = null;
        prefix = ' ';
    }
    final lineNum = line.type == DiffLineType.deleted
        ? line.oldLineNumber?.toString() ?? ''
        : line.type == DiffLineType.added
            ? line.newLineNumber?.toString() ?? ''
            : '${line.oldLineNumber ?? ''}';

    return Container(color: bgColor, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 50, padding: const EdgeInsets.symmetric(horizontal: 4), color: gutterColor,
        child: Text(lineNum, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', color: isDark ? const Color(0xFF484F58) : const Color(0xFF8C959F))),
      ),
      SizedBox(width: 16, child: Text(prefix, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', color: isDark ? const Color(0xFF7D8590) : const Color(0xFF57606A)))),
      Expanded(
        child: line.inlineChanges.isEmpty
            ? Text(line.content, style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328)))
            : _buildInlineHighlightedText(context, line),
      ),
    ]));
  }

  Widget _buildInlineHighlightedText(BuildContext context, DiffLine line) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328);
    Color highlightBg;
    if (line.type == DiffLineType.added) {
      highlightBg = isDark ? const Color(0x662EA043) : const Color(0xFFACEEBB);
    } else {
      highlightBg = isDark ? const Color(0x66DA3638) : const Color(0xFFFFCECB);
    }
    final spans = <TextSpan>[];
    var pos = 0;
    for (final change in line.inlineChanges) {
      if (change.start > pos) spans.add(TextSpan(text: line.content.substring(pos, change.start)));
      final end = change.start + change.length;
      spans.add(TextSpan(text: line.content.substring(change.start, end.clamp(0, line.content.length)), style: TextStyle(backgroundColor: highlightBg)));
      pos = end;
    }
    if (pos < line.content.length) spans.add(TextSpan(text: line.content.substring(pos)));
    return RichText(text: TextSpan(style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', color: normalColor), children: spans));
  }
}
