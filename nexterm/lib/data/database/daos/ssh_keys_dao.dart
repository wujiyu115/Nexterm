import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/ssh_keys_table.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

part 'ssh_keys_dao.g.dart';

@DriftAccessor(tables: [SshKeys])
class SshKeysDao extends DatabaseAccessor<AppDatabase> with _$SshKeysDaoMixin {
  SshKeysDao(super.db);

  SSHKeyEntity _rowToEntity(SshKey row) {
    return SSHKeyEntity(
      id: row.id,
      name: row.name,
      type: KeyType.values.byName(row.type),
      privateKey: row.privateKey,
      publicKey: row.publicKey,
      fingerprint: row.fingerprint,
      passphrase: row.passphrase,
      createdAt: row.createdAt,
    );
  }

  SshKeysCompanion _entityToCompanion(SSHKeyEntity entity) {
    return SshKeysCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.name),
      privateKey: Value(entity.privateKey),
      publicKey: Value(entity.publicKey),
      fingerprint: Value(entity.fingerprint),
      passphrase: Value(entity.passphrase),
      createdAt: Value(entity.createdAt),
    );
  }

  Future<List<SSHKeyEntity>> getAll() async => (await select(sshKeys).get()).map(_rowToEntity).toList();
  Future<SSHKeyEntity?> getById(String id) async {
    final row = await (select(sshKeys)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }
  Future<void> insertKey(SSHKeyEntity entity) => into(sshKeys).insert(_entityToCompanion(entity));
  Future<void> updateKey(SSHKeyEntity entity) => (update(sshKeys)..where((t) => t.id.equals(entity.id))).write(_entityToCompanion(entity));
  Future<void> deleteKey(String id) => (delete(sshKeys)..where((t) => t.id.equals(id))).go();
  Stream<List<SSHKeyEntity>> watchAll() => select(sshKeys).watch().map((rows) => rows.map(_rowToEntity).toList());
}
