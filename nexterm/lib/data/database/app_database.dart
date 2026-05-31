import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:nexterm/data/database/tables/hosts_table.dart';
import 'package:nexterm/data/database/tables/ssh_keys_table.dart';
import 'package:nexterm/data/database/tables/snippets_table.dart';
import 'package:nexterm/data/database/tables/port_forwards_table.dart';
import 'package:nexterm/data/database/tables/settings_table.dart';
import 'package:nexterm/data/database/tables/git_repos_table.dart';
import 'package:nexterm/data/database/daos/hosts_dao.dart';
import 'package:nexterm/data/database/daos/ssh_keys_dao.dart';
import 'package:nexterm/data/database/daos/snippets_dao.dart';
import 'package:nexterm/data/database/daos/port_forwards_dao.dart';
import 'package:nexterm/data/database/daos/settings_dao.dart';
import 'package:nexterm/data/database/daos/git_repos_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Hosts, SshKeys, Snippets, PortForwards, AppSettings, GitRepos],
  daos: [HostsDao, SshKeysDao, SnippetsDao, PortForwardsDao, SettingsDao, GitReposDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) await m.createTable(snippets);
        if (from < 3) await m.createTable(portForwards);
        if (from < 4) await m.createTable(appSettings);
        if (from < 5) await m.addColumn(hosts, hosts.startupCommand);
        if (from < 6) await m.createTable(gitRepos);
        if (from < 7) await m.addColumn(hosts, hosts.lastConnectionType);
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nexterm.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
