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
    final sw = Stopwatch()..start();
    _update(_state.copyWith(isLoading: true, error: () => null));
    try {
      final status = await _service.status();
      assert(() { debugPrint('[Git] loadAll: status done ${sw.elapsedMilliseconds}ms'); return true; }());
      _update(_state.copyWith(
        isLoading: false,
        isRepo: true,
        status: () => status,
        currentBranch: status.currentBranch,
      ));
      await Future.wait([
        refreshBranches(),
        refreshTags(),
      ]);
      assert(() { debugPrint('[Git] loadAll: all done ${sw.elapsedMilliseconds}ms'); return true; }());
    } on GitCommandException catch (e) {
      assert(() { debugPrint('[Git] loadAll: status failed ${sw.elapsedMilliseconds}ms, checking repo'); return true; }());
      final check = await _service.isGitRepo();
      if (!check.isRepo) {
        _update(_state.copyWith(isLoading: false, isRepo: false, error: () => check.error));
      } else {
        _update(_state.copyWith(isLoading: false, isRepo: true, error: () => e.toString()));
      }
    } catch (e) {
      _update(_state.copyWith(isLoading: false, isRepo: true, error: () => e.toString()));
    }
  }

  List<GitCommit> _graphCommits = [];

  Future<void> loadGraph() async {
    try {
      _graphCommits = await _service.logAll();
      final rows = GraphLayoutService.computeLayout(_graphCommits);
      _update(_state.copyWith(graphRows: rows));
    } catch (e) {
      assert(() { debugPrint('[Git] loadGraph error: $e'); return true; }());
    }
  }

  Future<List<GraphRow>> loadMoreGraph({
    required int skip,
    required List<GraphRow> existingRows,
  }) async {
    final moreCommits = await _service.logAll(skip: skip);
    if (moreCommits.isEmpty) return existingRows;
    _graphCommits = [..._graphCommits, ...moreCommits];
    final rows = GraphLayoutService.computeLayout(_graphCommits);
    _update(_state.copyWith(graphRows: rows));
    return rows;
  }

  Future<void> refreshStatus() async {
    final sw = Stopwatch()..start();
    try {
      final status = await _service.status();
      assert(() { debugPrint('[Git] refreshStatus ${sw.elapsedMilliseconds}ms'); return true; }());
      _update(_state.copyWith(
        status: () => status,
        currentBranch: status.currentBranch,
      ));
    } catch (e) {
      assert(() { debugPrint('[Git] refreshStatus error ${sw.elapsedMilliseconds}ms: $e'); return true; }());
    }
  }

  Future<void> refreshBranches() async {
    final sw = Stopwatch()..start();
    try {
      final branches = await _service.branches();
      assert(() { debugPrint('[Git] refreshBranches ${sw.elapsedMilliseconds}ms count=${branches.length}'); return true; }());
      _update(_state.copyWith(branches: branches));
    } catch (e) {
      assert(() { debugPrint('[Git] refreshBranches error ${sw.elapsedMilliseconds}ms: $e'); return true; }());
    }
  }

  Future<void> refreshTags() async {
    final sw = Stopwatch()..start();
    try {
      final tags = await _service.tags();
      assert(() { debugPrint('[Git] refreshTags ${sw.elapsedMilliseconds}ms count=${tags.length}'); return true; }());
      _update(_state.copyWith(tags: tags));
    } catch (e) {
      assert(() { debugPrint('[Git] refreshTags error ${sw.elapsedMilliseconds}ms: $e'); return true; }());
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
    bool untracked = false,
  }) async {
    if (untracked) {
      return DiffParser.parse(await _service.diffNewFile(filePath));
    }
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
