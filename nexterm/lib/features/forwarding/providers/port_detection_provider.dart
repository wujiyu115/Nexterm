import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/forwarding/models/detected_port.dart';
import 'package:nexterm/features/forwarding/services/port_detection_service.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';

class SessionInfo {
  final String sessionId;
  final String hostId;
  final String hostName;

  const SessionInfo({
    required this.sessionId,
    required this.hostId,
    required this.hostName,
  });
}

class PortDetectionState {
  final AsyncValue<List<DetectedPort>> ports;
  final String? activeSessionId;

  const PortDetectionState({
    this.ports = const AsyncValue.data([]),
    this.activeSessionId,
  });

  PortDetectionState copyWith({
    AsyncValue<List<DetectedPort>>? ports,
    String? Function()? activeSessionId,
  }) {
    return PortDetectionState(
      ports: ports ?? this.ports,
      activeSessionId: activeSessionId != null
          ? activeSessionId()
          : this.activeSessionId,
    );
  }
}

class PortDetectionNotifier extends StateNotifier<PortDetectionState> {
  PortDetectionNotifier(this._ref) : super(const PortDetectionState());

  final Ref _ref;
  final _service = PortDetectionService();

  Future<void> scan(String sessionId) async {
    state = state.copyWith(
      ports: const AsyncValue.loading(),
      activeSessionId: () => sessionId,
    );

    final client = _ref.read(sshServiceProvider).getClient(sessionId);
    if (client == null) {
      state = state.copyWith(
        ports: AsyncValue.error('SSH session not available', StackTrace.current),
      );
      return;
    }

    try {
      final results = await _service.detectPorts(client);
      if (!mounted) return;
      state = state.copyWith(ports: AsyncValue.data(results));
    } catch (e, st) {
      if (!mounted) return;
      state = state.copyWith(ports: AsyncValue.error(e, st));
    }
  }

  void reset() {
    state = const PortDetectionState();
  }
}

final portDetectionNotifierProvider =
    StateNotifierProvider.autoDispose<PortDetectionNotifier, PortDetectionState>(
  (ref) => PortDetectionNotifier(ref),
);

final activeSessionsForDetectionProvider = Provider<List<SessionInfo>>((ref) {
  final tabManager = ref.watch(tabManagerProvider);
  final hostsAsync = ref.watch(hostsStreamProvider);

  final hosts = hostsAsync.valueOrNull ?? [];
  final hostMap = {for (final h in hosts) h.id: h.name};

  final sessions = <SessionInfo>[];
  final seen = <String>{};

  for (final tab in tabManager.tabs) {
    if (tab.connectionType != ConnectionType.ssh) continue;
    if (tab.status != ConnectionStatus.connected) continue;
    if (tab.sessionId == null) continue;
    if (seen.contains(tab.sessionId)) continue;
    seen.add(tab.sessionId!);

    sessions.add(SessionInfo(
      sessionId: tab.sessionId!,
      hostId: tab.hostId,
      hostName: hostMap[tab.hostId] ?? tab.title,
    ));
  }

  return sessions;
});
