import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/repositories/port_forward_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';

void main() {
  late AppDatabase db;
  late PortForwardRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PortForwardRepositoryImpl(db.portForwardsDao);
  });
  tearDown(() => db.close());

  PortForwardEntity makeForward({
    String id = 'f1',
    String hostId = 'host1',
    ForwardType type = ForwardType.local,
    bool autoStart = false,
  }) {
    return PortForwardEntity(
      id: id,
      name: 'Test Forward',
      type: type,
      hostId: hostId,
      localPort: 8080,
      remoteHost: 'example.com',
      remotePort: 80,
      autoStart: autoStart,
    );
  }

  test('insert and getAll returns forward', () async {
    await repo.insert(makeForward());
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.first.name, equals('Test Forward'));
  });

  test('getByHostId filters correctly', () async {
    await repo.insert(makeForward(id: 'f1', hostId: 'host1'));
    await repo.insert(makeForward(id: 'f2', hostId: 'host2'));
    final byHost1 = await repo.getByHostId('host1');
    expect(byHost1, hasLength(1));
    expect(byHost1.first.id, equals('f1'));

    final byHost2 = await repo.getByHostId('host2');
    expect(byHost2, hasLength(1));
    expect(byHost2.first.id, equals('f2'));
  });

  test('getAutoStartByHostId returns only autoStart forwards', () async {
    await repo.insert(makeForward(id: 'f1', hostId: 'host1', autoStart: false));
    await repo.insert(makeForward(id: 'f2', hostId: 'host1', autoStart: true));
    final autoStart = await repo.getAutoStartByHostId('host1');
    expect(autoStart, hasLength(1));
    expect(autoStart.first.id, equals('f2'));
  });

  test('delete removes forward', () async {
    await repo.insert(makeForward());
    await repo.delete('f1');
    final all = await repo.getAll();
    expect(all, isEmpty);
  });

  test('getById returns matching forward', () async {
    await repo.insert(makeForward(id: 'f1'));
    final forward = await repo.getById('f1');
    expect(forward, isNotNull);
    expect(forward!.id, equals('f1'));
  });

  test('getById returns null for missing id', () async {
    expect(await repo.getById('missing'), isNull);
  });

  test('update modifies forward', () async {
    await repo.insert(makeForward());
    await repo.update(makeForward().copyWith(localPort: 9090));
    final forward = await repo.getById('f1');
    expect(forward!.localPort, equals(9090));
  });

  test('watchAll emits list on insert', () async {
    final stream = repo.watchAll();
    await repo.insert(makeForward());
    final result = await stream.first;
    expect(result, hasLength(1));
  });
}
