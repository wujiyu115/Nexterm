import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/features/multiplexer/services/multiplexer_service.dart';

class TmuxMultiplexerService implements MultiplexerService {
  static const _timeout = Duration(seconds: 5);

  @override
  MultiplexerType get type => MultiplexerType.tmux;

  @override
  String get displayName => 'Tmux';

  @override
  IconData get icon => Icons.view_week_outlined;

  @override
  Future<bool> isInstalled(SSHClient client) async {
    try {
      final result = await client.run('command -v tmux 2>/dev/null').timeout(_timeout);
      return utf8.decode(result, allowMalformed: true).trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static const _sep = '|||';

  @override
  Future<List<MuxSession>> listSessions(SSHClient client) async {
    try {
      final result = await client
          .run('tmux list-sessions -F "#{session_name}$_sep#{session_windows}$_sep#{session_attached}$_sep#{session_created}$_sep#{session_last_attached}" 2>/dev/null')
          .timeout(_timeout);
      final output = utf8.decode(result, allowMalformed: true).trim();
      if (output.isEmpty) return [];

      return output.split('\n').where((l) => l.contains(_sep)).map((line) {
        final parts = line.split(_sep);
        return MuxSession(
          name: parts[0],
          windows: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
          attachedCount: parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
          created: _parseTimestamp(parts.length > 3 ? parts[3] : null),
          lastActivity: _parseTimestamp(parts.length > 4 ? parts[4] : null),
          type: MultiplexerType.tmux,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  DateTime? _parseTimestamp(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value);
    if (seconds == null || seconds <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  @override
  Future<void> killSession(SSHClient client, String sessionName) async {
    await client.run('tmux kill-session -t ${_shellEscape(sessionName)} 2>/dev/null').timeout(_timeout);
  }

  @override
  Future<void> renameSession(SSHClient client, String oldName, String newName) async {
    await client.run('tmux rename-session -t ${_shellEscape(oldName)} ${_shellEscape(newName)} 2>/dev/null').timeout(_timeout);
  }

  String _shellEscape(String s) => "'${s.replaceAll("'", r"'\''")}'";

  @override
  String attachCommand(String sessionName) => 'tmux attach -t $sessionName';

  @override
  String newSessionCommand(String sessionName) => 'tmux new-session -s $sessionName';
}
