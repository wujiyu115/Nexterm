import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/port_forwards_table.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';

part 'port_forwards_dao.g.dart';

@DriftAccessor(tables: [PortForwards])
class PortForwardsDao extends DatabaseAccessor<AppDatabase> with _$PortForwardsDaoMixin {
  PortForwardsDao(super.db);

  PortForwardEntity _rowToEntity(PortForward row) {
    return PortForwardEntity(
      id: row.id,
      name: row.name,
      type: ForwardType.values.byName(row.type),
      hostId: row.hostId,
      localPort: row.localPort,
      remoteHost: row.remoteHost,
      remotePort: row.remotePort,
      bindAddress: row.bindAddress,
      autoStart: row.autoStart,
    );
  }

  PortForwardsCompanion _entityToCompanion(PortForwardEntity entity) {
    return PortForwardsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.name),
      hostId: Value(entity.hostId),
      localPort: Value(entity.localPort),
      remoteHost: Value(entity.remoteHost),
      remotePort: Value(entity.remotePort),
      bindAddress: Value(entity.bindAddress),
      autoStart: Value(entity.autoStart),
    );
  }

  Future<List<PortForwardEntity>> getAll() async {
    return (await select(portForwards).get()).map(_rowToEntity).toList();
  }

  Future<List<PortForwardEntity>> getByHostId(String hostId) async {
    return (await (select(portForwards)..where((t) => t.hostId.equals(hostId))).get())
        .map(_rowToEntity)
        .toList();
  }

  Future<List<PortForwardEntity>> getAutoStartByHostId(String hostId) async {
    return (await (select(portForwards)
          ..where((t) => t.hostId.equals(hostId) & t.autoStart.equals(true)))
        .get())
        .map(_rowToEntity)
        .toList();
  }

  Future<PortForwardEntity?> getById(String id) async {
    final row = await (select(portForwards)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<void> insertForward(PortForwardEntity entity) =>
      into(portForwards).insert(_entityToCompanion(entity));
  Future<void> updateForward(PortForwardEntity entity) =>
      (update(portForwards)..where((t) => t.id.equals(entity.id))).write(_entityToCompanion(entity));
  Future<void> deleteForward(String id) => (delete(portForwards)..where((t) => t.id.equals(id))).go();

  Stream<List<PortForwardEntity>> watchAll() {
    return select(portForwards).watch().map((rows) => rows.map(_rowToEntity).toList());
  }

  Stream<List<PortForwardEntity>> watchByHostId(String hostId) {
    return (select(portForwards)..where((t) => t.hostId.equals(hostId)))
        .watch()
        .map((rows) => rows.map(_rowToEntity).toList());
  }
}
