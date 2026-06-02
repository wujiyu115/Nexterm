# Remote Git Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Git management feature to Nexterm that lets users browse commit history, view diffs, manage branches/tags, and visualize branch graphs for Git repositories on remote servers via SSH.

**Architecture:** All git commands are executed remotely via `SSHClient.execute()` — each operation opens an independent exec channel, uses `--format` flags for machine-parseable output, and parses the text result into Dart models. The UI follows the existing feature module pattern (`features/git/`) with Riverpod providers and go_router integration.

**Tech Stack:** Flutter 3.29+, Dart 3.7+, dartssh2 (SSH exec), drift (database for saved repos), flutter_riverpod (state), go_router (routing), CustomPainter (branch graph)

---

## File Structure

### Models (pure data classes, no I/O)
- **Create:** `nexterm/lib/features/git/models/git_commit.dart` — commit data: sha, author, email, timestamp, subject, body, parentShas, refs
- **Create:** `nexterm/lib/features/git/models/git_branch.dart` — branch data: name, shortSha, isCurrent, isRemote
- **Create:** `nexterm/lib/features/git/models/git_tag.dart` — tag data: name, shortSha, timestamp
- **Create:** `nexterm/lib/features/git/models/git_diff.dart` — diff models: GitFileDiff, DiffHunk, DiffLine, InlineChange
- **Create:** `nexterm/lib/features/git/models/git_status.dart` — working tree status: GitStatusEntry (path, indexStatus, workTreeStatus)
- **Create:** `nexterm/lib/features/git/models/git_graph.dart` — graph topology: GraphRow, GraphLine, LaneColor

### Services (SSH exec + parsing)
- **Create:** `nexterm/lib/features/git/services/git_command_service.dart` — executes git commands via SSH, parses output
- **Create:** `nexterm/lib/features/git/services/diff_parser.dart` — parses unified diff output into GitFileDiff models
- **Create:** `nexterm/lib/features/git/services/graph_layout_service.dart` — lane assignment algorithm for branch graph

### Providers (Riverpod)
- **Create:** `nexterm/lib/features/git/providers/git_provider.dart` — main provider: holds current repo path, loads commits/branches/tags/status

### Database (drift — for Vault saved repos)
- **Create:** `nexterm/lib/data/database/tables/git_repos_table.dart` — GitRepos drift table
- **Create:** `nexterm/lib/data/database/daos/git_repos_dao.dart` — CRUD for saved repos
- **Create:** `nexterm/lib/domain/entities/git_repo_entity.dart` — entity class
- **Create:** `nexterm/lib/domain/repositories/git_repo_repository.dart` — repository interface
- **Create:** `nexterm/lib/data/repositories/git_repo_repository_impl.dart` — repository impl
- **Create:** `nexterm/lib/features/git/providers/git_repos_provider.dart` — Riverpod provider for saved repos
- **Modify:** `nexterm/lib/data/database/app_database.dart` — add GitRepos table, bump schema version

### UI
- **Create:** `nexterm/lib/features/git/ui/git_screen.dart` — main three-tab screen
- **Create:** `nexterm/lib/features/git/ui/git_repos_screen.dart` — Vault entry: saved repos list + add form
- **Create:** `nexterm/lib/features/git/ui/git_repo_form_screen.dart` — add/edit saved repo
- **Create:** `nexterm/lib/features/git/ui/widgets/commit_list.dart` — scrollable commit history
- **Create:** `nexterm/lib/features/git/ui/widgets/commit_detail_sheet.dart` — commit detail bottom sheet
- **Create:** `nexterm/lib/features/git/ui/widgets/branch_graph_screen.dart` — full-screen branch graph (CustomPainter + synced list)
- **Create:** `nexterm/lib/features/git/ui/widgets/branch_graph_painter.dart` — CustomPainter for branch lines
- **Create:** `nexterm/lib/features/git/ui/widgets/diff_view.dart` — unified diff with char-level highlight
- **Create:** `nexterm/lib/features/git/ui/widgets/status_file_list.dart` — staged/unstaged file list
- **Create:** `nexterm/lib/features/git/ui/widgets/branch_list.dart` — branch list with swipe-to-delete
- **Create:** `nexterm/lib/features/git/ui/widgets/tag_list.dart` — tag list with swipe-to-delete + checkout
- **Create:** `nexterm/lib/features/git/ui/widgets/git_init_prompt.dart` — non-repo init prompt

### Integration (entry points + routing)
- **Modify:** `nexterm/lib/core/router/app_router.dart` — add git routes
- **Modify:** `nexterm/lib/features/vaults/ui/vaults_screen.dart` — add Git Repos entry
- **Modify:** `nexterm/lib/features/sftp/ui/sftp_screen.dart` — add Git button when .git detected
- **Modify:** `nexterm/lib/features/terminal/ui/widgets/function_panel.dart` — add Git tab/button

### Localization
- **Modify:** `nexterm/lib/l10n/app_en.arb` — add git i18n keys
- **Modify:** `nexterm/lib/l10n/app_zh.arb` — add git i18n keys

---

## Task 1: Git Data Models

**Files:**
- Create: `nexterm/lib/features/git/models/git_commit.dart`
- Create: `nexterm/lib/features/git/models/git_branch.dart`
- Create: `nexterm/lib/features/git/models/git_tag.dart`
- Create: `nexterm/lib/features/git/models/git_diff.dart`
- Create: `nexterm/lib/features/git/models/git_status.dart`
- Create: `nexterm/lib/features/git/models/git_graph.dart`

- [ ] **Step 1: Create git_commit.dart**

```dart
// nexterm/lib/features/git/models/git_commit.dart

class GitCommit {
  final String sha;
  final String authorName;
  final String authorEmail;
  final DateTime timestamp;
  final String subject;
  final String body;
  final List<String> parentShas;
  final List<String> refs;

  const GitCommit({
    required this.sha,
    required this.authorName,
    required this.authorEmail,
    required this.timestamp,
    required this.subject,
    this.body = '',
    this.parentShas = const [],
    this.refs = const [],
  });

  String get shortSha => sha.length >= 7 ? sha.substring(0, 7) : sha;

  bool get isMerge => parentShas.length > 1;
}
```

- [ ] **Step 2: Create git_branch.dart**

```dart
// nexterm/lib/features/git/models/git_branch.dart

class GitBranch {
  final String name;
  final String shortSha;
  final bool isCurrent;
  final bool isRemote;

  const GitBranch({
    required this.name,
    required this.shortSha,
    this.isCurrent = false,
    this.isRemote = false,
  });

  bool get isDefault =>
      name == 'main' ||
      name == 'master' ||
      name == 'origin/main' ||
      name == 'origin/master';
}
```

- [ ] **Step 3: Create git_tag.dart**

```dart
// nexterm/lib/features/git/models/git_tag.dart

class GitTag {
  final String name;
  final String shortSha;
  final DateTime? timestamp;

  const GitTag({
    required this.name,
    required this.shortSha,
    this.timestamp,
  });
}
```

- [ ] **Step 4: Create git_diff.dart**

```dart
// nexterm/lib/features/git/models/git_diff.dart

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

  int get additions => hunks.fold(0, (sum, h) => sum + h.lines.where((l) => l.type == DiffLineType.added).length);
  int get deletions => hunks.fold(0, (sum, h) => sum + h.lines.where((l) => l.type == DiffLineType.deleted).length);
}
```

- [ ] **Step 5: Create git_status.dart**

```dart
// nexterm/lib/features/git/models/git_status.dart

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

  bool get isStaged => indexStatus != FileStatusCode.untracked && indexStatus != FileStatusCode.ignored;
  bool get isUnstaged => workTreeStatus != FileStatusCode.untracked && workTreeStatus != FileStatusCode.ignored;
}

class GitStatus {
  final String currentBranch;
  final List<GitStatusEntry> entries;

  const GitStatus({
    required this.currentBranch,
    this.entries = const [],
  });

  List<GitStatusEntry> get staged => entries.where((e) =>
      e.indexStatus != FileStatusCode.untracked &&
      e.indexStatus != FileStatusCode.ignored &&
      e.indexStatus != FileStatusCode.unmerged).toList();

  List<GitStatusEntry> get unstaged => entries.where((e) =>
      e.workTreeStatus == FileStatusCode.modified ||
      e.workTreeStatus == FileStatusCode.deleted).toList();

  List<GitStatusEntry> get untracked => entries.where((e) =>
      e.indexStatus == FileStatusCode.untracked).toList();

  bool get isDirty => entries.isNotEmpty;
}
```

- [ ] **Step 6: Create git_graph.dart**

```dart
// nexterm/lib/features/git/models/git_graph.dart

import 'dart:ui';
import 'package:nexterm/features/git/models/git_commit.dart';

const graphLaneColors = [
  Color(0xFF4A9EEA), // blue
  Color(0xFFE5A84B), // orange
  Color(0xFF6BCB77), // green
  Color(0xFFE06C75), // red
  Color(0xFFC678DD), // purple
  Color(0xFF56B6C2), // cyan
  Color(0xFFD19A66), // brown
  Color(0xFF98C379), // lime
];

enum GraphLineType { straight, mergeLeft, mergeRight, fork }

class GraphLine {
  final int fromLane;
  final int toLane;
  final GraphLineType type;
  final int colorIndex;

  const GraphLine({
    required this.fromLane,
    required this.toLane,
    required this.type,
    required this.colorIndex,
  });
}

class GraphRow {
  final GitCommit commit;
  final int laneIndex;
  final int colorIndex;
  final List<GraphLine> lines;
  final int activeLaneCount;

  const GraphRow({
    required this.commit,
    required this.laneIndex,
    required this.colorIndex,
    required this.lines,
    required this.activeLaneCount,
  });
}
```

- [ ] **Step 7: Commit**

```bash
git add nexterm/lib/features/git/models/
git commit -m "feat(git): add data models for remote git management"
```

---

## Task 2: Git Command Service

**Files:**
- Create: `nexterm/lib/features/git/services/git_command_service.dart`

- [ ] **Step 1: Create git_command_service.dart**

This service uses `SSHClient.execute()` to run git commands remotely. Each method opens an independent exec channel, runs a command, checks the exit code, and parses the output.

```dart
// nexterm/lib/features/git/services/git_command_service.dart

import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/features/git/models/git_branch.dart';
import 'package:nexterm/features/git/models/git_tag.dart';
import 'package:nexterm/features/git/models/git_status.dart';

class GitCommandException implements Exception {
  final String command;
  final int exitCode;
  final String stderr;

  GitCommandException({
    required this.command,
    required this.exitCode,
    required this.stderr,
  });

  @override
  String toString() => 'GitCommandException: "$command" exited with $exitCode: $stderr';
}

class GitCommandResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  const GitCommandResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });
}

class GitCommandService {
  final SSHClient _client;
  final String _repoPath;

  GitCommandService({required SSHClient client, required String repoPath})
      : _client = client,
        _repoPath = repoPath;

  // ---------------------------------------------------------------------------
  // Low-level exec
  // ---------------------------------------------------------------------------

  Future<GitCommandResult> _exec(String command) async {
    final fullCommand = 'git -C ${_shellEscape(_repoPath)} $command';
    final session = await _client.execute(fullCommand);

    final stdoutBytes = await session.stdout.toList();
    final stderrBytes = await session.stderr.toList();

    final stdout = utf8.decode(stdoutBytes.expand((b) => b).toList(), allowMalformed: true);
    final stderr = utf8.decode(stderrBytes.expand((b) => b).toList(), allowMalformed: true);

    await session.done;
    final exitCode = session.exitCode ?? -1;

    return GitCommandResult(stdout: stdout, stderr: stderr, exitCode: exitCode);
  }

  Future<String> _run(String command) async {
    final result = await _exec(command);
    if (result.exitCode != 0) {
      throw GitCommandException(
        command: command,
        exitCode: result.exitCode,
        stderr: result.stderr,
      );
    }
    return result.stdout;
  }

  String _shellEscape(String s) {
    return "'${s.replaceAll("'", "'\\''")}'";
  }

  // ---------------------------------------------------------------------------
  // Repo detection & init
  // ---------------------------------------------------------------------------

  Future<bool> isGitRepo() async {
    final result = await _exec('rev-parse --git-dir');
    return result.exitCode == 0;
  }

  Future<void> init() async {
    await _run('init');
  }

  Future<String> currentBranch() async {
    final output = await _run('rev-parse --abbrev-ref HEAD');
    return output.trim();
  }

  // ---------------------------------------------------------------------------
  // Commit history
  // ---------------------------------------------------------------------------

  /// Record separator \x1e, field separator \x00.
  static const _commitFormat = '%H%x00%an%x00%ae%x00%at%x00%s%x00%b%x1e';

  Future<List<GitCommit>> log({int limit = 100, String? filePath}) async {
    var cmd = 'log --format=$_commitFormat -n $limit';
    if (filePath != null) {
      cmd += ' --follow -- ${_shellEscape(filePath)}';
    }
    final output = await _run(cmd);
    return _parseCommits(output);
  }

  /// For branch graph: includes --all, --parents, and refs.
  static const _graphFormat = '%H%x00%P%x00%an%x00%at%x00%D%x00%s%x1e';

  Future<List<GitCommit>> logAll({int limit = 200}) async {
    final output = await _run('log --all --format=$_graphFormat -n $limit');
    return _parseGraphCommits(output);
  }

  List<GitCommit> _parseCommits(String output) {
    final records = output.split('\x1e').where((r) => r.trim().isNotEmpty);
    return records.map((record) {
      final fields = record.trim().split('\x00');
      if (fields.length < 5) return null;
      return GitCommit(
        sha: fields[0],
        authorName: fields[1],
        authorEmail: fields[2],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            int.tryParse(fields[3]) ?? 0 * 1000, isUtc: true),
        subject: fields[4],
        body: fields.length > 5 ? fields[5].trim() : '',
      );
    }).whereType<GitCommit>().toList();
  }

  List<GitCommit> _parseGraphCommits(String output) {
    final records = output.split('\x1e').where((r) => r.trim().isNotEmpty);
    return records.map((record) {
      final fields = record.trim().split('\x00');
      if (fields.length < 6) return null;
      final parentShas = fields[1].trim().isEmpty
          ? <String>[]
          : fields[1].trim().split(' ');
      final refsStr = fields[4].trim();
      final refs = refsStr.isEmpty
          ? <String>[]
          : refsStr.split(', ').map((r) => r.trim()).toList();
      return GitCommit(
        sha: fields[0],
        authorName: fields[2],
        authorEmail: '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            (int.tryParse(fields[3]) ?? 0) * 1000, isUtc: true),
        subject: fields[5],
        parentShas: parentShas,
        refs: refs,
      );
    }).whereType<GitCommit>().toList();
  }

  // ---------------------------------------------------------------------------
  // Branches
  // ---------------------------------------------------------------------------

  Future<List<GitBranch>> branches() async {
    final output = await _run(
        "branch -a --format=%(refname:short)%x00%(objectname:short)%x00%(HEAD)");
    final lines = output.trim().split('\n').where((l) => l.isNotEmpty);
    return lines.map((line) {
      final parts = line.split('\x00');
      if (parts.length < 3) return null;
      return GitBranch(
        name: parts[0],
        shortSha: parts[1],
        isCurrent: parts[2].trim() == '*',
        isRemote: parts[0].startsWith('origin/'),
      );
    }).whereType<GitBranch>().toList();
  }

  Future<void> deleteBranch(String name) async {
    await _run('branch -d ${_shellEscape(name)}');
  }

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  Future<List<GitTag>> tags() async {
    final output = await _run(
        "tag -l --format=%(refname:short)%x00%(objectname:short)%x00%(creatordate:unix)");
    if (output.trim().isEmpty) return [];
    final lines = output.trim().split('\n').where((l) => l.isNotEmpty);
    return lines.map((line) {
      final parts = line.split('\x00');
      if (parts.length < 3) return null;
      final ts = int.tryParse(parts[2].trim());
      return GitTag(
        name: parts[0],
        shortSha: parts[1],
        timestamp: ts != null && ts > 0
            ? DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true)
            : null,
      );
    }).whereType<GitTag>().toList();
  }

  Future<void> deleteTag(String name) async {
    await _run('tag -d ${_shellEscape(name)}');
  }

  Future<void> checkoutTag(String name) async {
    await _run('checkout ${_shellEscape(name)}');
  }

  Future<void> stash() async {
    await _run('stash');
  }

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  Future<GitStatus> status() async {
    final branchName = await currentBranch();
    final output = await _run('status --porcelain=v2');
    final entries = <GitStatusEntry>[];

    for (final line in output.split('\n').where((l) => l.isNotEmpty)) {
      if (line.startsWith('1 ')) {
        // ordinary changed entry: 1 XY ...  path
        final parts = line.split(' ');
        if (parts.length >= 9) {
          final xy = parts[1];
          final path = parts.sublist(8).join(' ');
          entries.add(GitStatusEntry(
            path: path,
            indexStatus: _statusFromChar(xy[0]),
            workTreeStatus: _statusFromChar(xy[1]),
          ));
        }
      } else if (line.startsWith('2 ')) {
        // renamed/copied: 2 XY ... origPath\tpath
        final parts = line.split(' ');
        if (parts.length >= 10) {
          final xy = parts[1];
          final pathPart = parts.sublist(9).join(' ');
          final paths = pathPart.split('\t');
          entries.add(GitStatusEntry(
            path: paths.length > 1 ? paths[1] : paths[0],
            indexStatus: _statusFromChar(xy[0]),
            workTreeStatus: _statusFromChar(xy[1]),
            origPath: paths.isNotEmpty ? paths[0] : null,
          ));
        }
      } else if (line.startsWith('? ')) {
        // untracked: ? path
        entries.add(GitStatusEntry(
          path: line.substring(2),
          indexStatus: FileStatusCode.untracked,
          workTreeStatus: FileStatusCode.untracked,
        ));
      }
    }

    return GitStatus(currentBranch: branchName, entries: entries);
  }

  FileStatusCode _statusFromChar(String c) => switch (c) {
    'M' => FileStatusCode.modified,
    'A' => FileStatusCode.added,
    'D' => FileStatusCode.deleted,
    'R' => FileStatusCode.renamed,
    'C' => FileStatusCode.copied,
    '.' => FileStatusCode.untracked,
    _ => FileStatusCode.modified,
  };

  // ---------------------------------------------------------------------------
  // Diff
  // ---------------------------------------------------------------------------

  Future<String> diffUnstaged() async {
    return await _run('diff');
  }

  Future<String> diffStaged() async {
    return await _run('diff --cached');
  }

  Future<String> diffCommit(String sha) async {
    return await _run('diff-tree -p $sha');
  }

  Future<String> diffFile(String filePath, {bool staged = false}) async {
    final flag = staged ? '--cached' : '';
    return await _run('diff $flag -- ${_shellEscape(filePath)}');
  }

  // ---------------------------------------------------------------------------
  // Commit file list
  // ---------------------------------------------------------------------------

  Future<List<CommitFileChange>> commitFiles(String sha) async {
    final output = await _run('diff-tree --no-commit-id -r --name-status $sha');
    final lines = output.trim().split('\n').where((l) => l.isNotEmpty);
    return lines.map((line) {
      final parts = line.split('\t');
      if (parts.length < 2) return null;
      return CommitFileChange(
        status: parts[0].trim(),
        path: parts.length > 2 ? parts[2] : parts[1],
        oldPath: parts.length > 2 ? parts[1] : null,
      );
    }).whereType<CommitFileChange>().toList();
  }
}

class CommitFileChange {
  final String status;
  final String path;
  final String? oldPath;

  const CommitFileChange({
    required this.status,
    required this.path,
    this.oldPath,
  });

  String get statusLabel => switch (status) {
    'A' => 'Added',
    'D' => 'Deleted',
    'M' => 'Modified',
    _ when status.startsWith('R') => 'Renamed',
    _ when status.startsWith('C') => 'Copied',
    _ => status,
  };
}
```

- [ ] **Step 2: Verify the service compiles**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter analyze nexterm/lib/features/git/services/git_command_service.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/services/git_command_service.dart
git commit -m "feat(git): add GitCommandService for remote git command execution"
```

---

## Task 3: Diff Parser Service

**Files:**
- Create: `nexterm/lib/features/git/services/diff_parser.dart`

- [ ] **Step 1: Create diff_parser.dart**

Parses unified diff output and computes character-level inline changes using a simple LCS approach.

```dart
// nexterm/lib/features/git/services/diff_parser.dart

import 'dart:math';
import 'package:nexterm/features/git/models/git_diff.dart';

class DiffParser {
  /// Parses the full output of `git diff` into per-file diffs.
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
    // First line: a/path b/path
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

    // Compute inline changes for adjacent add/delete pairs
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
      final hunkMatch = RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)$')
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

      if (diffLine != null) {
        (current.lines as List<DiffLine>).add(diffLine);
      }
    }

    return hunks;
  }

  /// For adjacent deleted→added line pairs, compute character-level diffs.
  static DiffHunk _computeInlineChanges(DiffHunk hunk) {
    final lines = List<DiffLine>.from(hunk.lines);
    final result = <DiffLine>[];
    var i = 0;

    while (i < lines.length) {
      if (lines[i].type == DiffLineType.deleted) {
        // Collect consecutive deleted lines
        final deletedStart = i;
        while (i < lines.length && lines[i].type == DiffLineType.deleted) {
          i++;
        }
        // Collect consecutive added lines
        final addedStart = i;
        while (i < lines.length && lines[i].type == DiffLineType.added) {
          i++;
        }
        final deletedLines = lines.sublist(deletedStart, addedStart);
        final addedLines = lines.sublist(addedStart, i);

        // Pair them up for inline diff
        final pairCount = min(deletedLines.length, addedLines.length);
        for (var j = 0; j < pairCount; j++) {
          final pair = _inlineDiff(deletedLines[j].content, addedLines[j].content);
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
        // Remaining unpaired lines
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

  /// Returns (deletedInlineChanges, addedInlineChanges) for a pair of lines.
  /// Uses a simple LCS-based character diff.
  static (List<InlineChange>, List<InlineChange>) _inlineDiff(
      String oldStr, String newStr) {
    final lcs = _lcs(oldStr, newStr);
    final oldChanges = _findChanges(oldStr, lcs, true);
    final newChanges = _findChanges(newStr, lcs, false);
    return (oldChanges, newChanges);
  }

  static String _lcs(String a, String b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
        }
      }
    }

    // Backtrack to find the LCS string
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

  static List<InlineChange> _findChanges(
      String str, String lcs, bool isOld) {
    final changes = <InlineChange>[];
    var si = 0;
    var li = 0;
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
```

- [ ] **Step 2: Verify compilation**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter analyze lib/features/git/services/diff_parser.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/services/diff_parser.dart
git commit -m "feat(git): add DiffParser with character-level inline change detection"
```

---

## Task 4: Graph Layout Service

**Files:**
- Create: `nexterm/lib/features/git/services/graph_layout_service.dart`

- [ ] **Step 1: Create graph_layout_service.dart**

Implements the lane assignment algorithm that takes a list of commits (with parent SHAs) and outputs `GraphRow` data for rendering.

```dart
// nexterm/lib/features/git/services/graph_layout_service.dart

import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/features/git/models/git_graph.dart';

class GraphLayoutService {
  /// Computes graph layout from a topologically-sorted commit list
  /// (most recent first, as `git log --all` outputs).
  static List<GraphRow> computeLayout(List<GitCommit> commits) {
    final rows = <GraphRow>[];
    // Active lanes: each lane holds the SHA it's waiting to see.
    final lanes = <String?>[];
    // Maps SHA → lane index for quick lookup of which lane a commit occupies.
    final shaToLane = <String, int>{};
    // Maps SHA → color index.
    final shaToColor = <String, int>{};
    var nextColor = 0;

    for (final commit in commits) {
      int laneIndex;

      // Does this commit already have a reserved lane?
      if (shaToLane.containsKey(commit.sha)) {
        laneIndex = shaToLane[commit.sha]!;
      } else {
        // Find an empty lane or add a new one
        laneIndex = lanes.indexOf(null);
        if (laneIndex == -1) {
          laneIndex = lanes.length;
          lanes.add(null);
        }
        shaToColor[commit.sha] = nextColor % graphLaneColors.length;
        nextColor++;
      }

      final colorIndex = shaToColor[commit.sha] ?? 0;

      // Mark this lane as occupied by this commit
      lanes[laneIndex] = commit.sha;

      final lineSegments = <GraphLine>[];

      // Draw pass-through lines for all active lanes
      for (var i = 0; i < lanes.length; i++) {
        if (i == laneIndex) continue;
        if (lanes[i] != null) {
          lineSegments.add(GraphLine(
            fromLane: i,
            toLane: i,
            type: GraphLineType.straight,
            colorIndex: shaToColor[lanes[i]] ?? 0,
          ));
        }
      }

      // Clear this lane (will be reassigned to first parent below)
      lanes[laneIndex] = null;

      // Process parents
      if (commit.parentShas.isNotEmpty) {
        final firstParent = commit.parentShas[0];

        if (!shaToLane.containsKey(firstParent)) {
          // First parent continues in the same lane
          lanes[laneIndex] = firstParent;
          shaToLane[firstParent] = laneIndex;
          shaToColor[firstParent] = colorIndex;

          lineSegments.add(GraphLine(
            fromLane: laneIndex,
            toLane: laneIndex,
            type: GraphLineType.straight,
            colorIndex: colorIndex,
          ));
        } else {
          // First parent already has a lane — merge line
          final parentLane = shaToLane[firstParent]!;
          final type = parentLane < laneIndex
              ? GraphLineType.mergeLeft
              : GraphLineType.mergeRight;
          lineSegments.add(GraphLine(
            fromLane: laneIndex,
            toLane: parentLane,
            type: type,
            colorIndex: colorIndex,
          ));
        }

        // Additional parents (merge commits) — assign new lanes
        for (var p = 1; p < commit.parentShas.length; p++) {
          final parent = commit.parentShas[p];
          if (!shaToLane.containsKey(parent)) {
            var newLane = lanes.indexOf(null);
            if (newLane == -1) {
              newLane = lanes.length;
              lanes.add(null);
            }
            lanes[newLane] = parent;
            shaToLane[parent] = newLane;
            final pColor = nextColor % graphLaneColors.length;
            shaToColor[parent] = pColor;
            nextColor++;

            lineSegments.add(GraphLine(
              fromLane: laneIndex,
              toLane: newLane,
              type: GraphLineType.fork,
              colorIndex: pColor,
            ));
          } else {
            final parentLane = shaToLane[parent]!;
            final type = parentLane < laneIndex
                ? GraphLineType.mergeLeft
                : GraphLineType.mergeRight;
            lineSegments.add(GraphLine(
              fromLane: laneIndex,
              toLane: parentLane,
              type: type,
              colorIndex: shaToColor[parent] ?? 0,
            ));
          }
        }
      }

      // Compact: remove trailing null lanes
      while (lanes.isNotEmpty && lanes.last == null) {
        lanes.removeLast();
      }

      rows.add(GraphRow(
        commit: commit,
        laneIndex: laneIndex,
        colorIndex: colorIndex,
        lines: lineSegments,
        activeLaneCount: lanes.length,
      ));
    }

    return rows;
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter analyze lib/features/git/services/graph_layout_service.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/services/graph_layout_service.dart
git commit -m "feat(git): add GraphLayoutService with lane assignment algorithm"
```

---

## Task 5: Localization Strings

**Files:**
- Modify: `nexterm/lib/l10n/app_en.arb`
- Modify: `nexterm/lib/l10n/app_zh.arb`

- [ ] **Step 1: Add English i18n keys to app_en.arb**

Add the following keys at the end of the JSON object (before the closing `}`):

```json
  "git_title": "Git",
  "git_repos": "Git Repos",
  "git_reposEmpty": "No saved repositories",
  "git_addRepo": "Add Repository",
  "git_editRepo": "Edit Repository",
  "git_repoLabel": "Label",
  "git_repoLabelHint": "e.g. My Project",
  "git_repoPath": "Remote Path",
  "git_repoPathHint": "e.g. /home/user/project",
  "git_selectHost": "Select Host",
  "git_tabWorkTree": "Working Tree",
  "git_tabBranches": "Branches",
  "git_tabTags": "Tags",
  "git_commits": "Commits",
  "git_commitDetail": "Commit Detail",
  "git_author": "Author",
  "git_date": "Date",
  "git_message": "Message",
  "git_changedFiles": "Changed Files",
  "git_staged": "Staged",
  "git_unstaged": "Unstaged",
  "git_untracked": "Untracked",
  "git_noChanges": "Working tree clean",
  "git_branchGraph": "Branch Graph",
  "git_currentBranch": "Current",
  "git_deleteBranch": "Delete Branch",
  "git_deleteBranchProtected": "Cannot delete current or default branch",
  "git_deleteTag": "Delete Tag",
  "git_deleteTagConfirm": "Delete tag \"{name}\"?",
  "@git_deleteTagConfirm": { "placeholders": { "name": { "type": "String" } } },
  "git_checkoutTag": "Checkout",
  "git_checkoutDirtyTitle": "Uncommitted Changes",
  "git_checkoutDirtyMessage": "Your working tree has uncommitted changes. Stash them before checking out?",
  "git_stashAndCheckout": "Stash & Checkout",
  "git_initTitle": "Not a Git Repository",
  "git_initMessage": "This directory is not a git repository. Initialize one?",
  "git_initButton": "Initialize",
  "git_initConfirm": "Initialize a git repository at this path?",
  "git_fileHistory": "File History",
  "git_diff": "Diff",
  "git_additions": "+{count}",
  "@git_additions": { "placeholders": { "count": { "type": "int" } } },
  "git_deletions": "-{count}",
  "@git_deletions": { "placeholders": { "count": { "type": "int" } } },
  "git_statusModified": "Modified",
  "git_statusAdded": "Added",
  "git_statusDeleted": "Deleted",
  "git_statusRenamed": "Renamed",
  "git_statusUntracked": "Untracked",
  "git_noBranches": "No branches",
  "git_noTags": "No tags",
  "git_noCommits": "No commits yet",
  "git_openGit": "Open Git",
  "git_connecting": "Connecting..."
```

- [ ] **Step 2: Add Chinese i18n keys to app_zh.arb**

Add the corresponding Chinese translations at the end of app_zh.arb:

```json
  "git_title": "Git",
  "git_repos": "Git 仓库",
  "git_reposEmpty": "暂无已保存的仓库",
  "git_addRepo": "添加仓库",
  "git_editRepo": "编辑仓库",
  "git_repoLabel": "标签",
  "git_repoLabelHint": "例如: 我的项目",
  "git_repoPath": "远程路径",
  "git_repoPathHint": "例如: /home/user/project",
  "git_selectHost": "选择主机",
  "git_tabWorkTree": "工作树",
  "git_tabBranches": "分支",
  "git_tabTags": "标签",
  "git_commits": "提交",
  "git_commitDetail": "提交详情",
  "git_author": "作者",
  "git_date": "日期",
  "git_message": "提交信息",
  "git_changedFiles": "变更文件",
  "git_staged": "已暂存",
  "git_unstaged": "未暂存",
  "git_untracked": "未跟踪",
  "git_noChanges": "工作树干净",
  "git_branchGraph": "分支图",
  "git_currentBranch": "当前",
  "git_deleteBranch": "删除分支",
  "git_deleteBranchProtected": "无法删除当前分支或默认分支",
  "git_deleteTag": "删除标签",
  "git_deleteTagConfirm": "删除标签 \"{name}\"？",
  "@git_deleteTagConfirm": { "placeholders": { "name": { "type": "String" } } },
  "git_checkoutTag": "检出",
  "git_checkoutDirtyTitle": "未提交的更改",
  "git_checkoutDirtyMessage": "工作树有未提交的更改。是否先暂存再检出？",
  "git_stashAndCheckout": "暂存并检出",
  "git_initTitle": "非 Git 仓库",
  "git_initMessage": "此目录不是 git 仓库。是否初始化？",
  "git_initButton": "初始化",
  "git_initConfirm": "在此路径初始化 git 仓库？",
  "git_fileHistory": "文件历史",
  "git_diff": "差异",
  "git_additions": "+{count}",
  "@git_additions": { "placeholders": { "count": { "type": "int" } } },
  "git_deletions": "-{count}",
  "@git_deletions": { "placeholders": { "count": { "type": "int" } } },
  "git_statusModified": "已修改",
  "git_statusAdded": "已添加",
  "git_statusDeleted": "已删除",
  "git_statusRenamed": "已重命名",
  "git_statusUntracked": "未跟踪",
  "git_noBranches": "暂无分支",
  "git_noTags": "暂无标签",
  "git_noCommits": "暂无提交",
  "git_openGit": "打开 Git",
  "git_connecting": "连接中..."
```

- [ ] **Step 3: Regenerate localizations**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter gen-l10n`
Expected: Regenerates `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_zh.dart` with new git keys

- [ ] **Step 4: Commit**

```bash
git add nexterm/lib/l10n/
git commit -m "feat(git): add i18n strings for git management feature"
```

---

## Task 6: Git Provider (Riverpod State Management)

**Files:**
- Create: `nexterm/lib/features/git/providers/git_provider.dart`

- [ ] **Step 1: Create git_provider.dart**

```dart
// nexterm/lib/features/git/providers/git_provider.dart

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/git/models/git_branch.dart';
import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/features/git/models/git_diff.dart';
import 'package:nexterm/features/git/models/git_graph.dart';
import 'package:nexterm/features/git/models/git_status.dart';
import 'package:nexterm/features/git/models/git_tag.dart';
import 'package:nexterm/features/git/services/diff_parser.dart';
import 'package:nexterm/features/git/services/git_command_service.dart';
import 'package:nexterm/features/git/services/graph_layout_service.dart';

class GitState {
  final bool isLoading;
  final String? error;
  final bool isRepo;
  final String currentBranch;
  final List<GitCommit> commits;
  final List<GitBranch> branches;
  final List<GitTag> tags;
  final GitStatus? status;
  final List<GraphRow> graphRows;

  const GitState({
    this.isLoading = true,
    this.error,
    this.isRepo = false,
    this.currentBranch = '',
    this.commits = const [],
    this.branches = const [],
    this.tags = const [],
    this.status,
    this.graphRows = const [],
  });

  GitState copyWith({
    bool? isLoading,
    String? Function()? error,
    bool? isRepo,
    String? currentBranch,
    List<GitCommit>? commits,
    List<GitBranch>? branches,
    List<GitTag>? tags,
    GitStatus? Function()? status,
    List<GraphRow>? graphRows,
  }) {
    return GitState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      isRepo: isRepo ?? this.isRepo,
      currentBranch: currentBranch ?? this.currentBranch,
      commits: commits ?? this.commits,
      branches: branches ?? this.branches,
      tags: tags ?? this.tags,
      status: status != null ? status() : this.status,
      graphRows: graphRows ?? this.graphRows,
    );
  }
}

class GitNotifier extends ChangeNotifier {
  final GitCommandService _service;
  GitState _state = const GitState();

  GitNotifier(this._service);

  GitState get state => _state;
  GitCommandService get service => _service;

  void _update(GitState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _update(_state.copyWith(isLoading: true, error: () => null));
    try {
      final isRepo = await _service.isGitRepo();
      if (!isRepo) {
        _update(_state.copyWith(isLoading: false, isRepo: false));
        return;
      }

      final results = await Future.wait([
        _service.log(),
        _service.branches(),
        _service.tags(),
        _service.status(),
      ]);

      _update(_state.copyWith(
        isLoading: false,
        isRepo: true,
        commits: results[0] as List<GitCommit>,
        branches: results[1] as List<GitBranch>,
        tags: results[2] as List<GitTag>,
        status: () => results[3] as GitStatus,
        currentBranch: (results[3] as GitStatus).currentBranch,
      ));
    } catch (e) {
      _update(_state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }

  Future<void> loadGraph() async {
    try {
      final commits = await _service.logAll();
      final rows = GraphLayoutService.computeLayout(commits);
      _update(_state.copyWith(graphRows: rows));
    } catch (e) {
      debugPrint('loadGraph error: $e');
    }
  }

  Future<void> refreshStatus() async {
    try {
      final status = await _service.status();
      _update(_state.copyWith(
        status: () => status,
        currentBranch: status.currentBranch,
      ));
    } catch (e) {
      debugPrint('refreshStatus error: $e');
    }
  }

  Future<void> refreshBranches() async {
    try {
      final branches = await _service.branches();
      _update(_state.copyWith(branches: branches));
    } catch (e) {
      debugPrint('refreshBranches error: $e');
    }
  }

  Future<void> refreshTags() async {
    try {
      final tags = await _service.tags();
      _update(_state.copyWith(tags: tags));
    } catch (e) {
      debugPrint('refreshTags error: $e');
    }
  }

  Future<List<GitFileDiff>> getDiff({bool staged = false}) async {
    final rawDiff = staged
        ? await _service.diffStaged()
        : await _service.diffUnstaged();
    return DiffParser.parse(rawDiff);
  }

  Future<List<GitFileDiff>> getFileDiff(String filePath, {bool staged = false}) async {
    final rawDiff = await _service.diffFile(filePath, staged: staged);
    return DiffParser.parse(rawDiff);
  }

  Future<List<GitFileDiff>> getCommitDiff(String sha) async {
    final rawDiff = await _service.diffCommit(sha);
    return DiffParser.parse(rawDiff);
  }

  Future<List<CommitFileChange>> getCommitFiles(String sha) async {
    return await _service.commitFiles(sha);
  }

  Future<List<GitCommit>> getFileHistory(String filePath) async {
    return await _service.log(filePath: filePath);
  }

  Future<void> deleteBranch(String name) async {
    await _service.deleteBranch(name);
    await refreshBranches();
  }

  Future<void> deleteTag(String name) async {
    await _service.deleteTag(name);
    await refreshTags();
  }

  Future<void> checkoutTag(String name) async {
    await _service.checkoutTag(name);
    await loadAll();
  }

  Future<void> stashAndCheckoutTag(String name) async {
    await _service.stash();
    await _service.checkoutTag(name);
    await loadAll();
  }

  Future<void> initRepo() async {
    await _service.init();
    await loadAll();
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter analyze lib/features/git/providers/git_provider.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/providers/git_provider.dart
git commit -m "feat(git): add GitNotifier provider for state management"
```

---

## Task 7: Database — Saved Git Repos (Vault Entry)

**Files:**
- Create: `nexterm/lib/data/database/tables/git_repos_table.dart`
- Create: `nexterm/lib/data/database/daos/git_repos_dao.dart`
- Create: `nexterm/lib/domain/entities/git_repo_entity.dart`
- Create: `nexterm/lib/domain/repositories/git_repo_repository.dart`
- Create: `nexterm/lib/data/repositories/git_repo_repository_impl.dart`
- Create: `nexterm/lib/features/git/providers/git_repos_provider.dart`
- Modify: `nexterm/lib/data/database/app_database.dart`

- [ ] **Step 1: Create git_repos_table.dart**

```dart
// nexterm/lib/data/database/tables/git_repos_table.dart

import 'package:drift/drift.dart';
import 'package:nexterm/data/database/tables/hosts_table.dart';

class GitRepos extends Table {
  TextColumn get id => text()();
  TextColumn get hostId => text().references(Hosts, #id)();
  TextColumn get remotePath => text()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 2: Create git_repo_entity.dart**

```dart
// nexterm/lib/domain/entities/git_repo_entity.dart

class GitRepoEntity {
  final String id;
  final String hostId;
  final String remotePath;
  final String? label;

  const GitRepoEntity({
    required this.id,
    required this.hostId,
    required this.remotePath,
    this.label,
  });

  String get displayName => label ?? remotePath.split('/').last;
}
```

- [ ] **Step 3: Create git_repos_dao.dart**

```dart
// nexterm/lib/data/database/daos/git_repos_dao.dart

import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/git_repos_table.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';

part 'git_repos_dao.g.dart';

@DriftAccessor(tables: [GitRepos])
class GitReposDao extends DatabaseAccessor<AppDatabase> with _$GitReposDaoMixin {
  GitReposDao(super.db);

  GitRepoEntity _rowToEntity(GitRepo row) {
    return GitRepoEntity(
      id: row.id,
      hostId: row.hostId,
      remotePath: row.remotePath,
      label: row.label,
    );
  }

  GitReposCompanion _entityToCompanion(GitRepoEntity entity) {
    return GitReposCompanion(
      id: Value(entity.id),
      hostId: Value(entity.hostId),
      remotePath: Value(entity.remotePath),
      label: Value(entity.label),
    );
  }

  Future<List<GitRepoEntity>> getAll() async {
    final rows = await select(gitRepos).get();
    return rows.map(_rowToEntity).toList();
  }

  Future<GitRepoEntity?> getById(String id) async {
    final row = await (select(gitRepos)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<void> insertRepo(GitRepoEntity entity) =>
      into(gitRepos).insert(_entityToCompanion(entity));

  Future<void> updateRepo(GitRepoEntity entity) =>
      (update(gitRepos)..where((t) => t.id.equals(entity.id)))
          .write(_entityToCompanion(entity));

  Future<void> deleteRepo(String id) =>
      (delete(gitRepos)..where((t) => t.id.equals(id))).go();

  Stream<List<GitRepoEntity>> watchAll() {
    return select(gitRepos).watch().map((rows) => rows.map(_rowToEntity).toList());
  }
}
```

- [ ] **Step 4: Create git_repo_repository.dart (interface)**

```dart
// nexterm/lib/domain/repositories/git_repo_repository.dart

import 'package:nexterm/domain/entities/git_repo_entity.dart';

abstract class GitRepoRepository {
  Future<List<GitRepoEntity>> getAll();
  Future<GitRepoEntity?> getById(String id);
  Future<void> insert(GitRepoEntity entity);
  Future<void> update(GitRepoEntity entity);
  Future<void> delete(String id);
  Stream<List<GitRepoEntity>> watchAll();
}
```

- [ ] **Step 5: Create git_repo_repository_impl.dart**

```dart
// nexterm/lib/data/repositories/git_repo_repository_impl.dart

import 'package:nexterm/data/database/daos/git_repos_dao.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/domain/repositories/git_repo_repository.dart';

class GitRepoRepositoryImpl implements GitRepoRepository {
  final GitReposDao _dao;

  GitRepoRepositoryImpl(this._dao);

  @override
  Future<List<GitRepoEntity>> getAll() => _dao.getAll();

  @override
  Future<GitRepoEntity?> getById(String id) => _dao.getById(id);

  @override
  Future<void> insert(GitRepoEntity entity) => _dao.insertRepo(entity);

  @override
  Future<void> update(GitRepoEntity entity) => _dao.updateRepo(entity);

  @override
  Future<void> delete(String id) => _dao.deleteRepo(id);

  @override
  Stream<List<GitRepoEntity>> watchAll() => _dao.watchAll();
}
```

- [ ] **Step 6: Create git_repos_provider.dart**

```dart
// nexterm/lib/features/git/providers/git_repos_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/daos/git_repos_dao.dart';
import 'package:nexterm/data/repositories/git_repo_repository_impl.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/domain/repositories/git_repo_repository.dart';

final gitRepoRepositoryProvider = Provider<GitRepoRepository>((ref) {
  final db = ref.read(databaseProvider);
  return GitRepoRepositoryImpl(GitReposDao(db));
});

final gitReposStreamProvider = StreamProvider<List<GitRepoEntity>>((ref) {
  return ref.watch(gitRepoRepositoryProvider).watchAll();
});
```

- [ ] **Step 7: Modify app_database.dart — add GitRepos table and bump schema**

In `app_database.dart`:
- Add import for `git_repos_table.dart` and `git_repos_dao.dart`
- Add `GitRepos` to the `@DriftDatabase` tables list
- Add `GitReposDao` to the daos list
- Bump `schemaVersion` from 5 to 6
- Add migration for `from < 6`

The modified `app_database.dart` should look like:

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:nexterm/data/database/tables/hosts_table.dart';
import 'package:nexterm/data/database/tables/ssh_keys_table.dart';
import 'package:nexterm/data/database/tables/snippets_table.dart';
import 'package:nexterm/data/database/tables/port_forwards_table.dart';
import 'package:nexterm/data/database/tables/settings_table.dart';
import 'package:nexterm/data/database/tables/git_repos_table.dart';
import 'package:nexterm/data/database/daos/hosts_dao.dart';
import 'package:nexterm/data/database/daos/ssh_keys_dao.dart';
import 'package:nexterm/data/database/daos/snippets_dao.dart';
import 'package:nexterm/data/database/daos/port_forwards_dao.dart';
import 'package:nexterm/data/database/daos/settings_dao.dart';
import 'package:nexterm/data/database/daos/git_repos_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Hosts, SshKeys, Snippets, PortForwards, AppSettings, GitRepos],
  daos: [HostsDao, SshKeysDao, SnippetsDao, PortForwardsDao, SettingsDao, GitReposDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) await m.createTable(snippets);
        if (from < 3) await m.createTable(portForwards);
        if (from < 4) await m.createTable(appSettings);
        if (from < 5) await m.addColumn(hosts, hosts.startupCommand);
        if (from < 6) await m.createTable(gitRepos);
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nexterm.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 8: Check if databaseProvider exists; if not, note what to add**

The `git_repos_provider.dart` references `databaseProvider`. Check if this already exists in the codebase. If not, you'll need to add it. Search for it:

Run: `grep -r "databaseProvider" /Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/`

If it doesn't exist, add to `app_database.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
```

Or update `git_repos_provider.dart` to match whatever pattern the existing providers use for database access.

- [ ] **Step 9: Run build_runner to generate drift code**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `app_database.g.dart`, `git_repos_dao.g.dart`

- [ ] **Step 10: Verify compilation**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter analyze`
Expected: No errors related to git_repos

- [ ] **Step 11: Commit**

```bash
git add nexterm/lib/data/database/ nexterm/lib/domain/ nexterm/lib/features/git/providers/git_repos_provider.dart
git commit -m "feat(git): add database table, DAO, and provider for saved git repos"
```

---

## Task 8: Git Init Prompt Widget

**Files:**
- Create: `nexterm/lib/features/git/ui/widgets/git_init_prompt.dart`

- [ ] **Step 1: Create git_init_prompt.dart**

Shown when the user navigates to a directory that is not a git repository.

```dart
// nexterm/lib/features/git/ui/widgets/git_init_prompt.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GitInitPrompt extends StatelessWidget {
  final VoidCallback onInit;

  const GitInitPrompt({super.key, required this.onInit});

  void _confirmInit(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.git_initTitle),
        content: Text(l.git_initConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.common_cancel),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(ctx).pop();
              onInit();
            },
            child: Text(l.git_initButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.source_outlined,
            size: 64,
            color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l.git_initTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.git_initMessage,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _confirmInit(context),
            icon: const Icon(Icons.play_arrow),
            label: Text(l.git_initButton),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/git/ui/widgets/git_init_prompt.dart
git commit -m "feat(git): add GitInitPrompt widget for non-repo directories"
```

---

## Task 9: Working Tree Status File List Widget

**Files:**
- Create: `nexterm/lib/features/git/ui/widgets/status_file_list.dart`

- [ ] **Step 1: Create status_file_list.dart**

```dart
// nexterm/lib/features/git/ui/widgets/status_file_list.dart

import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_status.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class StatusFileList extends StatelessWidget {
  final GitStatus status;
  final void Function(GitStatusEntry entry, bool staged) onFileTap;

  const StatusFileList({
    super.key,
    required this.status,
    required this.onFileTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!status.isDirty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 48,
                color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
            const SizedBox(height: 12),
            Text(l.git_noChanges,
                style: TextStyle(
                  color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary)),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (status.staged.isNotEmpty) ...[
          _SectionHeader(title: l.git_staged, count: status.staged.length),
          ...status.staged.map((e) => _FileRow(
            entry: e,
            staged: true,
            onTap: () => onFileTap(e, true),
          )),
        ],
        if (status.unstaged.isNotEmpty) ...[
          _SectionHeader(title: l.git_unstaged, count: status.unstaged.length),
          ...status.unstaged.map((e) => _FileRow(
            entry: e,
            staged: false,
            onTap: () => onFileTap(e, false),
          )),
        ],
        if (status.untracked.isNotEmpty) ...[
          _SectionHeader(title: l.git_untracked, count: status.untracked.length),
          ...status.untracked.map((e) => _FileRow(
            entry: e,
            staged: false,
            onTap: () => onFileTap(e, false),
          )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
              )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: (isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                )),
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final code = staged ? entry.indexStatus : entry.workTreeStatus;
    final fileName = entry.path.split('/').last;
    final dirPath = entry.path.contains('/')
        ? entry.path.substring(0, entry.path.lastIndexOf('/'))
        : '';

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(_statusIcon(code), size: 18, color: _statusColor(code)),
      title: Text(
        fileName,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: dirPath.isNotEmpty
          ? Text(dirPath,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)
          : null,
      onTap: onTap,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/git/ui/widgets/status_file_list.dart
git commit -m "feat(git): add StatusFileList widget for working tree changes"
```

---

## Task 10: Diff View Widget

**Files:**
- Create: `nexterm/lib/features/git/ui/widgets/diff_view.dart`

- [ ] **Step 1: Create diff_view.dart**

Unified diff view with character-level highlighting using `RichText` + `TextSpan`.

```dart
// nexterm/lib/features/git/ui/widgets/diff_view.dart

import 'package:flutter/material.dart';
import 'package:nexterm/features/git/models/git_diff.dart';

class DiffView extends StatelessWidget {
  final List<GitFileDiff> diffs;

  const DiffView({super.key, required this.diffs});

  @override
  Widget build(BuildContext context) {
    if (diffs.isEmpty) {
      return const Center(child: Text('No changes'));
    }

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
  Widget build(BuildContext context) {
    return _FileDiffSection(diff: diff);
  }
}

class _FileDiffSection extends StatelessWidget {
  final GitFileDiff diff;

  const _FileDiffSection({required this.diff});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF2D333B) : const Color(0xFFF6F8FA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: headerBg,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  diff.filePath,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'JetBrains Mono',
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('+${diff.additions}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6BCB77))),
              const SizedBox(width: 4),
              Text('-${diff.deletions}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFE06C75))),
            ],
          ),
        ),
        for (final hunk in diff.hunks) _HunkView(hunk: hunk),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HunkView extends StatelessWidget {
  final DiffHunk hunk;

  const _HunkView({required this.hunk});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hunkHeaderBg = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFDDF4FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: hunkHeaderBg,
          child: Text(
            '@@ -${hunk.oldStart},${hunk.oldCount} +${hunk.newStart},${hunk.newCount} @@${hunk.header != null ? ' ${hunk.header}' : ''}',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'JetBrains Mono',
              color: isDark ? const Color(0xFF79C0FF) : const Color(0xFF0550AE),
            ),
          ),
        ),
        for (final line in hunk.lines) _DiffLineView(line: line),
      ],
    );
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

    return Container(
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: gutterColor,
            child: Text(
              lineNum,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
                color: isDark ? const Color(0xFF484F58) : const Color(0xFF8C959F),
              ),
            ),
          ),
          SizedBox(
            width: 16,
            child: Text(
              prefix,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'JetBrains Mono',
                color: isDark ? const Color(0xFF7D8590) : const Color(0xFF57606A),
              ),
            ),
          ),
          Expanded(
            child: line.inlineChanges.isEmpty
                ? Text(
                    line.content,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'JetBrains Mono',
                      color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328),
                    ),
                  )
                : _buildInlineHighlightedText(context, line),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineHighlightedText(BuildContext context, DiffLine line) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328);

    Color highlightBg;
    if (line.type == DiffLineType.added) {
      highlightBg = isDark ? const Color(0xFF2EA04366) : const Color(0xFFACEEBB);
    } else {
      highlightBg = isDark ? const Color(0xFFDA363866) : const Color(0xFFFFCECB);
    }

    final spans = <TextSpan>[];
    var pos = 0;

    for (final change in line.inlineChanges) {
      if (change.start > pos) {
        spans.add(TextSpan(text: line.content.substring(pos, change.start)));
      }
      final end = change.start + change.length;
      spans.add(TextSpan(
        text: line.content.substring(change.start, end.clamp(0, line.content.length)),
        style: TextStyle(backgroundColor: highlightBg),
      ));
      pos = end;
    }
    if (pos < line.content.length) {
      spans.add(TextSpan(text: line.content.substring(pos)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'JetBrains Mono',
          color: normalColor,
        ),
        children: spans,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/git/ui/widgets/diff_view.dart
git commit -m "feat(git): add DiffView widget with character-level inline highlighting"
```

---

## Task 11: Commit List & Commit Detail Sheet Widgets

**Files:**
- Create: `nexterm/lib/features/git/ui/widgets/commit_list.dart`
- Create: `nexterm/lib/features/git/ui/widgets/commit_detail_sheet.dart`

- [ ] **Step 1: Create commit_list.dart**

```dart
// nexterm/lib/features/git/ui/widgets/commit_list.dart

import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class CommitList extends StatelessWidget {
  final List<GitCommit> commits;
  final void Function(GitCommit commit) onCommitTap;

  const CommitList({super.key, required this.commits, required this.onCommitTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (commits.isEmpty) {
      return Center(child: Text(l.git_noCommits));
    }

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
      title: Text(
        commit.subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            commit.shortSha,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'JetBrains Mono',
              color: OutdoorColors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            commit.authorName,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
            ),
          ),
          const Spacer(),
          Text(
            _timeAgo(commit.timestamp),
            style: TextStyle(
              fontSize: 11,
              color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create commit_detail_sheet.dart**

```dart
// nexterm/lib/features/git/ui/widgets/commit_detail_sheet.dart

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

  const CommitDetailSheet({
    super.key,
    required this.commit,
    required this.gitNotifier,
  });

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
      if (mounted) setState(() { _files = files; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadDiffs() async {
    setState(() { _isLoading = true; _showDiff = true; });
    try {
      final diffs = await widget.gitNotifier.getCommitDiff(widget.commit.sha);
      if (mounted) setState(() { _diffs = diffs; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commit = widget.commit;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 12),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.git_commitDetail,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                    )),
              ),
              const SizedBox(height: 12),
              // SHA
              _DetailRow(label: 'SHA', value: commit.shortSha, onTap: () {
                Clipboard.setData(ClipboardData(text: commit.sha));
              }),
              _DetailRow(label: l.git_author, value: '${commit.authorName} <${commit.authorEmail}>'),
              _DetailRow(label: l.git_date, value: _formatDate(commit.timestamp)),
              const Divider(height: 24),
              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.git_message,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(commit.subject,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                    )),
              ),
              if (commit.body.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(commit.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                      )),
                ),
              const Divider(height: 24),
              // Changed files
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(l.git_changedFiles,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                        )),
                    const Spacer(),
                    if (!_showDiff)
                      TextButton(
                        onPressed: _loadDiffs,
                        child: Text(l.git_diff),
                      ),
                  ],
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_showDiff && _diffs != null)
                ..._diffs!.map((d) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FileDiffView(diff: d),
                ))
              else if (_files != null)
                ...(_files!.map((f) => ListTile(
                  dense: true,
                  leading: _statusIcon(f.status),
                  title: Text(f.path,
                      style: const TextStyle(fontSize: 13, fontFamily: 'JetBrains Mono')),
                ))),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _statusIcon(String status) {
    final (icon, color) = switch (status) {
      'A' => (Icons.add_circle_outline, const Color(0xFF6BCB77)),
      'D' => (Icons.remove_circle_outline, const Color(0xFFE06C75)),
      'M' => (Icons.edit_outlined, const Color(0xFFE5A84B)),
      _ when status.startsWith('R') => (Icons.drive_file_rename_outline, const Color(0xFF4A9EEA)),
      _ => (Icons.circle_outlined, const Color(0xFF888888)),
    };
    return Icon(icon, size: 18, color: color);
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
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
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                  )),
            ),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'JetBrains Mono',
                    color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/ui/widgets/commit_list.dart nexterm/lib/features/git/ui/widgets/commit_detail_sheet.dart
git commit -m "feat(git): add CommitList and CommitDetailSheet widgets"
```

---

## Task 12: Branch List & Tag List Widgets

**Files:**
- Create: `nexterm/lib/features/git/ui/widgets/branch_list.dart`
- Create: `nexterm/lib/features/git/ui/widgets/tag_list.dart`

- [ ] **Step 1: Create branch_list.dart**

```dart
// nexterm/lib/features/git/ui/widgets/branch_list.dart

import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_branch.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class BranchList extends StatelessWidget {
  final List<GitBranch> branches;
  final VoidCallback onBranchGraphTap;
  final Future<void> Function(GitBranch branch) onDeleteBranch;

  const BranchList({
    super.key,
    required this.branches,
    required this.onBranchGraphTap,
    required this.onDeleteBranch,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (branches.isEmpty) {
      return Center(child: Text(l.git_noBranches));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onBranchGraphTap,
              icon: const Icon(Icons.account_tree_outlined, size: 18),
              label: Text(l.git_branchGraph),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: branches.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final branch = branches[index];
              final canDelete = !branch.isCurrent && !branch.isDefault && !branch.isRemote;

              return Dismissible(
                key: Key(branch.name),
                direction: canDelete
                    ? DismissDirection.endToStart
                    : DismissDirection.none,
                confirmDismiss: (_) async {
                  if (!canDelete) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.git_deleteBranchProtected)),
                    );
                    return false;
                  }
                  return true;
                },
                onDismissed: (_) => onDeleteBranch(branch),
                background: Container(
                  color: const Color(0xFFE06C75),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  leading: Icon(
                    branch.isRemote ? Icons.cloud_outlined : Icons.call_split,
                    size: 18,
                    color: branch.isCurrent ? OutdoorColors.accent : (isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary),
                  ),
                  title: Text(
                    branch.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: branch.isCurrent ? FontWeight.w600 : FontWeight.normal,
                      color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (branch.isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: OutdoorColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(l.git_currentBranch,
                              style: TextStyle(fontSize: 10, color: OutdoorColors.accent)),
                        ),
                      const SizedBox(width: 4),
                      Text(branch.shortSha,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'JetBrains Mono',
                            color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Create tag_list.dart**

```dart
// nexterm/lib/features/git/ui/widgets/tag_list.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_tag.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class TagList extends StatelessWidget {
  final List<GitTag> tags;
  final Future<void> Function(GitTag tag) onDeleteTag;
  final Future<void> Function(GitTag tag) onCheckoutTag;

  const TagList({
    super.key,
    required this.tags,
    required this.onDeleteTag,
    required this.onCheckoutTag,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (tags.isEmpty) {
      return Center(child: Text(l.git_noTags));
    }

    return ListView.separated(
      itemCount: tags.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tag = tags[index];
        return Dismissible(
          key: Key(tag.name),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showCupertinoDialog<bool>(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: Text(l.git_deleteTag),
                content: Text(l.git_deleteTagConfirm(tag.name)),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l.common_cancel),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(l.common_delete),
                  ),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) => onDeleteTag(tag),
          background: Container(
            color: const Color(0xFFE06C75),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Icon(Icons.local_offer_outlined, size: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? OutdoorColors.darkFgSecondary
                    : OutdoorColors.lightFgSecondary),
            title: Text(tag.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? OutdoorColors.darkFg
                      : OutdoorColors.lightFg,
                )),
            subtitle: tag.timestamp != null
                ? Text(
                    '${tag.timestamp!.year}-${tag.timestamp!.month.toString().padLeft(2, '0')}-${tag.timestamp!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? OutdoorColors.darkFgTertiary
                            : OutdoorColors.lightFgTertiary),
                  )
                : null,
            trailing: TextButton(
              onPressed: () => onCheckoutTag(tag),
              child: Text(l.git_checkoutTag, style: const TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/ui/widgets/branch_list.dart nexterm/lib/features/git/ui/widgets/tag_list.dart
git commit -m "feat(git): add BranchList and TagList widgets with swipe-to-delete"
```

---

## Task 13: Branch Graph Painter & Screen

**Files:**
- Create: `nexterm/lib/features/git/ui/widgets/branch_graph_painter.dart`
- Create: `nexterm/lib/features/git/ui/widgets/branch_graph_screen.dart`

- [ ] **Step 1: Create branch_graph_painter.dart**

```dart
// nexterm/lib/features/git/ui/widgets/branch_graph_painter.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexterm/features/git/models/git_graph.dart';

class BranchGraphPainter extends CustomPainter {
  final List<GraphRow> rows;
  final double rowHeight;
  final double laneWidth;
  final double dotRadius;

  BranchGraphPainter({
    required this.rows,
    this.rowHeight = 56.0,
    this.laneWidth = 20.0,
    this.dotRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final cy = i * rowHeight + rowHeight / 2;

      // Draw line segments
      for (final line in row.lines) {
        final paint = Paint()
          ..color = graphLaneColors[line.colorIndex % graphLaneColors.length]
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        final fromX = line.fromLane * laneWidth + laneWidth / 2;
        final toX = line.toLane * laneWidth + laneWidth / 2;

        switch (line.type) {
          case GraphLineType.straight:
            canvas.drawLine(
              Offset(toX, cy + rowHeight / 2),
              Offset(toX, cy - rowHeight / 2),
              paint,
            );
          case GraphLineType.mergeLeft:
          case GraphLineType.mergeRight:
            final path = Path()
              ..moveTo(fromX, cy)
              ..cubicTo(fromX, cy + rowHeight * 0.4, toX, cy + rowHeight * 0.1, toX, cy + rowHeight / 2);
            canvas.drawPath(path, paint);
          case GraphLineType.fork:
            final path = Path()
              ..moveTo(fromX, cy)
              ..cubicTo(fromX, cy + rowHeight * 0.4, toX, cy + rowHeight * 0.1, toX, cy + rowHeight / 2);
            canvas.drawPath(path, paint);
        }
      }

      // Draw commit dot
      final cx = row.laneIndex * laneWidth + laneWidth / 2;
      final dotColor = graphLaneColors[row.colorIndex % graphLaneColors.length];

      canvas.drawCircle(
        Offset(cx, cy),
        dotRadius + 1,
        Paint()..color = Colors.black.withValues(alpha: 0.5),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        dotRadius,
        Paint()..color = dotColor,
      );
    }
  }

  @override
  bool shouldRepaint(BranchGraphPainter oldDelegate) =>
      rows != oldDelegate.rows;
}
```

- [ ] **Step 2: Create branch_graph_screen.dart**

The hybrid layout: CustomPainter on the left, synced ListView on the right.

```dart
// nexterm/lib/features/git/ui/widgets/branch_graph_screen.dart

import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_graph.dart';
import 'package:nexterm/features/git/ui/widgets/branch_graph_painter.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class BranchGraphScreen extends StatefulWidget {
  final List<GraphRow> rows;

  const BranchGraphScreen({super.key, required this.rows});

  @override
  State<BranchGraphScreen> createState() => _BranchGraphScreenState();
}

class _BranchGraphScreenState extends State<BranchGraphScreen> {
  final _scrollController = ScrollController();

  static const _rowHeight = 56.0;
  static const _laneWidth = 20.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _maxLanes {
    var max = 1;
    for (final row in widget.rows) {
      if (row.activeLaneCount > max) max = row.activeLaneCount;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final graphWidth = (_maxLanes + 1) * _laneWidth;
    final totalHeight = widget.rows.length * _rowHeight;

    return Scaffold(
      appBar: AppBar(title: Text(l.git_branchGraph)),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: graph lines
              SizedBox(
                width: graphWidth,
                height: totalHeight,
                child: CustomPaint(
                  size: Size(graphWidth, totalHeight),
                  painter: BranchGraphPainter(
                    rows: widget.rows,
                    rowHeight: _rowHeight,
                    laneWidth: _laneWidth,
                  ),
                ),
              ),
              // Right: commit info list
              Expanded(
                child: Column(
                  children: widget.rows.map((row) {
                    final commit = row.commit;
                    final refs = commit.refs.where((r) => r.isNotEmpty).toList();

                    return SizedBox(
                      height: _rowHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    commit.subject,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  commit.shortSha,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'JetBrains Mono',
                                    color: OutdoorColors.accent,
                                  ),
                                ),
                                if (refs.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  ...refs.take(2).map((ref) => Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: graphLaneColors[row.colorIndex % graphLaneColors.length],
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      ref.replaceFirst('HEAD -> ', ''),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: graphLaneColors[row.colorIndex % graphLaneColors.length],
                                      ),
                                    ),
                                  )),
                                ],
                                const Spacer(),
                                Text(
                                  commit.authorName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/ui/widgets/branch_graph_painter.dart nexterm/lib/features/git/ui/widgets/branch_graph_screen.dart
git commit -m "feat(git): add BranchGraphPainter and BranchGraphScreen with synced layout"
```

---

## Task 14: Main Git Screen (Three-Tab Container)

**Files:**
- Create: `nexterm/lib/features/git/ui/git_screen.dart`

- [ ] **Step 1: Create git_screen.dart**

```dart
// nexterm/lib/features/git/ui/git_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_tag.dart';
import 'package:nexterm/features/git/providers/git_provider.dart';
import 'package:nexterm/features/git/services/git_command_service.dart';
import 'package:nexterm/features/git/ui/widgets/branch_graph_screen.dart';
import 'package:nexterm/features/git/ui/widgets/branch_list.dart';
import 'package:nexterm/features/git/ui/widgets/commit_detail_sheet.dart';
import 'package:nexterm/features/git/ui/widgets/commit_list.dart';
import 'package:nexterm/features/git/ui/widgets/diff_view.dart';
import 'package:nexterm/features/git/ui/widgets/git_init_prompt.dart';
import 'package:nexterm/features/git/ui/widgets/status_file_list.dart';
import 'package:nexterm/features/git/ui/widgets/tag_list.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GitScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String remotePath;

  const GitScreen({
    super.key,
    required this.sessionId,
    required this.remotePath,
  });

  @override
  ConsumerState<GitScreen> createState() => _GitScreenState();
}

class _GitScreenState extends ConsumerState<GitScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GitNotifier? _gitNotifier;
  GitState _gitState = const GitState();
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final sshService = ref.read(sshServiceProvider);
      final client = sshService.getClient(widget.sessionId);
      if (client == null) {
        throw StateError('No active SSH session');
      }

      final service = GitCommandService(
        client: client,
        repoPath: widget.remotePath,
      );
      final notifier = GitNotifier(service);

      notifier.addListener(() {
        if (mounted) setState(() => _gitState = notifier.state);
      });

      setState(() {
        _gitNotifier = notifier;
        _isInitializing = false;
      });

      await notifier.loadAll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gitNotifier?.dispose();
    super.dispose();
  }

  void _showCommitDetail(commit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommitDetailSheet(
        commit: commit,
        gitNotifier: _gitNotifier!,
      ),
    );
  }

  void _showFileDiff(entry, bool staged) async {
    final diffs = await _gitNotifier!.getFileDiff(entry.path, staged: staged);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(entry.path.split('/').last)),
          body: DiffView(diffs: diffs),
        ),
      ),
    );
  }

  void _openBranchGraph() async {
    await _gitNotifier!.loadGraph();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BranchGraphScreen(rows: _gitNotifier!.state.graphRows),
      ),
    );
  }

  Future<void> _handleCheckoutTag(GitTag tag) async {
    final l = AppLocalizations.of(context)!;
    final status = _gitState.status;

    if (status != null && status.isDirty) {
      final result = await showCupertinoDialog<String>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(l.git_checkoutDirtyTitle),
          content: Text(l.git_checkoutDirtyMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop('cancel'),
              child: Text(l.common_cancel),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop('stash'),
              child: Text(l.git_stashAndCheckout),
            ),
          ],
        ),
      );
      if (result == 'stash') {
        await _gitNotifier!.stashAndCheckoutTag(tag.name);
      }
    } else {
      await _gitNotifier!.checkoutTag(tag.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Git')),
        body: Center(child: Text(_initError!)),
      );
    }

    if (_gitState.isLoading && !_gitState.isRepo) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_gitState.isRepo) {
      return Scaffold(
        appBar: AppBar(title: const Text('Git')),
        body: GitInitPrompt(onInit: () => _gitNotifier!.initRepo()),
      );
    }

    return _buildMain(context);
  }

  Widget _buildMain(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Git', style: TextStyle(fontSize: 17)),
            Text(
              _gitState.currentBranch,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _gitNotifier!.loadAll(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l.git_tabWorkTree),
            Tab(text: l.git_tabBranches),
            Tab(text: l.git_tabTags),
          ],
        ),
      ),
      body: _gitState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Working Tree tab
                _gitState.status != null
                    ? StatusFileList(
                        status: _gitState.status!,
                        onFileTap: _showFileDiff,
                      )
                    : const SizedBox.shrink(),
                // Branches tab
                BranchList(
                  branches: _gitState.branches,
                  onBranchGraphTap: _openBranchGraph,
                  onDeleteBranch: (branch) => _gitNotifier!.deleteBranch(branch.name),
                ),
                // Tags tab
                TagList(
                  tags: _gitState.tags,
                  onDeleteTag: (tag) => _gitNotifier!.deleteTag(tag.name),
                  onCheckoutTag: _handleCheckoutTag,
                ),
              ],
            ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/git/ui/git_screen.dart
git commit -m "feat(git): add main GitScreen with three-tab layout"
```

---

## Task 15: Git Repos Screen & Form (Vault Entry)

**Files:**
- Create: `nexterm/lib/features/git/ui/git_repos_screen.dart`
- Create: `nexterm/lib/features/git/ui/git_repo_form_screen.dart`

- [ ] **Step 1: Create git_repos_screen.dart**

```dart
// nexterm/lib/features/git/ui/git_repos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/features/git/providers/git_repos_provider.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/services/ssh_service.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class GitReposScreen extends ConsumerWidget {
  const GitReposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final reposAsync = ref.watch(gitReposStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.git_repos),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/vaults/git/add'),
          ),
        ],
      ),
      body: reposAsync.when(
        data: (repos) {
          if (repos.isEmpty) {
            return Center(child: Text(l.git_reposEmpty));
          }
          return ListView.separated(
            itemCount: repos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final repo = repos[index];
              return _RepoTile(repo: repo);
            },
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.git_connecting)),
    );

    try {
      final sessionId = await ref.read(terminalActionsProvider).connectHost(repo.hostId);
      if (sessionId != null && context.mounted) {
        context.push('/git/$sessionId?path=${Uri.encodeComponent(repo.remotePath)}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.common_error(e.toString())}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hostAsync = ref.watch(hostByIdProvider(repo.hostId));

    return ListTile(
      leading: Icon(Icons.source_outlined, size: 24,
          color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary),
      title: Text(repo.displayName),
      subtitle: hostAsync.when(
        data: (host) => Text(
          host != null ? '${host.name} · ${repo.remotePath}' : repo.remotePath,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
          ),
        ),
        loading: () => Text(repo.remotePath),
        error: (_, __) => Text(repo.remotePath),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () => _connect(context, ref),
    );
  }
}
```

- [ ] **Step 2: Create git_repo_form_screen.dart**

```dart
// nexterm/lib/features/git/ui/git_repo_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/features/git/providers/git_repos_provider.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class GitRepoFormScreen extends ConsumerStatefulWidget {
  final String? repoId;

  const GitRepoFormScreen({super.key, this.repoId});

  @override
  ConsumerState<GitRepoFormScreen> createState() => _GitRepoFormScreenState();
}

class _GitRepoFormScreenState extends ConsumerState<GitRepoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _pathController = TextEditingController();
  String? _selectedHostId;

  @override
  void dispose() {
    _labelController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHostId == null) return;

    final repo = GitRepoEntity(
      id: widget.repoId ?? const Uuid().v4(),
      hostId: _selectedHostId!,
      remotePath: _pathController.text.trim(),
      label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
    );

    final repository = ref.read(gitRepoRepositoryProvider);
    if (widget.repoId != null) {
      await repository.update(repo);
    } else {
      await repository.insert(repo);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.watch(hostsStreamProvider);
    final isEdit = widget.repoId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.git_editRepo : l.git_addRepo),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l.common_save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: l.git_repoLabel,
                hintText: l.git_repoLabelHint,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pathController,
              decoration: InputDecoration(
                labelText: l.git_repoPath,
                hintText: l.git_repoPathHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            hostsAsync.when(
              data: (hosts) => DropdownButtonFormField<String>(
                value: _selectedHostId,
                decoration: InputDecoration(labelText: l.git_selectHost),
                items: hosts.map((h) => DropdownMenuItem(
                  value: h.id,
                  child: Text(h.name),
                )).toList(),
                onChanged: (v) => setState(() => _selectedHostId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/git/ui/git_repos_screen.dart nexterm/lib/features/git/ui/git_repo_form_screen.dart
git commit -m "feat(git): add GitReposScreen and GitRepoFormScreen for Vault entry"
```

---

## Task 16: Routing & Entry Point Integration

**Files:**
- Modify: `nexterm/lib/core/router/app_router.dart`
- Modify: `nexterm/lib/features/vaults/ui/vaults_screen.dart`
- Modify: `nexterm/lib/features/sftp/ui/sftp_screen.dart`
- Modify: `nexterm/lib/features/terminal/ui/widgets/function_panel.dart`

- [ ] **Step 1: Add git routes to app_router.dart**

Add imports at the top:
```dart
import 'package:nexterm/features/git/ui/git_screen.dart';
import 'package:nexterm/features/git/ui/git_repos_screen.dart';
import 'package:nexterm/features/git/ui/git_repo_form_screen.dart';
```

Add routes inside the Vault branch (under the `forwarding` route, before the closing `]` of routes):
```dart
GoRoute(
  path: 'git',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => const GitReposScreen(),
  routes: [
    GoRoute(path: 'add', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const GitRepoFormScreen()),
    GoRoute(path: 'edit/:id', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => GitRepoFormScreen(repoId: state.pathParameters['id'])),
  ],
),
```

Add standalone git screen route (after the `/sftp/edit` route):
```dart
GoRoute(
  path: '/git/:sessionId',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => GitScreen(
    sessionId: state.pathParameters['sessionId']!,
    remotePath: state.uri.queryParameters['path'] ?? '.',
  ),
),
```

- [ ] **Step 2: Add Git entry to vaults_screen.dart**

Add a new `GlassCard` for Git repos in the Vault screen, after the forwarding entry and before the Keychain section:

```dart
GlassCard(
  onTap: () => context.push('/vaults/git'),
  child: _VaultItem(icon: Icons.source_outlined, title: l.git_repos),
),
```

- [ ] **Step 3: Add SFTP .git detection to sftp_screen.dart**

In the `_buildMain` method of `SftpScreen`, add a FAB or app bar action that appears when `.git` is detected. After checking `state.visibleFiles`, add an action in the `appBar.actions`:

Add an import at the top of sftp_screen.dart:
```dart
import 'package:go_router/go_router.dart';
```

In the `actions` list of the AppBar (after the existing `PopupMenuButton`), add:
```dart
if (_sftpState.visibleFiles.any((f) => f.isDirectory && f.name == '.git'))
  IconButton(
    icon: const Icon(Icons.source_outlined),
    tooltip: l.git_openGit,
    onPressed: () {
      context.push('/git/${widget.sessionId}?path=${Uri.encodeComponent(_sftpState.currentPath)}');
    },
  ),
```

Make sure `go_router` is imported and the localization key `git_openGit` is available (added in Task 5).

- [ ] **Step 4: Add Git button to function_panel.dart**

In `FunctionPanel`, change the `TabController` length from 3 to 4 and add a Git tab. Add the following icon to the `tabs` list:

```dart
Tab(icon: Icon(Icons.source_outlined, size: 18)),
```

Add the corresponding tab content in `TabBarView.children`. This tab will show a button to open Git for the current terminal session's working directory:

```dart
widget.sessionId != null
    ? _GitTab(sessionId: widget.sessionId!)
    : _EmptyTab(message: l.function_noActiveSession),
```

Create the `_GitTab` widget class at the bottom of function_panel.dart:

```dart
class _GitTab extends ConsumerWidget {
  final String sessionId;
  const _GitTab({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.source_outlined, size: 40,
              color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final sshService = ref.read(sshServiceProvider);
              final client = sshService.getClient(sessionId);
              if (client == null) return;

              try {
                final session = await client.execute('pwd');
                final stdoutBytes = await session.stdout.toList();
                final pwd = String.fromCharCodes(
                    stdoutBytes.expand((b) => b)).trim();
                await session.done;

                if (context.mounted) {
                  GoRouter.of(context).push(
                      '/git/$sessionId?path=${Uri.encodeComponent(pwd)}');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            icon: const Icon(Icons.folder_open),
            label: Text(l.git_openGit),
          ),
        ],
      ),
    );
  }
}
```

Add the necessary imports to `function_panel.dart`:
```dart
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
```

- [ ] **Step 5: Verify compilation**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter analyze`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add nexterm/lib/core/router/app_router.dart nexterm/lib/features/vaults/ui/vaults_screen.dart nexterm/lib/features/sftp/ui/sftp_screen.dart nexterm/lib/features/terminal/ui/widgets/function_panel.dart
git commit -m "feat(git): integrate git management with routing and three entry points"
```

---

## Task 17: Final Verification

- [ ] **Step 1: Run full analysis**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter analyze`
Expected: No errors

- [ ] **Step 2: Run build to verify compilation**

Run: `cd /Users/yitouxiaomaolv/git/Nexterm/nexterm && flutter build ios --no-codesign --debug 2>&1 | tail -20`
Expected: Build succeeds (or at least no compilation errors related to git feature)

- [ ] **Step 3: Fix any issues found and commit**

If any errors appear, fix them and create a new commit.
