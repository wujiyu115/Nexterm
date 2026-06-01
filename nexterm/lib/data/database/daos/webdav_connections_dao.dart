import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/webdav_connections_table.dart';
import 'package:nexterm/domain/entities/webdav_connection_entity.dart';

part 'webdav_connections_dao.g.dart';

@DriftAccessor(tables: [WebdavConnections])
class WebdavConnectionsDao extends DatabaseAccessor<AppDatabase> with _$WebdavConnectionsDaoMixin {
  WebdavConnectionsDao(super.db);

  WebdavConnectionEntity _rowToEntity(WebdavConnection row) {
    return WebdavConnectionEntity(
      id: row.id,
      name: row.name,
      url: row.url,
      username: row.username,
      password: row.password,
      lastConnected: row.lastConnected,
      sortOrder: row.sortOrder,
    );
  }

  WebdavConnectionsCompanion _entityToCompanion(WebdavConnectionEntity entity) {
    return WebdavConnectionsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      url: Value(entity.url),
      username: Value(entity.username),
      password: Value(entity.password),
      lastConnected: Value(entity.lastConnected),
      sortOrder: Value(entity.sortOrder),
    );
  }

  Future<List<WebdavConnectionEntity>> getAll() async {
    return (await select(webdavConnections).get()).map(_rowToEntity).toList();
  }

  Future<WebdavConnectionEntity?> getById(String id) async {
    final row = await (select(webdavConnections)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<void> insertConnection(WebdavConnectionEntity entity) => into(webdavConnections).insert(_entityToCompanion(entity));
  Future<void> updateConnection(WebdavConnectionEntity entity) => (update(webdavConnections)..where((t) => t.id.equals(entity.id))).write(_entityToCompanion(entity));
  Future<void> deleteConnection(String id) => (delete(webdavConnections)..where((t) => t.id.equals(id))).go();

  Stream<List<WebdavConnectionEntity>> watchAll() {
    return select(webdavConnections).watch().map((rows) => rows.map(_rowToEntity).toList());
  }
}
