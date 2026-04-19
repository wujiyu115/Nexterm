import 'package:nexterm/domain/entities/host_entity.dart';

abstract class HostRepository {
  Future<List<HostEntity>> getAll();
  Future<HostEntity?> getById(String id);
  Future<List<HostEntity>> getByGroup(String? group);
  Future<List<HostEntity>> getFavorites();
  Future<List<HostEntity>> search(String query);
  Future<void> insert(HostEntity host);
  Future<void> update(HostEntity host);
  Future<void> delete(String id);
  Future<void> deleteMultiple(List<String> ids);
  Stream<List<HostEntity>> watchAll();
}
