import 'package:drift/drift.dart';

class CommandHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hostId => text()();
  TextColumn get command => text()();
  IntColumn get frequency => integer().withDefault(const Constant(1))();
  DateTimeColumn get lastUsedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {hostId, command},
      ];
}
