import 'package:drift/drift.dart';

class Hosts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get hostname => text().withLength(min: 1, max: 255)();
  IntColumn get port => integer().withDefault(const Constant(22))();
  TextColumn get username => text().withLength(min: 1, max: 255)();
  TextColumn get authMethod => text()();
  TextColumn get password => text().nullable()();
  TextColumn get keyId => text().nullable()();
  TextColumn get group => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get jumpHosts => text().withDefault(const Constant('[]'))();
  TextColumn get startupSnippetId => text().nullable()();
  TextColumn get startupCommand => text().nullable()();
  DateTimeColumn get lastConnected => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
