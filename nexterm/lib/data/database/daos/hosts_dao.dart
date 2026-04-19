import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/hosts_table.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';

part 'hosts_dao.g.dart';

@DriftAccessor(tables: [Hosts])
class HostsDao extends DatabaseAccessor<AppDatabase> with _$HostsDaoMixin {
  HostsDao(super.db);

  HostEntity _rowToEntity(Host row) {
    return HostEntity(
      id: row.id,
      name: row.name,
      hostname: row.hostname,
      port: row.port,
      username: row.username,
      authMethod: AuthMethod.values.byName(row.authMethod),
      password: row.password,
      keyId: row.keyId,
      group: row.group,
      tags: (jsonDecode(row.tags) as List).cast<String>(),
      isFavorite: row.isFavorite,
      jumpHosts: (jsonDecode(row.jumpHosts) as List).cast<String>(),
      startupSnippetId: row.startupSnippetId,
      lastConnected: row.lastConnected,
      sortOrder: row.sortOrder,
    );
  }

  HostsCompanion _entityToCompanion(HostEntity entity) {
    return HostsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      hostname: Value(entity.hostname),
      port: Value(entity.port),
      username: Value(entity.username),
      authMethod: Value(entity.authMethod.name),
      password: Value(entity.password),
      keyId: Value(entity.keyId),
      group: Value(entity.group),
      tags: Value(jsonEncode(entity.tags)),
      isFavorite: Value(entity.isFavorite),
      jumpHosts: Value(jsonEncode(entity.jumpHosts)),
      startupSnippetId: Value(entity.startupSnippetId),
      lastConnected: Value(entity.lastConnected),
      sortOrder: Value(entity.sortOrder),
      updatedAt: Value(DateTime.now()),
    );
  }

  Future<List<HostEntity>> getAll() async {
    final rows = await (select(hosts)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();
    return rows.map(_rowToEntity).toList();
  }

  Future<HostEntity?> getById(String id) async {
    final row = await (select(hosts)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<List<HostEntity>> getByGroup(String? group) async {
    final query = select(hosts);
    if (group == null) {
      query.where((t) => t.group.isNull());
    } else {
      query.where((t) => t.group.equals(group));
    }
    return (await query.get()).map(_rowToEntity).toList();
  }

  Future<List<HostEntity>> getFavorites() async {
    return (await (select(hosts)..where((t) => t.isFavorite.equals(true))).get()).map(_rowToEntity).toList();
  }

  Future<List<HostEntity>> search(String query) async {
    final pattern = '%$query%';
    return (await (select(hosts)..where((t) => t.name.like(pattern) | t.hostname.like(pattern) | t.tags.like(pattern))).get()).map(_rowToEntity).toList();
  }

  Future<void> insertHost(HostEntity entity) => into(hosts).insert(_entityToCompanion(entity));
  Future<void> updateHost(HostEntity entity) => (update(hosts)..where((t) => t.id.equals(entity.id))).write(_entityToCompanion(entity));
  Future<void> deleteHost(String id) => (delete(hosts)..where((t) => t.id.equals(id))).go();
  Future<void> deleteMultiple(List<String> ids) => (delete(hosts)..where((t) => t.id.isIn(ids))).go();

  Stream<List<HostEntity>> watchAll() {
    return (select(hosts)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).watch().map((rows) => rows.map(_rowToEntity).toList());
  }
}
