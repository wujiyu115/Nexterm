import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/services/command_history_service.dart';
import 'package:nexterm/main.dart';

/// Singleton [CommandHistoryService] shared across the app.
final commandHistoryServiceProvider = Provider<CommandHistoryService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = CommandHistoryService(db.commandHistoryDao);
  ref.onDispose(() => service.clearAll());
  return service;
});

/// Provider that returns the command history list for a given session ID.
final commandHistoryProvider =
    Provider.family<List<String>, String>((ref, sessionId) {
  final service = ref.watch(commandHistoryServiceProvider);
  return service.getAll(sessionId);
});

/// Stream provider for persistent host-level command history.
final hostCommandHistoryProvider =
    StreamProvider.family<List<CommandHistoryEntry>, String>((ref, hostId) {
  final service = ref.watch(commandHistoryServiceProvider);
  return service.watchHostHistory(hostId);
});
