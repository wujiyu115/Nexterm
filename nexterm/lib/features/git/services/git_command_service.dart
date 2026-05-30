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

  GitCommandException({required this.command, required this.exitCode, required this.stderr});

  @override
  String toString() => 'GitCommandException: "$command" exited with $exitCode: $stderr';
}

class GitCommandResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  const GitCommandResult({required this.stdout, required this.stderr, required this.exitCode});
}

class GitCommandService {
  final SSHClient _client;
  final String _repoPath;

  GitCommandService({required SSHClient client, required String repoPath})
      : _client = client,
        _repoPath = repoPath;

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
      throw GitCommandException(command: command, exitCode: result.exitCode, stderr: result.stderr);
    }
    return result.stdout;
  }

  String _shellEscape(String s) => "'${s.replaceAll("'", "'\\''")}'";

  // Repo detection & init
  Future<bool> isGitRepo() async {
    final result = await _exec('rev-parse --git-dir');
    return result.exitCode == 0;
  }

  Future<void> init() async => await _run('init');

  Future<String> currentBranch() async {
    final output = await _run('rev-parse --abbrev-ref HEAD');
    return output.trim();
  }

  // Commit history
  static const _commitFormat = '%H%x00%an%x00%ae%x00%at%x00%s%x00%b%x1e';

  Future<List<GitCommit>> log({int limit = 100, String? filePath}) async {
    var cmd = 'log --format=$_commitFormat -n $limit';
    if (filePath != null) cmd += ' --follow -- ${_shellEscape(filePath)}';
    final output = await _run(cmd);
    return _parseCommits(output);
  }

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
            (int.tryParse(fields[3]) ?? 0) * 1000, isUtc: true),
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
      final parentShas = fields[1].trim().isEmpty ? <String>[] : fields[1].trim().split(' ');
      final refsStr = fields[4].trim();
      final refs = refsStr.isEmpty ? <String>[] : refsStr.split(', ').map((r) => r.trim()).toList();
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

  // Branches
  Future<List<GitBranch>> branches() async {
    final output = await _run("branch -a --format=%(refname:short)%x00%(objectname:short)%x00%(HEAD)");
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

  Future<void> deleteBranch(String name) async => await _run('branch -d ${_shellEscape(name)}');

  // Tags
  Future<List<GitTag>> tags() async {
    final output = await _run("tag -l --format=%(refname:short)%x00%(objectname:short)%x00%(creatordate:unix)");
    if (output.trim().isEmpty) return [];
    final lines = output.trim().split('\n').where((l) => l.isNotEmpty);
    return lines.map((line) {
      final parts = line.split('\x00');
      if (parts.length < 3) return null;
      final ts = int.tryParse(parts[2].trim());
      return GitTag(
        name: parts[0],
        shortSha: parts[1],
        timestamp: ts != null && ts > 0 ? DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true) : null,
      );
    }).whereType<GitTag>().toList();
  }

  Future<void> deleteTag(String name) async => await _run('tag -d ${_shellEscape(name)}');
  Future<void> checkoutTag(String name) async => await _run('checkout ${_shellEscape(name)}');
  Future<void> stash() async => await _run('stash');

  // Status
  Future<GitStatus> status() async {
    final branchName = await currentBranch();
    final output = await _run('status --porcelain=v2');
    final entries = <GitStatusEntry>[];

    for (final line in output.split('\n').where((l) => l.isNotEmpty)) {
      if (line.startsWith('1 ')) {
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

  // Diff
  Future<String> diffUnstaged() async => await _run('diff');
  Future<String> diffStaged() async => await _run('diff --cached');
  Future<String> diffCommit(String sha) async => await _run('diff-tree -p $sha');

  Future<String> diffFile(String filePath, {bool staged = false}) async {
    final flag = staged ? '--cached' : '';
    return await _run('diff $flag -- ${_shellEscape(filePath)}');
  }

  // Commit file list
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

  const CommitFileChange({required this.status, required this.path, this.oldPath});

  String get statusLabel => switch (status) {
    'A' => 'Added',
    'D' => 'Deleted',
    'M' => 'Modified',
    _ when status.startsWith('R') => 'Renamed',
    _ when status.startsWith('C') => 'Copied',
    _ => status,
  };
}
