/// Service that records and retrieves command history per terminal session.
///
/// Commands are stored in-memory, keyed by session ID. A helper method can
/// fetch remote shell history via an SSH session.
class CommandHistoryService {
  /// In-memory store: sessionId → list of commands (most recent last).
  final Map<String, List<String>> _history = {};

  /// Buffer for the current line being typed, keyed by session ID.
  final Map<String, StringBuffer> _lineBuffers = {};

  // -------------------------------------------------------------------------
  // Recording
  // -------------------------------------------------------------------------

  /// Called when the user types output into the terminal.
  ///
  /// We accumulate characters and treat `\r` or `\n` as a command submission.
  void onUserInput(String sessionId, String data) {
    final buffer = _lineBuffers.putIfAbsent(sessionId, () => StringBuffer());

    for (final char in data.codeUnits) {
      if (char == 0x0D || char == 0x0A) {
        // Enter pressed — record the buffered line.
        final command = buffer.toString().trim();
        if (command.isNotEmpty) {
          _history.putIfAbsent(sessionId, () => []);
          // Avoid consecutive duplicates.
          final list = _history[sessionId]!;
          if (list.isEmpty || list.last != command) {
            list.add(command);
          }
        }
        buffer.clear();
      } else if (char == 0x7F || char == 0x08) {
        // Backspace / DEL — remove last char from buffer.
        final s = buffer.toString();
        if (s.isNotEmpty) {
          buffer.clear();
          buffer.write(s.substring(0, s.length - 1));
        }
      } else if (char >= 0x20) {
        // Printable character.
        buffer.writeCharCode(char);
      }
      // Ignore other control characters.
    }
  }

  // -------------------------------------------------------------------------
  // Retrieval
  // -------------------------------------------------------------------------

  /// Returns all recorded commands for [sessionId], most recent last.
  List<String> getAll(String sessionId) {
    return List.unmodifiable(_history[sessionId] ?? []);
  }

  /// Fuzzy-searches recorded commands for [sessionId].
  List<String> search(String sessionId, String query) {
    final all = _history[sessionId] ?? [];
    if (query.isEmpty) return List.unmodifiable(all);
    final lower = query.toLowerCase();
    return all.where((cmd) => cmd.toLowerCase().contains(lower)).toList();
  }

  /// Clears history for a specific session.
  void clearSession(String sessionId) {
    _history.remove(sessionId);
    _lineBuffers.remove(sessionId);
  }

  /// Clears all history.
  void clearAll() {
    _history.clear();
    _lineBuffers.clear();
  }

  // -------------------------------------------------------------------------
  // Remote history
  // -------------------------------------------------------------------------

  /// Builds a shell command string that can be sent via SSH to fetch the
  /// remote shell history. The caller is responsible for sending this command
  /// and parsing the output.
  static String get fetchRemoteHistoryCommand =>
      'HISTFILE=~/.bash_history && history 100';
}
