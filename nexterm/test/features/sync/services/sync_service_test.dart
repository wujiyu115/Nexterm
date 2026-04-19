import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/core/crypto/crypto_service.dart';
import 'package:nexterm/features/sync/services/sync_api_client.dart';
import 'package:nexterm/features/sync/services/sync_service.dart';

/// A real [SyncApiClient] backed by a no-op [Dio].  Only the
/// [SyncService.encryptRecord] / [SyncService.decryptRecord] paths are
/// exercised here, so the HTTP client is never actually invoked.
SyncApiClient _makeApiClient() => SyncApiClient(Dio());

SyncService _makeService({bool setKey = true}) {
  final svc = SyncService(_makeApiClient(), CryptoService());
  if (setKey) {
    // 32-byte AES-256 key
    final key = Uint8List.fromList(List.generate(32, (i) => i + 1));
    svc.setEncryptionKey(key);
  }
  return svc;
}

void main() {
  group('SyncService encrypt/decrypt', () {
    late SyncService service;

    setUp(() {
      service = _makeService();
    });

    test('encryptRecord → decryptRecord round-trip preserves data', () {
      final plain = <String, dynamic>{
        'name': 'Alice',
        'age': 30,
        'tags': ['admin', 'user'],
      };
      final encrypted = service.encryptRecord(plain);
      final decrypted = service.decryptRecord(
        encrypted['encrypted_payload']!,
        encrypted['iv']!,
      );
      expect(decrypted['name'], equals('Alice'));
      expect(decrypted['age'], equals(30));
      expect(decrypted['tags'], equals(['admin', 'user']));
    });

    test('encryptRecord throws StateError when key not set', () {
      final svc = _makeService(setKey: false);
      expect(
        () => svc.encryptRecord({'key': 'value'}),
        throwsA(isA<StateError>()),
      );
    });

    test('decryptRecord throws StateError when key not set', () {
      final svc = _makeService(setKey: false);
      // Even with valid-looking base64 values the key-check fires first.
      expect(
        () => svc.decryptRecord(base64Encode([1, 2, 3]), base64Encode([4, 5, 6])),
        throwsA(isA<StateError>()),
      );
    });

    test('encrypted output has iv and encrypted_payload fields (valid base64)', () {
      final encrypted = service.encryptRecord({'hello': 'world'});

      expect(encrypted, containsPair('iv', isA<String>()));
      expect(encrypted, containsPair('encrypted_payload', isA<String>()));

      // Both values must decode without error.
      final ivBytes = base64Decode(encrypted['iv']!);
      final payloadBytes = base64Decode(encrypted['encrypted_payload']!);

      // IV is always 12 bytes for AES-GCM.
      expect(ivBytes, hasLength(12));
      // Payload must be non-empty.
      expect(payloadBytes.isNotEmpty, isTrue);
    });

    test('different encryptions of the same data produce different output (random IV)', () {
      final plain = <String, dynamic>{'secret': 'value'};
      final enc1 = service.encryptRecord(plain);
      final enc2 = service.encryptRecord(plain);

      // Random IV means the two outputs must differ.
      expect(enc1['iv'], isNot(equals(enc2['iv'])));
      expect(enc1['encrypted_payload'], isNot(equals(enc2['encrypted_payload'])));
    });

    test('round-trip preserves empty map', () {
      final encrypted = service.encryptRecord({});
      final decrypted = service.decryptRecord(
        encrypted['encrypted_payload']!,
        encrypted['iv']!,
      );
      expect(decrypted, isEmpty);
    });

    test('round-trip preserves nested map and boolean types', () {
      final plain = <String, dynamic>{
        'nested': {'x': 1},
        'flag': true,
      };
      final encrypted = service.encryptRecord(plain);
      final decrypted = service.decryptRecord(
        encrypted['encrypted_payload']!,
        encrypted['iv']!,
      );
      expect((decrypted['nested'] as Map)['x'], equals(1));
      expect(decrypted['flag'], isTrue);
    });
  });
}
