import 'package:dartssh2/dartssh2.dart';
import 'package:nexterm/features/multiplexer/services/tmux_service.dart';

sealed class TmuxAction {}

class TmuxNotInstalled implements TmuxAction {
  const TmuxNotInstalled();
}

class TmuxAttach implements TmuxAction {
  final String name;
  final int attachedCount;
  const TmuxAttach(this.name, {this.attachedCount = 0});
}

class TmuxCreate implements TmuxAction {
  final String name;
  const TmuxCreate(this.name);
}

class TmuxAutomationService {
  final _tmux = TmuxMultiplexerService();

  Future<TmuxAction> determineAction({
    required SSHClient client,
    required String sessionName,
  }) async {
    final installed = await _tmux.isInstalled(client);
    if (!installed) return const TmuxNotInstalled();

    final sessions = await _tmux.listSessions(client);
    final existing =
        sessions.where((s) => s.name == sessionName).firstOrNull;

    if (existing != null) {
      return TmuxAttach(sessionName, attachedCount: existing.attachedCount);
    }
    return TmuxCreate(sessionName);
  }

  String commandFor(TmuxAction action) {
    return switch (action) {
      TmuxAttach(name: final n) => 'tmux attach-session -t $n',
      TmuxCreate(name: final n) => 'tmux new-session -s $n',
      TmuxNotInstalled() => '',
    };
  }

  static String defaultSessionName(String hostName) {
    return 'nexterm-${hostName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}';
  }
}
