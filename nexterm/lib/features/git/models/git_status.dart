enum FileStatusCode {
  modified,
  added,
  deleted,
  renamed,
  copied,
  untracked,
  ignored,
  unmerged;

  static FileStatusCode fromChar(String c) => switch (c) {
        'M' => modified,
        'A' => added,
        'D' => deleted,
        'R' => renamed,
        'C' => copied,
        '?' => untracked,
        '!' => ignored,
        'U' => unmerged,
        _ => modified,
      };
}

class GitStatusEntry {
  final String path;
  final FileStatusCode indexStatus;
  final FileStatusCode workTreeStatus;
  final String? origPath;

  const GitStatusEntry({
    required this.path,
    required this.indexStatus,
    required this.workTreeStatus,
    this.origPath,
  });

  bool get isStaged =>
      indexStatus != FileStatusCode.untracked &&
      indexStatus != FileStatusCode.ignored;
  bool get isUnstaged =>
      workTreeStatus != FileStatusCode.untracked &&
      workTreeStatus != FileStatusCode.ignored;
}

class GitStatus {
  final String currentBranch;
  final List<GitStatusEntry> entries;

  const GitStatus({required this.currentBranch, this.entries = const []});

  List<GitStatusEntry> get staged => entries
      .where((e) =>
          e.indexStatus != FileStatusCode.untracked &&
          e.indexStatus != FileStatusCode.ignored &&
          e.indexStatus != FileStatusCode.unmerged)
      .toList();

  List<GitStatusEntry> get unstaged => entries
      .where((e) =>
          e.workTreeStatus == FileStatusCode.modified ||
          e.workTreeStatus == FileStatusCode.deleted)
      .toList();

  List<GitStatusEntry> get untracked =>
      entries.where((e) => e.indexStatus == FileStatusCode.untracked).toList();

  bool get isDirty => entries.isNotEmpty;
}
