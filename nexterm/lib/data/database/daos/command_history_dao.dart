import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/command_history_table.dart';

part 'command_history_dao.g.dart';

@DriftAccessor(tables: [CommandHistory])
class CommandHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$CommandHistoryDaoMixin {
  CommandHistoryDao(super.db);

  Future<void> recordCommand(String hostId, String command) async {
    final existing = await (select(commandHistory)
          ..where(
              (t) => t.hostId.equals(hostId) & t.command.equals(command)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(commandHistory)..where((t) => t.id.equals(existing.id)))
          .write(CommandHistoryCompanion(
        frequency: Value(existing.frequency + 1),
        lastUsedAt: Value(DateTime.now()),
      ));
    } else {
      await into(commandHistory).insert(CommandHistoryCompanion(
        hostId: Value(hostId),
        command: Value(command),
        frequency: const Value(1),
        lastUsedAt: Value(DateTime.now()),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  Future<List<CommandHistoryData>> getByHost(String hostId,
      {int limit = 500}) async {
    return (select(commandHistory)
          ..where((t) => t.hostId.equals(hostId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.frequency, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.lastUsedAt, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<CommandHistoryData>> search(String query,
      {String? hostId}) async {
    final pattern = '%$query%';
    final q = select(commandHistory)
      ..where((t) {
        final like = t.command.like(pattern);
        if (hostId != null) {
          return like & t.hostId.equals(hostId);
        }
        return like;
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.frequency, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.lastUsedAt, mode: OrderingMode.desc),
      ])
      ..limit(100);
    return q.get();
  }

  Future<void> pruneHost(String hostId, {int maxEntries = 500}) async {
    final count = await (selectOnly(commandHistory)
          ..where(commandHistory.hostId.equals(hostId))
          ..addColumns([commandHistory.id.count()]))
        .map((row) => row.read(commandHistory.id.count())!)
        .getSingle();

    if (count > maxEntries) {
      final toDelete = count - maxEntries;
      final oldest = await (select(commandHistory)
            ..where((t) => t.hostId.equals(hostId))
            ..orderBy([(t) => OrderingTerm(expression: t.lastUsedAt)])
            ..limit(toDelete))
          .get();

      for (final entry in oldest) {
        await (delete(commandHistory)..where((t) => t.id.equals(entry.id)))
            .go();
      }
    }
  }

  Stream<List<CommandHistoryData>> watchByHost(String hostId) {
    return (select(commandHistory)
          ..where((t) => t.hostId.equals(hostId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.frequency, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.lastUsedAt, mode: OrderingMode.desc),
          ])
          ..limit(500))
        .watch();
  }

  Future<void> deleteAll() async {
    await delete(commandHistory).go();
  }
}
