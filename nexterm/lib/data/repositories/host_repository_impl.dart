import 'package:nexterm/data/database/daos/hosts_dao.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/repositories/host_repository.dart';

class HostRepositoryImpl implements HostRepository {
  final HostsDao _dao;
  HostRepositoryImpl(this._dao);

  @override Future<List<HostEntity>> getAll() => _dao.getAll();
  @override Future<HostEntity?> getById(String id) => _dao.getById(id);
  @override Future<List<HostEntity>> getByGroup(String? group) => _dao.getByGroup(group);
  @override Future<List<HostEntity>> getFavorites() => _dao.getFavorites();
  @override Future<List<HostEntity>> search(String query) => _dao.search(query);
  @override Future<void> insert(HostEntity host) => _dao.insertHost(host);
  @override Future<void> update(HostEntity host) => _dao.updateHost(host);
  @override Future<void> delete(String id) => _dao.deleteHost(id);
  @override Future<void> deleteMultiple(List<String> ids) => _dao.deleteMultiple(ids);
  @override Stream<List<HostEntity>> watchAll() => _dao.watchAll();
}
