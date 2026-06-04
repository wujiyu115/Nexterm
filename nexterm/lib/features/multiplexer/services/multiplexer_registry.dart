import 'package:dartssh2/dartssh2.dart';
import 'package:nexterm/features/multiplexer/services/multiplexer_service.dart';
import 'package:nexterm/features/multiplexer/services/tmux_service.dart';

class MultiplexerRegistry {
  MultiplexerRegistry._();

  static final List<MultiplexerService> all = [
    TmuxMultiplexerService(),
  ];

  static Future<List<MultiplexerService>> detectInstalled(SSHClient client) async {
    final installed = <MultiplexerService>[];
    for (final svc in all) {
      if (await svc.isInstalled(client)) installed.add(svc);
    }
    return installed;
  }
}
