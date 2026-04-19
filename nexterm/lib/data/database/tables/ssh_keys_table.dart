import 'package:drift/drift.dart';

class SshKeys extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get type => text()();
  TextColumn get privateKey => text()();
  TextColumn get publicKey => text()();
  TextColumn get fingerprint => text()();
  TextColumn get passphrase => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
