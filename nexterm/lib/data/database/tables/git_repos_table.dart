import 'package:drift/drift.dart';
import 'package:nexterm/data/database/tables/hosts_table.dart';

class GitRepos extends Table {
  TextColumn get id => text()();
  TextColumn get hostId => text().references(Hosts, #id)();
  TextColumn get remotePath => text()();
  TextColumn get label => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
