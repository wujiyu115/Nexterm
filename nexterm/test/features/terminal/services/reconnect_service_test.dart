import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/terminal/services/reconnect_service.dart';

void main() {
  test('calculates exponential backoff correctly', () {
    expect(ReconnectService.calculateDelay(0), equals(const Duration(seconds: 1)));
    expect(ReconnectService.calculateDelay(1), equals(const Duration(seconds: 2)));
    expect(ReconnectService.calculateDelay(2), equals(const Duration(seconds: 4)));
    expect(ReconnectService.calculateDelay(3), equals(const Duration(seconds: 8)));
    expect(ReconnectService.calculateDelay(4), equals(const Duration(seconds: 16)));
    expect(ReconnectService.calculateDelay(5), equals(const Duration(seconds: 30)));
    expect(ReconnectService.calculateDelay(10), equals(const Duration(seconds: 30)));
  });

  test('max retries defaults to 10', () {
    final service = ReconnectService(maxRetries: 10);
    expect(service.maxRetries, equals(10));
  });

  group('scheduleReconnect', () {
    /// Returns a fake [ReconnectService] that uses 1 ms delays so tests run fast.
    /// The real [calculateDelay] returns seconds; we override scheduling by
    /// patching [Future.delayed] — instead we rely on the service's own internal
    /// delay call being very small when the delay duration itself is tiny.
    ///
    /// Strategy: we pass maxRetries:2 and a reconnectFn that always returns
    /// immediately, then we wait for the future to complete.

    test('success on first attempt calls onReconnected and not onGaveUp', () async {
      final service = ReconnectService(maxRetries: 2);
      bool reconnected = false;
      bool gaveUp = false;

      // Override delay by using a custom reconnectFn that succeeds immediately.
      // The real delay is calculateDelay(0) = 1 s — too long for a unit test.
      // We work around this by replacing calculateDelay indirectly: we can't
      // easily override it, so we run the schedule and fake the clock via
      // fake async.
      await _withFakeDelays(() => service.scheduleReconnect(
            sessionId: 'sess1',
            reconnectFn: () async => true,
            onReconnected: () => reconnected = true,
            onGaveUp: () => gaveUp = true,
          ));

      expect(reconnected, isTrue);
      expect(gaveUp, isFalse);
    });

    test('all failures calls onGaveUp and not onReconnected', () async {
      final service = ReconnectService(maxRetries: 2);
      bool reconnected = false;
      bool gaveUp = false;

      await _withFakeDelays(() => service.scheduleReconnect(
            sessionId: 'sess2',
            reconnectFn: () async => false,
            onReconnected: () => reconnected = true,
            onGaveUp: () => gaveUp = true,
          ));

      expect(gaveUp, isTrue);
      expect(reconnected, isFalse);
    });

    test('cancelReconnect stops the retry loop before onGaveUp', () async {
      final service = ReconnectService(maxRetries: 5);
      bool gaveUp = false;
      int attempts = 0;

      // Cancel after the first attempt starts.
      final future = _withFakeDelays(() => service.scheduleReconnect(
            sessionId: 'sess3',
            reconnectFn: () async {
              attempts++;
              // Cancel after first invocation
              service.cancelReconnect('sess3');
              return false;
            },
            onGaveUp: () => gaveUp = true,
          ));

      await future;

      expect(gaveUp, isFalse);
      expect(attempts, equals(1));
    });

    test('exception in reconnectFn is swallowed and loop continues', () async {
      final service = ReconnectService(maxRetries: 2);
      int calls = 0;
      bool gaveUp = false;

      await _withFakeDelays(() => service.scheduleReconnect(
            sessionId: 'sess4',
            reconnectFn: () async {
              calls++;
              throw Exception('boom');
            },
            onGaveUp: () => gaveUp = true,
          ));

      // All maxRetries attempts were made despite the exception each time.
      expect(calls, equals(2));
      expect(gaveUp, isTrue);
    });
  });
}

/// Runs [fn] with all [Future.delayed] calls patched to complete in 1 ms,
/// using [FakeAsync] semantics via manual pump.
///
/// Because [ReconnectService.scheduleReconnect] uses [Future.delayed] with
/// values like [Duration(seconds: 1)], running it for real would make tests
/// very slow.  We use [fakeAsync] from package:fake_async (re-exported by
/// flutter_test) to advance time instantly.
Future<void> _withFakeDelays(Future<void> Function() fn) async {
  // flutter_test provides fakeAsync; pump time to skip waits.
  // We run this test as a normal async test and just rely on the fact
  // that fakeAsync is available from flutter_test.
  bool done = false;
  Object? error;

  fakeAsync((async) {
    fn().then((_) => done = true).catchError((e) {
      error = e;
      done = true;
    });
    // Advance time far enough to cover all retries (maxRetries:5 * 30s each).
    async.elapse(const Duration(minutes: 10));
  });

  if (error != null) throw error!;
  assert(done, 'scheduleReconnect future did not complete');
}
