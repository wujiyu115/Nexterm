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
    return (await select(gitRepos).get()).map(_rowToEntity).toList();
  }

  Future<GitRepoEntity?> getById(String id) async {
    final row = await (select(gitRepos)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<void> insertRepo(GitRepoEntity entity) => into(gitRepos).insert(_entityToCompanion(entity));
  Future<void> updateRepo(GitRepoEntity entity) => (update(gitRepos)..where((t) => t.id.equals(entity.id))).write(_entityToCompanion(entity));
  Future<void> deleteRepo(String id) => (delete(gitRepos)..where((t) => t.id.equals(id))).go();

  Stream<List<GitRepoEntity>> watchAll() {
    return select(gitRepos).watch().map((rows) => rows.map(_rowToEntity).toList());
  }
}
