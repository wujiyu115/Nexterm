import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/core/crypto/crypto_service.dart';

void main() {
  late CryptoService crypto;
  setUp(() => crypto = CryptoService());

  group('AES-256-GCM', () {
    test('encrypts and decrypts string data', () {
      final key = crypto.generateRandomKey(32);
      const plaintext = 'Hello, Nexterm! 你好世界';
      final encrypted = crypto.encrypt(utf8.encode(plaintext), key);
      final decrypted = crypto.decrypt(encrypted, key);
      expect(utf8.decode(decrypted), equals(plaintext));
    });

    test('produces different ciphertext for same plaintext', () {
      final key = crypto.generateRandomKey(32);
      final data = utf8.encode('same data');
      final e1 = crypto.encrypt(data, key);
      final e2 = crypto.encrypt(data, key);
      expect(e1, isNot(equals(e2)));
    });

    test('fails to decrypt with wrong key', () {
      final key1 = crypto.generateRandomKey(32);
      final key2 = crypto.generateRandomKey(32);
      final encrypted = crypto.encrypt(utf8.encode('secret'), key1);
      expect(() => crypto.decrypt(encrypted, key2), throwsException);
    });

    test('fails to decrypt tampered ciphertext', () {
      final key = crypto.generateRandomKey(32);
      final encrypted = crypto.encrypt(utf8.encode('secret'), key);
      encrypted[encrypted.length - 1] ^= 0xFF;
      expect(() => crypto.decrypt(encrypted, key), throwsException);
    });
  });

  group('Key derivation', () {
    test('derives consistent key from same password and salt', () {
      final salt = crypto.generateRandomKey(16);
      final key1 = crypto.deriveKey('my-password', salt);
      final key2 = crypto.deriveKey('my-password', salt);
      expect(key1, equals(key2));
    });

    test('derives different keys from different passwords', () {
      final salt = crypto.generateRandomKey(16);
      final key1 = crypto.deriveKey('password1', salt);
      final key2 = crypto.deriveKey('password2', salt);
      expect(key1, isNot(equals(key2)));
    });

    test('derived key is 32 bytes', () {
      final salt = crypto.generateRandomKey(16);
      final key = crypto.deriveKey('password', salt);
      expect(key.length, equals(32));
    });
  });
}
