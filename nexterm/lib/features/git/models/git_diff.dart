enum DiffLineType { context, added, deleted }

class InlineChange {
  final int start;
  final int length;
  const InlineChange({required this.start, required this.length});
}

class DiffLine {
  final DiffLineType type;
  final String content;
  final int? oldLineNumber;
  final int? newLineNumber;
  final List<InlineChange> inlineChanges;

  const DiffLine({
    required this.type,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
    this.inlineChanges = const [],
  });
}

class DiffHunk {
  final int oldStart;
  final int oldCount;
  final int newStart;
  final int newCount;
  final String? header;
  final List<DiffLine> lines;

  const DiffHunk({
    required this.oldStart,
    required this.oldCount,
    required this.newStart,
    required this.newCount,
    this.header,
    this.lines = const [],
  });
}

class GitFileDiff {
  final String filePath;
  final String? oldPath;
  final bool isNew;
  final bool isDeleted;
  final bool isRenamed;
  final List<DiffHunk> hunks;

  const GitFileDiff({
    required this.filePath,
    this.oldPath,
    this.isNew = false,
    this.isDeleted = false,
    this.isRenamed = false,
    this.hunks = const [],
  });

  int get additions => hunks.fold(
      0,
      (sum, h) =>
          sum + h.lines.where((l) => l.type == DiffLineType.added).length);
  int get deletions => hunks.fold(
      0,
      (sum, h) =>
          sum + h.lines.where((l) => l.type == DiffLineType.deleted).length);
}
