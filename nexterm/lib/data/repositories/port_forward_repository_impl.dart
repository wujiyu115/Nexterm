import 'package:nexterm/data/database/daos/port_forwards_dao.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/domain/repositories/port_forward_repository.dart';

class PortForwardRepositoryImpl implements PortForwardRepository {
  final PortForwardsDao _dao;
  PortForwardRepositoryImpl(this._dao);

  @override Future<List<PortForwardEntity>> getAll() => _dao.getAll();
  @override Future<List<PortForwardEntity>> getByHostId(String hostId) => _dao.getByHostId(hostId);
  @override Future<List<PortForwardEntity>> getAutoStartByHostId(String hostId) => _dao.getAutoStartByHostId(hostId);
  @override Future<PortForwardEntity?> getById(String id) => _dao.getById(id);
  @override Future<void> insert(PortForwardEntity forward) => _dao.insertForward(forward);
  @override Future<void> update(PortForwardEntity forward) => _dao.updateForward(forward);
  @override Future<void> delete(String id) => _dao.deleteForward(id);
  @override Stream<List<PortForwardEntity>> watchAll() => _dao.watchAll();
  @override Stream<List<PortForwardEntity>> watchByHostId(String hostId) => _dao.watchByHostId(hostId);
}
