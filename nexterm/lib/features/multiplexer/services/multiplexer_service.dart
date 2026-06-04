import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

enum MultiplexerType { tmux, zellij, herdr }

class MuxSession {
  final String name;
  final int windows;
  final bool isAttached;
  final DateTime? created;
  final MultiplexerType type;

  const MuxSession({
    required this.name,
    required this.windows,
    required this.isAttached,
    this.created,
    required this.type,
  });
}

abstract class MultiplexerService {
  MultiplexerType get type;
  String get displayName;
  IconData get icon;
  Future<bool> isInstalled(SSHClient client);
  Future<List<MuxSession>> listSessions(SSHClient client);
  String attachCommand(String sessionName);
  String newSessionCommand(String sessionName);
}
