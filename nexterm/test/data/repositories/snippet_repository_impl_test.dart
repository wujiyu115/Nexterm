import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/repositories/snippet_repository_impl.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';

void main() {
  late AppDatabase db;
  late SnippetRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SnippetRepositoryImpl(db.snippetsDao);
  });
  tearDown(() => db.close());

  SnippetEntity makeSnippet({
    String id = 's1',
    String name = 'Deploy Script',
    String command = 'kubectl apply -f \${FILE}',
    List<SnippetVariable> variables = const [],
  }) {
    return SnippetEntity(
      id: id,
      name: name,
      command: command,
      variables: variables,
    );
  }

  test('insert and getAll returns snippet', () async {
    await repo.insert(makeSnippet());
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.first.name, equals('Deploy Script'));
  });

  test('variables are persisted and restored', () async {
    final snippet = makeSnippet(
      variables: [
        const SnippetVariable(name: 'FILE', defaultValue: 'deployment.yaml', description: 'The k8s manifest'),
        const SnippetVariable(name: 'NS', defaultValue: 'default'),
      ],
    );
    await repo.insert(snippet);
    final loaded = await repo.getById('s1');
    expect(loaded, isNotNull);
    expect(loaded!.variables, hasLength(2));
    expect(loaded.variables.first.name, equals('FILE'));
    expect(loaded.variables.first.defaultValue, equals('deployment.yaml'));
    expect(loaded.variables.first.description, equals('The k8s manifest'));
    expect(loaded.variables[1].name, equals('NS'));
  });

  test('search by name finds matching snippet', () async {
    await repo.insert(makeSnippet(id: 's1', name: 'Deploy to Production'));
    await repo.insert(makeSnippet(id: 's2', name: 'Restart Service', command: 'systemctl restart nginx'));
    final results = await repo.search('deploy');
    expect(results, hasLength(1));
    expect(results.first.name, contains('Deploy'));
  });

  test('search by command finds matching snippet', () async {
    await repo.insert(makeSnippet(id: 's1', name: 'K8s Apply', command: 'kubectl apply -f \${FILE}'));
    await repo.insert(makeSnippet(id: 's2', name: 'Nginx Restart', command: 'systemctl restart nginx'));
    final results = await repo.search('kubectl');
    expect(results, hasLength(1));
    expect(results.first.id, equals('s1'));
  });

  test('delete removes snippet', () async {
    await repo.insert(makeSnippet());
    await repo.delete('s1');
    expect(await repo.getAll(), isEmpty);
  });

  test('update modifies snippet', () async {
    await repo.insert(makeSnippet());
    await repo.update(makeSnippet().copyWith(name: 'Updated Name'));
    final loaded = await repo.getById('s1');
    expect(loaded!.name, equals('Updated Name'));
  });

  test('watchAll emits current list', () async {
    await repo.insert(makeSnippet(id: 's1', name: 'Snippet A'));
    await repo.insert(makeSnippet(id: 's2', name: 'Snippet B'));
    final list = await repo.watchAll().first;
    expect(list, hasLength(2));
  });

  test('tags are persisted', () async {
    await repo.insert(makeSnippet().copyWith(tags: ['devops', 'k8s']));
    final loaded = await repo.getById('s1');
    expect(loaded!.tags, equals(['devops', 'k8s']));
  });

  test('isFavorite is persisted', () async {
    await repo.insert(makeSnippet().copyWith(isFavorite: true));
    final loaded = await repo.getById('s1');
    expect(loaded!.isFavorite, isTrue);
  });
}
