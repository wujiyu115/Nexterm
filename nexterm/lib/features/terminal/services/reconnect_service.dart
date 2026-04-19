import 'dart:async';
import 'dart:math';

class ReconnectService {
  static const Duration _maxDelay = Duration(seconds: 30);
  static const Duration _baseDelay = Duration(seconds: 1);

  final int maxRetries;
  final Map<String, int> _retryCounts = {};
  final Map<String, bool> _cancelled = {};

  ReconnectService({this.maxRetries = 10});

  static Duration calculateDelay(int attempt) {
    final seconds = _baseDelay.inSeconds * pow(2, attempt);
    return Duration(seconds: min(seconds.toInt(), _maxDelay.inSeconds));
  }

  Future<void> scheduleReconnect({
    required String sessionId,
    required Future<bool> Function() reconnectFn,
    void Function(int attempt, Duration delay)? onRetrying,
    void Function()? onGaveUp,
    void Function()? onReconnected,
  }) async {
    _cancelled[sessionId] = false;
    _retryCounts[sessionId] = 0;

    while ((_retryCounts[sessionId] ?? 0) < maxRetries) {
      if (_cancelled[sessionId] == true) return;

      final attempt = _retryCounts[sessionId]!;
      final delay = calculateDelay(attempt);
      onRetrying?.call(attempt, delay);

      await Future.delayed(delay);
      if (_cancelled[sessionId] == true) return;

      try {
        final success = await reconnectFn();
        if (success) {
          _retryCounts.remove(sessionId);
          _cancelled.remove(sessionId);
          onReconnected?.call();
          return;
        }
      } catch (_) {}

      _retryCounts[sessionId] = attempt + 1;
    }

    _retryCounts.remove(sessionId);
    _cancelled.remove(sessionId);
    onGaveUp?.call();
  }

  void cancelReconnect(String sessionId) {
    _cancelled[sessionId] = true;
    _retryCounts.remove(sessionId);
  }

  void cancelAll() {
    for (final id in _cancelled.keys.toList()) {
      cancelReconnect(id);
    }
  }
}
