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
