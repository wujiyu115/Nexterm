import 'dart:async';
import 'dart:collection';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/monitor/models/system_metrics.dart';
import 'package:nexterm/features/monitor/services/system_monitor_service.dart';

class MonitorState {
  final List<SystemSnapshot> history;
  final bool isConnecting;
  final String? error;

  const MonitorState({
    this.history = const [],
    this.isConnecting = false,
    this.error,
  });

  SystemSnapshot? get latest => history.isNotEmpty ? history.last : null;

  MonitorState copyWith({
    List<SystemSnapshot>? history,
    bool? isConnecting,
    String? Function()? error,
  }) {
    return MonitorState(
      history: history ?? this.history,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error != null ? error() : this.error,
    );
  }
}

class MonitorNotifier extends StateNotifier<MonitorState> {
  static const int maxHistory = 60;

  SystemMonitorService? _service;
  StreamSubscription<SystemSnapshot>? _subscription;
  final Queue<SystemSnapshot> _buffer = Queue();

  MonitorNotifier() : super(const MonitorState(isConnecting: true));

  Future<void> start(SSHClient client) async {
    _service?.dispose();
    _service = SystemMonitorService(client);

    state = state.copyWith(isConnecting: true, error: () => null);

    _subscription = _service!.snapshots.listen(
      (snapshot) {
        _buffer.addLast(snapshot);
        while (_buffer.length > maxHistory) {
          _buffer.removeFirst();
        }
        state = state.copyWith(
          history: _buffer.toList(),
          isConnecting: false,
          error: () => null,
        );
      },
      onError: (e) {
        state = state.copyWith(error: () => e.toString(), isConnecting: false);
      },
    );

    await _service!.start();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service?.dispose();
    super.dispose();
  }
}

final monitorProvider =
    StateNotifierProvider.autoDispose.family<MonitorNotifier, MonitorState, String>(
  (ref, sessionId) {
    final notifier = MonitorNotifier();
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);
