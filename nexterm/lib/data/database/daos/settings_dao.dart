import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<void> deleteValue(String key) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(appSettings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Stream<Map<String, String>> watchAll() {
    return select(appSettings).watch().map((rows) => {for (final r in rows) r.key: r.value});
  }
}
