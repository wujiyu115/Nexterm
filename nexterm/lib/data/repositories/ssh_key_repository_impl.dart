import 'package:nexterm/data/database/daos/ssh_keys_dao.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/domain/repositories/ssh_key_repository.dart';

class SSHKeyRepositoryImpl implements SSHKeyRepository {
  final SshKeysDao _dao;
  SSHKeyRepositoryImpl(this._dao);

  @override Future<List<SSHKeyEntity>> getAll() => _dao.getAll();
  @override Future<SSHKeyEntity?> getById(String id) => _dao.getById(id);
  @override Future<void> insert(SSHKeyEntity key) => _dao.insertKey(key);
  @override Future<void> update(SSHKeyEntity key) => _dao.updateKey(key);
  @override Future<void> delete(String id) => _dao.deleteKey(id);
  @override Stream<List<SSHKeyEntity>> watchAll() => _dao.watchAll();
}
