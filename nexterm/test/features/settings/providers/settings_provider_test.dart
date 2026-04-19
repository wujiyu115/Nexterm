import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/main.dart';

/// Creates a [ProviderContainer] backed by an in-memory database.
ProviderContainer _makeContainer() {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
    ],
  );
}

void main() {
  group('SettingsNotifier', () {
    late ProviderContainer container;
    late SettingsNotifier notifier;

    setUp(() {
      container = _makeContainer();
      notifier = container.read(settingsNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('set writes value and get retrieves it', () async {
      await notifier.set('theme', 'dark');
      expect(notifier.get('theme'), equals('dark'));
    });

    test('get returns defaultValue when key is absent', () {
      expect(notifier.get('missing_key'), equals(''));
      expect(notifier.get('missing_key', defaultValue: 'fallback'),
          equals('fallback'));
    });

    test('getInt parses valid int string', () async {
      await notifier.set('font_size', '18');
      expect(notifier.getInt('font_size'), equals(18));
    });

    test('getInt returns default for non-numeric value', () async {
      await notifier.set('font_size', 'big');
      expect(notifier.getInt('font_size', defaultValue: 14), equals(14));
    });

    test('getInt returns default when key absent', () {
      expect(notifier.getInt('absent', defaultValue: 99), equals(99));
    });

    group('getBool', () {
      test('returns true for stored "true"', () async {
        await notifier.set('haptic', 'true');
        expect(notifier.getBool('haptic'), isTrue);
      });

      test('returns false for stored "false"', () async {
        await notifier.set('haptic', 'false');
        expect(notifier.getBool('haptic'), isFalse);
      });

      test('returns defaultValue when key is absent', () {
        expect(notifier.getBool('absent', defaultValue: true), isTrue);
        expect(notifier.getBool('absent2', defaultValue: false), isFalse);
      });

      test('returns defaultValue for non-boolean string', () async {
        await notifier.set('haptic', 'yes');
        expect(notifier.getBool('haptic', defaultValue: true), isTrue);
      });
    });

    test('remove deletes key from state', () async {
      await notifier.set('temp_key', 'value');
      expect(notifier.get('temp_key'), equals('value'));

      await notifier.remove('temp_key');
      expect(notifier.get('temp_key'), equals(''));
    });

    test('remove is a no-op for non-existent key', () async {
      // Should not throw
      await notifier.remove('non_existent');
      expect(notifier.state, isEmpty);
    });

    test('load populates state from DB', () async {
      // Write directly to the DB bypassing the notifier's state.
      final db = container.read(databaseProvider);
      await db.settingsDao.setValue('persisted_key', 'hello');

      // A freshly-created notifier should pick it up via load().
      final container2 = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
      ]);
      addTearDown(container2.dispose);

      final freshNotifier =
          container2.read(settingsNotifierProvider.notifier);
      // The provider calls load() during construction; allow microtasks to settle.
      await Future.microtask(() {});
      await freshNotifier.load();

      expect(freshNotifier.get('persisted_key'), equals('hello'));
    });

    test('set multiple keys accumulates state', () async {
      await notifier.set('k1', 'v1');
      await notifier.set('k2', 'v2');
      expect(notifier.get('k1'), equals('v1'));
      expect(notifier.get('k2'), equals('v2'));
    });

    test('set overwrites existing key', () async {
      await notifier.set('theme', 'light');
      await notifier.set('theme', 'dark');
      expect(notifier.get('theme'), equals('dark'));
    });
  });
}
