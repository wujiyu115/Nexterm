import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/repositories/ssh_key_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

void main() {
  late AppDatabase db;
  late SSHKeyRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SSHKeyRepositoryImpl(db.sshKeysDao);
  });
  tearDown(() => db.close());

  SSHKeyEntity makeKey({String id = 'k1'}) {
    return SSHKeyEntity(id: id, name: 'Test Key', type: KeyType.ed25519, privateKey: 'private-data', publicKey: 'ssh-ed25519 AAAA...', fingerprint: 'SHA256:abc123', createdAt: DateTime(2026, 1, 1));
  }

  test('insert and getAll', () async {
    await repo.insert(makeKey());
    final keys = await repo.getAll();
    expect(keys, hasLength(1));
    expect(keys.first.name, equals('Test Key'));
  });

  test('getById returns matching key', () async {
    await repo.insert(makeKey());
    final key = await repo.getById('k1');
    expect(key, isNotNull);
    expect(key!.fingerprint, equals('SHA256:abc123'));
  });

  test('delete removes key', () async {
    await repo.insert(makeKey());
    await repo.delete('k1');
    expect(await repo.getAll(), isEmpty);
  });

  test('update modifies key', () async {
    await repo.insert(makeKey());
    await repo.update(makeKey().copyWith(name: 'Renamed'));
    final key = await repo.getById('k1');
    expect(key!.name, equals('Renamed'));
  });
}
