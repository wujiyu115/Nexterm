import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/repositories/host_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';

void main() {
  late AppDatabase db;
  late HostRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = HostRepositoryImpl(db.hostsDao);
  });
  tearDown(() => db.close());

  HostEntity _makeHost({String id = 'h1', String name = 'Test Server'}) {
    return HostEntity(id: id, name: name, hostname: '192.168.1.1', username: 'admin', authMethod: AuthMethod.password, password: 'secret');
  }

  test('insert and getAll returns host', () async {
    await repo.insert(_makeHost());
    final hosts = await repo.getAll();
    expect(hosts, hasLength(1));
    expect(hosts.first.name, equals('Test Server'));
  });

  test('getById returns matching host', () async {
    await repo.insert(_makeHost(id: 'h1'));
    final host = await repo.getById('h1');
    expect(host, isNotNull);
    expect(host!.id, equals('h1'));
  });

  test('getById returns null for missing id', () async {
    expect(await repo.getById('missing'), isNull);
  });

  test('update modifies host', () async {
    await repo.insert(_makeHost());
    await repo.update(_makeHost().copyWith(name: 'Updated'));
    final host = await repo.getById('h1');
    expect(host!.name, equals('Updated'));
  });

  test('delete removes host', () async {
    await repo.insert(_makeHost());
    await repo.delete('h1');
    expect(await repo.getAll(), isEmpty);
  });

  test('search finds by name', () async {
    await repo.insert(_makeHost(name: 'Production Server'));
    await repo.insert(_makeHost(id: 'h2', name: 'Staging DB'));
    final results = await repo.search('prod');
    expect(results, hasLength(1));
  });

  test('getFavorites returns only favorites', () async {
    await repo.insert(_makeHost(id: 'h1'));
    await repo.insert(_makeHost(id: 'h2').copyWith(isFavorite: true));
    final favorites = await repo.getFavorites();
    expect(favorites, hasLength(1));
    expect(favorites.first.id, equals('h2'));
  });

  test('tags are persisted', () async {
    await repo.insert(_makeHost().copyWith(tags: ['web', 'prod']));
    final host = await repo.getById('h1');
    expect(host!.tags, equals(['web', 'prod']));
  });
}
