import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:nexterm/features/monitor/models/system_metrics.dart';
import 'package:nexterm/features/monitor/services/metrics_parser.dart';

class SystemMonitorService {
  final SSHClient _client;
  final MetricsParser _parser = MetricsParser();
  Timer? _timer;
  final _controller = StreamController<SystemSnapshot>.broadcast();
  bool _isMac = false;
  bool _disposed = false;

  SystemMonitorService(this._client);

  Stream<SystemSnapshot> get snapshots => _controller.stream;

  static const _linuxCommand =
      'echo "::CPU::" && head -1 /proc/stat && '
      'echo "::MEM::" && cat /proc/meminfo && '
      'echo "::DISK::" && df -B1 2>/dev/null && '
      'echo "::NET::" && cat /proc/net/dev && '
      'echo "::OS::" && uname -sr && uptime';

  static const _macCommand =
      'echo "::CPU::" && top -l 1 -n 0 2>/dev/null | grep "CPU usage" && '
      'echo "::MEM::" && vm_stat && '
      'echo "::DISK::" && df -b 2>/dev/null && '
      'echo "::NET::" && netstat -ibn 2>/dev/null && '
      'echo "::OS::" && uname -sr && uptime';

  Future<void> start({Duration interval = const Duration(seconds: 3)}) async {
    _isMac = await _detectOs();
    await _poll();
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  Future<bool> _detectOs() async {
    try {
      final result = await _client.run('uname -s');
      final os = String.fromCharCodes(result).trim();
      return os == 'Darwin';
    } catch (_) {
      return false;
    }
  }

  Future<void> _poll() async {
    if (_disposed) return;
    try {
      final command = _isMac ? _macCommand : _linuxCommand;
      final result = await _client.run(command);
      final output = String.fromCharCodes(result);
      final snapshot = _parser.parse(output);
      if (snapshot != null && !_disposed) {
        _controller.add(snapshot);
      }
    } catch (_) {
      // Connection lost - will retry on next tick
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _parser.reset();
    _controller.close();
  }
}
