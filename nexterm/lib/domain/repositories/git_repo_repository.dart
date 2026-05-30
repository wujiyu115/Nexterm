import 'package:nexterm/domain/entities/git_repo_entity.dart';

abstract class GitRepoRepository {
  Future<List<GitRepoEntity>> getAll();
  Future<GitRepoEntity?> getById(String id);
  Future<void> insert(GitRepoEntity entity);
  Future<void> update(GitRepoEntity entity);
  Future<void> delete(String id);
  Stream<List<GitRepoEntity>> watchAll();
}
