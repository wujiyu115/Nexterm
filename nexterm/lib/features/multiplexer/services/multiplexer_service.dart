import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

enum MultiplexerType { tmux, zellij, herdr }

class MuxSession {
  final String name;
  final int windows;
  final int attachedCount;
  final DateTime? created;
  final DateTime? lastActivity;
  final MultiplexerType type;

  const MuxSession({
    required this.name,
    required this.windows,
    required this.attachedCount,
    this.created,
    this.lastActivity,
    required this.type,
  });

  bool get isAttached => attachedCount > 0;
}

abstract class MultiplexerService {
  MultiplexerType get type;
  String get displayName;
  IconData get icon;
  Future<bool> isInstalled(SSHClient client);
  Future<List<MuxSession>> listSessions(SSHClient client);
  Future<void> killSession(SSHClient client, String sessionName);
  String attachCommand(String sessionName);
  String newSessionCommand(String sessionName);
}
