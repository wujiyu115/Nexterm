import 'package:nexterm/domain/entities/ssh_key_entity.dart';

abstract class SSHKeyRepository {
  Future<List<SSHKeyEntity>> getAll();
  Future<SSHKeyEntity?> getById(String id);
  Future<void> insert(SSHKeyEntity key);
  Future<void> update(SSHKeyEntity key);
  Future<void> delete(String id);
  Stream<List<SSHKeyEntity>> watchAll();
}
