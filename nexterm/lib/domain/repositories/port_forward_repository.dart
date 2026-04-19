import 'package:nexterm/domain/entities/port_forward_entity.dart';

abstract class PortForwardRepository {
  Future<List<PortForwardEntity>> getAll();
  Future<List<PortForwardEntity>> getByHostId(String hostId);
  Future<List<PortForwardEntity>> getAutoStartByHostId(String hostId);
  Future<PortForwardEntity?> getById(String id);
  Future<void> insert(PortForwardEntity forward);
  Future<void> update(PortForwardEntity forward);
  Future<void> delete(String id);
  Stream<List<PortForwardEntity>> watchAll();
  Stream<List<PortForwardEntity>> watchByHostId(String hostId);
}
