import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/repositories/git_repo_repository_impl.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/domain/repositories/git_repo_repository.dart';
import 'package:nexterm/main.dart';

final gitRepoRepositoryProvider = Provider<GitRepoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GitRepoRepositoryImpl(db.gitReposDao);
});

final gitReposStreamProvider = StreamProvider<List<GitRepoEntity>>((ref) {
  return ref.watch(gitRepoRepositoryProvider).watchAll();
});

final gitRepoSearchProvider = FutureProvider.family<List<GitRepoEntity>, String>((ref, query) {
  final db = ref.watch(databaseProvider);
  return db.gitReposDao.search(query);
});
