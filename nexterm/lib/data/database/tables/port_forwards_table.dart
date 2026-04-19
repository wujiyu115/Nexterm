import 'package:drift/drift.dart';

class PortForwards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get type => text()();
  TextColumn get hostId => text()();
  IntColumn get localPort => integer()();
  TextColumn get remoteHost => text().nullable()();
  IntColumn get remotePort => integer().nullable()();
  TextColumn get bindAddress => text().withDefault(const Constant('127.0.0.1'))();
  BoolColumn get autoStart => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
