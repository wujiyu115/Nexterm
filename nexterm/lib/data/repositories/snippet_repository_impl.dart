import 'package:nexterm/data/database/daos/snippets_dao.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/domain/repositories/snippet_repository.dart';

class SnippetRepositoryImpl implements SnippetRepository {
  final SnippetsDao _dao;
  SnippetRepositoryImpl(this._dao);

  @override Future<List<SnippetEntity>> getAll() => _dao.getAll();
  @override Future<SnippetEntity?> getById(String id) => _dao.getById(id);
  @override Future<List<SnippetEntity>> search(String query) => _dao.search(query);
  @override Future<void> insert(SnippetEntity snippet) => _dao.insertSnippet(snippet);
  @override Future<void> update(SnippetEntity snippet) => _dao.updateSnippet(snippet);
  @override Future<void> delete(String id) => _dao.deleteSnippet(id);
  @override Stream<List<SnippetEntity>> watchAll() => _dao.watchAll();
}
