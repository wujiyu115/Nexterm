import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/features/forwarding/services/port_forward_service.dart';

void main() {
  group('PortForwardService', () {
    late PortForwardService service;

    setUp(() {
      service = PortForwardService();
    });

    tearDown(() async {
      await service.stopAll();
    });

    test('instantiates with no active forwards', () {
      expect(service.activeForwardIds, isEmpty);
    });

    test('getStatus returns inactive for unknown forward', () {
      expect(service.getStatus('non-existent'), equals(ForwardStatus.inactive));
    });

    test('isActive returns false for unknown forward', () {
      expect(service.isActive('ghost'), isFalse);
    });

    test('stopAll on empty service completes without error', () async {
      await expectLater(service.stopAll(), completes);
    });

    test('stop on non-existent forward is a no-op', () async {
      await expectLater(service.stop('not-there'), completes);
    });

    test('activeForwardIds is unmodifiable', () {
      expect(
        () => (service.activeForwardIds as Set).add('should-fail'),
        throwsUnsupportedError,
      );
    });

    // Note: startLocalForward / startRemoteForward / startDynamicForward
    // require a real SSHClient and live network; those are integration tests.
    // The unit tests here validate the pure logic paths.

    test('getStatus and isActive are consistent for inactive forward', () {
      const id = 'some-forward-id';
      expect(service.getStatus(id), ForwardStatus.inactive);
      expect(service.isActive(id), isFalse);
    });
  });

  group('PortForwardEntity.summary', () {
    test('local forward summary', () {
      final e = PortForwardEntity(
        id: 'f1',
        name: 'Local',
        type: ForwardType.local,
        hostId: 'h1',
        localPort: 8080,
        remoteHost: 'db.internal',
        remotePort: 5432,
      );
      expect(e.summary, equals('L 8080 → db.internal:5432'));
    });

    test('remote forward summary', () {
      final e = PortForwardEntity(
        id: 'f2',
        name: 'Remote',
        type: ForwardType.remote,
        hostId: 'h1',
        localPort: 22,
        remotePort: 2222,
        bindAddress: '127.0.0.1',
      );
      expect(e.summary, equals('R 2222 → 127.0.0.1:22'));
    });

    test('dynamic forward summary', () {
      final e = PortForwardEntity(
        id: 'f3',
        name: 'Dynamic',
        type: ForwardType.dynamic,
        hostId: 'h1',
        localPort: 1080,
      );
      expect(e.summary, equals('D 1080'));
    });
  });
}
