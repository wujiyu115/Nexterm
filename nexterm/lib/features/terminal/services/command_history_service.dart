import 'package:nexterm/data/database/daos/command_history_dao.dart';

class CommandHistoryService {
  final CommandHistoryDao _dao;

  CommandHistoryService(this._dao);

  /// In-memory store: sessionId → list of commands (most recent last).
  final Map<String, List<String>> _history = {};

  /// Buffer for the current line being typed, keyed by session ID.
  final Map<String, StringBuffer> _lineBuffers = {};

  /// Maps sessionId → hostId for DB persistence.
  final Map<String, String> _sessionHostMap = {};

  // -------------------------------------------------------------------------
  // Registration
  // -------------------------------------------------------------------------

  void registerSession(String sessionId, String hostId) {
    _sessionHostMap[sessionId] = hostId;
  }

  // -------------------------------------------------------------------------
  // Recording
  // -------------------------------------------------------------------------

  void onUserInput(String sessionId, String data) {
    final buffer = _lineBuffers.putIfAbsent(sessionId, () => StringBuffer());

    for (final char in data.codeUnits) {
      if (char == 0x0D || char == 0x0A) {
        final command = buffer.toString().trim();
        if (command.isNotEmpty) {
          _history.putIfAbsent(sessionId, () => []);
          final list = _history[sessionId]!;
          if (list.isEmpty || list.last != command) {
            list.add(command);
          }
          _persistCommand(sessionId, command);
        }
        buffer.clear();
      } else if (char == 0x7F || char == 0x08) {
        final s = buffer.toString();
        if (s.isNotEmpty) {
          buffer.clear();
          buffer.write(s.substring(0, s.length - 1));
        }
      } else if (char >= 0x20) {
        buffer.writeCharCode(char);
      }
    }
  }

  void _persistCommand(String sessionId, String command) {
    final hostId = _sessionHostMap[sessionId];
    if (hostId == null) return;
    _dao.recordCommand(hostId, command);
  }

  // -------------------------------------------------------------------------
  // Retrieval (in-memory, for current session)
  // -------------------------------------------------------------------------

  List<String> getAll(String sessionId) {
    return List.unmodifiable(_history[sessionId] ?? []);
  }

  List<String> search(String sessionId, String query) {
    final all = _history[sessionId] ?? [];
    if (query.isEmpty) return List.unmodifiable(all);
    final lower = query.toLowerCase();
    return all.where((cmd) => cmd.toLowerCase().contains(lower)).toList();
  }

  // -------------------------------------------------------------------------
  // Retrieval (from DB, cross-session)
  // -------------------------------------------------------------------------

  Future<List<CommandHistoryEntry>> getHostHistory(String hostId,
      {int limit = 500}) async {
    final rows = await _dao.getByHost(hostId, limit: limit);
    return rows
        .map((r) => CommandHistoryEntry(
              command: r.command,
              frequency: r.frequency,
              lastUsedAt: r.lastUsedAt,
            ))
        .toList();
  }

  Future<List<CommandHistoryEntry>> searchAll(String query,
      {String? hostId}) async {
    final rows = await _dao.search(query, hostId: hostId);
    return rows
        .map((r) => CommandHistoryEntry(
              command: r.command,
              frequency: r.frequency,
              lastUsedAt: r.lastUsedAt,
              hostId: r.hostId,
            ))
        .toList();
  }

  Stream<List<CommandHistoryEntry>> watchHostHistory(String hostId) {
    return _dao.watchByHost(hostId).map((rows) => rows
        .map((r) => CommandHistoryEntry(
              command: r.command,
              frequency: r.frequency,
              lastUsedAt: r.lastUsedAt,
            ))
        .toList());
  }

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  void clearSession(String sessionId) {
    _history.remove(sessionId);
    _lineBuffers.remove(sessionId);
    _sessionHostMap.remove(sessionId);
  }

  void clearAll() {
    _history.clear();
    _lineBuffers.clear();
    _sessionHostMap.clear();
  }

  Future<void> pruneHost(String hostId, {int maxEntries = 500}) async {
    await _dao.pruneHost(hostId, maxEntries: maxEntries);
  }
}

class CommandHistoryEntry {
  final String command;
  final int frequency;
  final DateTime lastUsedAt;
  final String? hostId;

  const CommandHistoryEntry({
    required this.command,
    required this.frequency,
    required this.lastUsedAt,
    this.hostId,
  });
}
