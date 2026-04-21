import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/services/command_history_service.dart';

/// Singleton [CommandHistoryService] shared across the app.
final commandHistoryServiceProvider = Provider<CommandHistoryService>((ref) {
  final service = CommandHistoryService();
  ref.onDispose(() => service.clearAll());
  return service;
});

/// Provider that returns the command history list for a given session ID.
///
/// Usage: `ref.watch(commandHistoryProvider(sessionId))`
///
/// Note: This is a simple Provider.family — it reads the current snapshot.
/// For reactive updates, the UI should call `ref.invalidate` after recording
/// new commands, or use a StateNotifier wrapper.
final commandHistoryProvider =
    Provider.family<List<String>, String>((ref, sessionId) {
  final service = ref.watch(commandHistoryServiceProvider);
  return service.getAll(sessionId);
});
