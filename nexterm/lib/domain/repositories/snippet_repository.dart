import 'package:nexterm/domain/entities/snippet_entity.dart';

abstract class SnippetRepository {
  Future<List<SnippetEntity>> getAll();
  Future<SnippetEntity?> getById(String id);
  Future<List<SnippetEntity>> search(String query);
  Future<void> insert(SnippetEntity snippet);
  Future<void> update(SnippetEntity snippet);
  Future<void> delete(String id);
  Stream<List<SnippetEntity>> watchAll();
}
