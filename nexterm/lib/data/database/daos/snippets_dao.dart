import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/snippets_table.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';

part 'snippets_dao.g.dart';

@DriftAccessor(tables: [Snippets])
class SnippetsDao extends DatabaseAccessor<AppDatabase> with _$SnippetsDaoMixin {
  SnippetsDao(super.db);

  SnippetEntity _rowToEntity(Snippet row) {
    final variablesList = (jsonDecode(row.variables) as List)
        .map((v) => SnippetVariable.fromJson(v as Map<String, dynamic>))
        .toList();
    return SnippetEntity(
      id: row.id,
      name: row.name,
      command: row.command,
      variables: variablesList,
      group: row.group,
      tags: (jsonDecode(row.tags) as List).cast<String>(),
      isFavorite: row.isFavorite,
      sortOrder: row.sortOrder,
    );
  }

  SnippetsCompanion _entityToCompanion(SnippetEntity entity) {
    return SnippetsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      command: Value(entity.command),
      variables: Value(jsonEncode(entity.variables.map((v) => v.toJson()).toList())),
      group: Value(entity.group),
      tags: Value(jsonEncode(entity.tags)),
      isFavorite: Value(entity.isFavorite),
      sortOrder: Value(entity.sortOrder),
      updatedAt: Value(DateTime.now()),
    );
  }

  Future<List<SnippetEntity>> getAll() async {
    final rows = await (select(snippets)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
    return rows.map(_rowToEntity).toList();
  }

  Future<SnippetEntity?> getById(String id) async {
    final row = await (select(snippets)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<List<SnippetEntity>> search(String query) async {
    final pattern = '%$query%';
    return (await (select(snippets)
          ..where((t) => t.name.like(pattern) | t.command.like(pattern) | t.tags.like(pattern)))
        .get())
        .map(_rowToEntity)
        .toList();
  }

  Future<void> insertSnippet(SnippetEntity entity) => into(snippets).insert(_entityToCompanion(entity));
  Future<void> updateSnippet(SnippetEntity entity) =>
      (update(snippets)..where((t) => t.id.equals(entity.id))).write(_entityToCompanion(entity));
  Future<void> deleteSnippet(String id) => (delete(snippets)..where((t) => t.id.equals(id))).go();

  Stream<List<SnippetEntity>> watchAll() {
    return (select(snippets)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_rowToEntity).toList());
  }
}
