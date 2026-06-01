import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/smb_connections_table.dart';
import 'package:nexterm/domain/entities/smb_connection_entity.dart';

part 'smb_connections_dao.g.dart';

@DriftAccessor(tables: [SmbConnections])
class SmbConnectionsDao extends DatabaseAccessor<AppDatabase> with _$SmbConnectionsDaoMixin {
  SmbConnectionsDao(super.db);

  SmbConnectionEntity _rowToEntity(SmbConnection row) {
    return SmbConnectionEntity(
      id: row.id,
      name: row.name,
      host: row.host,
      port: row.port,
      shareName: row.shareName,
      username: row.username,
      password: row.password,
      domain: row.domain,
      lastConnected: row.lastConnected,
      sortOrder: row.sortOrder,
    );
  }

  SmbConnectionsCompanion _entityToCompanion(SmbConnectionEntity entity) {
    return SmbConnectionsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      host: Value(entity.host),
      port: Value(entity.port),
      shareName: Value(entity.shareName),
      username: Value(entity.username),
      password: Value(entity.password),
      domain: Value(entity.domain),
      lastConnected: Value(entity.lastConnected),
      sortOrder: Value(entity.sortOrder),
    );
  }

  Future<List<SmbConnectionEntity>> getAll() async {
    return (await select(smbConnections).get()).map(_rowToEntity).toList();
  }

  Future<SmbConnectionEntity?> getById(String id) async {
    final row = await (select(smbConnections)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<void> insertConnection(SmbConnectionEntity entity) => into(smbConnections).insert(_entityToCompanion(entity));
  Future<void> updateConnection(SmbConnectionEntity entity) => (update(smbConnections)..where((t) => t.id.equals(entity.id))).write(_entityToCompanion(entity));
  Future<void> deleteConnection(String id) => (delete(smbConnections)..where((t) => t.id.equals(id))).go();

  Stream<List<SmbConnectionEntity>> watchAll() {
    return select(smbConnections).watch().map((rows) => rows.map(_rowToEntity).toList());
  }
}
