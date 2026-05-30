import 'dart:math';
import 'package:nexterm/features/git/models/git_diff.dart';

class DiffParser {
  static List<GitFileDiff> parse(String rawDiff) {
    final fileDiffs = <GitFileDiff>[];
    final fileChunks = rawDiff.split(RegExp(r'^diff --git ', multiLine: true));
    for (final chunk in fileChunks) {
      if (chunk.trim().isEmpty) continue;
      fileDiffs.add(_parseFileDiff(chunk));
    }
    return fileDiffs;
  }

  static GitFileDiff _parseFileDiff(String chunk) {
    final lines = chunk.split('\n');
    final headerMatch = RegExp(r'^a/(.+?) b/(.+)$').firstMatch(lines[0]);
    final oldPath = headerMatch?.group(1) ?? '';
    final newPath = headerMatch?.group(2) ?? oldPath;
    var isNew = false;
    var isDeleted = false;
    var isRenamed = oldPath != newPath;
    for (final line in lines) {
      if (line.startsWith('new file mode')) isNew = true;
      if (line.startsWith('deleted file mode')) isDeleted = true;
      if (line.startsWith('rename from')) isRenamed = true;
    }
    final hunks = _parseHunks(lines);
    final processedHunks = hunks.map(_computeInlineChanges).toList();
    return GitFileDiff(
      filePath: newPath,
      oldPath: isRenamed ? oldPath : null,
      isNew: isNew,
      isDeleted: isDeleted,
      isRenamed: isRenamed,
      hunks: processedHunks,
    );
  }

  static List<DiffHunk> _parseHunks(List<String> lines) {
    final hunks = <DiffHunk>[];
    DiffHunk? current;
    var oldLine = 0;
    var newLine = 0;
    for (final line in lines) {
      final hunkMatch = RegExp(
              r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)$')
          .firstMatch(line);
      if (hunkMatch != null) {
        final oldStart = int.parse(hunkMatch.group(1)!);
        final oldCount = int.tryParse(hunkMatch.group(2) ?? '1') ?? 1;
        final newStart = int.parse(hunkMatch.group(3)!);
        final newCount = int.tryParse(hunkMatch.group(4) ?? '1') ?? 1;
        final header = hunkMatch.group(5)?.trim();
        current = DiffHunk(
          oldStart: oldStart,
          oldCount: oldCount,
          newStart: newStart,
          newCount: newCount,
          header: header?.isNotEmpty == true ? header : null,
          lines: [],
        );
        hunks.add(current);
        oldLine = oldStart;
        newLine = newStart;
        continue;
      }
      if (current == null) continue;
      DiffLine? diffLine;
      if (line.startsWith('+')) {
        diffLine = DiffLine(
          type: DiffLineType.added,
          content: line.substring(1),
          newLineNumber: newLine++,
        );
      } else if (line.startsWith('-')) {
        diffLine = DiffLine(
          type: DiffLineType.deleted,
          content: line.substring(1),
          oldLineNumber: oldLine++,
        );
      } else if (line.startsWith(' ')) {
        diffLine = DiffLine(
          type: DiffLineType.context,
          content: line.substring(1),
          oldLineNumber: oldLine++,
          newLineNumber: newLine++,
        );
      }
      if (diffLine != null) current.lines.add(diffLine);
    }
    return hunks;
  }

  static DiffHunk _computeInlineChanges(DiffHunk hunk) {
    final lines = List<DiffLine>.from(hunk.lines);
    final result = <DiffLine>[];
    var i = 0;
    while (i < lines.length) {
      if (lines[i].type == DiffLineType.deleted) {
        final deletedStart = i;
        while (i < lines.length && lines[i].type == DiffLineType.deleted) {
          i++;
        }
        final addedStart = i;
        while (i < lines.length && lines[i].type == DiffLineType.added) {
          i++;
        }
        final deletedLines = lines.sublist(deletedStart, addedStart);
        final addedLines = lines.sublist(addedStart, i);
        final pairCount = min(deletedLines.length, addedLines.length);
        for (var j = 0; j < pairCount; j++) {
          final pair =
              _inlineDiff(deletedLines[j].content, addedLines[j].content);
          result.add(DiffLine(
            type: DiffLineType.deleted,
            content: deletedLines[j].content,
            oldLineNumber: deletedLines[j].oldLineNumber,
            inlineChanges: pair.$1,
          ));
          result.add(DiffLine(
            type: DiffLineType.added,
            content: addedLines[j].content,
            newLineNumber: addedLines[j].newLineNumber,
            inlineChanges: pair.$2,
          ));
        }
        for (var j = pairCount; j < deletedLines.length; j++) {
          result.add(deletedLines[j]);
        }
        for (var j = pairCount; j < addedLines.length; j++) {
          result.add(addedLines[j]);
        }
      } else {
        result.add(lines[i]);
        i++;
      }
    }
    return DiffHunk(
      oldStart: hunk.oldStart,
      oldCount: hunk.oldCount,
      newStart: hunk.newStart,
      newCount: hunk.newCount,
      header: hunk.header,
      lines: result,
    );
  }

  static (List<InlineChange>, List<InlineChange>) _inlineDiff(
      String oldStr, String newStr) {
    final lcs = _lcs(oldStr, newStr);
    final oldChanges = _findChanges(oldStr, lcs, true);
    final newChanges = _findChanges(newStr, lcs, false);
    return (oldChanges, newChanges);
  }

  static String _lcs(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        dp[i][j] = a[i - 1] == b[j - 1]
            ? dp[i - 1][j - 1] + 1
            : max(dp[i - 1][j], dp[i][j - 1]);
      }
    }
    final buf = StringBuffer();
    var i = m, j = n;
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        buf.write(a[i - 1]);
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }
    return buf.toString().split('').reversed.join();
  }

  static List<InlineChange> _findChanges(String str, String lcs, bool isOld) {
    final changes = <InlineChange>[];
    var si = 0, li = 0;
    int? changeStart;
    while (si < str.length) {
      if (li < lcs.length && str[si] == lcs[li]) {
        if (changeStart != null) {
          changes.add(InlineChange(start: changeStart, length: si - changeStart));
          changeStart = null;
        }
        li++;
      } else {
        changeStart ??= si;
      }
      si++;
    }
    if (changeStart != null) {
      changes.add(InlineChange(start: changeStart, length: si - changeStart));
    }
    return changes;
  }
}
