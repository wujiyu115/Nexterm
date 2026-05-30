import 'package:flutter/foundation.dart';
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
      final check = await _service.isGitRepo();
      if (!check.isRepo) {
        _update(_state.copyWith(isLoading: false, isRepo: false, error: () => check.error));
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
      _update(_state.copyWith(isLoading: false, isRepo: true, error: () => e.toString()));
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
      _update(_state.copyWith(branches: await _service.branches()));
    } catch (e) {
      debugPrint('refreshBranches error: $e');
    }
  }

  Future<void> refreshTags() async {
    try {
      _update(_state.copyWith(tags: await _service.tags()));
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

  Future<List<GitFileDiff>> getFileDiff(
    String filePath, {
    bool staged = false,
  }) async {
    return DiffParser.parse(await _service.diffFile(filePath, staged: staged));
  }

  Future<List<GitFileDiff>> getCommitDiff(String sha) async {
    return DiffParser.parse(await _service.diffCommit(sha));
  }

  Future<List<CommitFileChange>> getCommitFiles(String sha) async {
    return await _service.commitFiles(sha);
  }

  Future<List<GitCommit>> getFileHistory(String filePath) async {
    return await _service.log(filePath: filePath);
  }

  Future<List<GitCommit>> getBranchLog(String branch) async {
    return await _service.log(branch: branch);
  }

  Future<List<GitFileDiff>> getCommitFileDiff(String sha, String filePath) async {
    return DiffParser.parse(await _service.diffCommitFile(sha, filePath));
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
