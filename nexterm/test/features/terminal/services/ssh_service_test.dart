import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/features/terminal/services/ssh_service.dart';

void main() {
  group('SSHService.buildConnectionConfig', () {
    late SSHService service;

    setUp(() {
      service = SSHService();
    });

    test('password auth sets password and host fields correctly', () {
      final host = HostEntity(
        id: 'h1',
        name: 'Test Host',
        hostname: 'example.com',
        port: 22,
        username: 'admin',
        authMethod: AuthMethod.password,
        password: 'secret',
      );

      final config = service.buildConnectionConfig(host);

      expect(config.host, 'example.com');
      expect(config.port, 22);
      expect(config.username, 'admin');
      expect(config.authMethod, AuthMethod.password);
      expect(config.password, 'secret');
      expect(config.privateKeyPem, isNull);
    });

    test('key auth sets privateKeyPem from SSHKeyEntity', () {
      final host = HostEntity(
        id: 'h2',
        name: 'Key Host',
        hostname: '10.0.0.1',
        port: 2222,
        username: 'root',
        authMethod: AuthMethod.key,
        keyId: 'key1',
      );
      final sshKey = SSHKeyEntity(
        id: 'key1',
        name: 'my-key',
        type: KeyType.ed25519,
        privateKey: '-----BEGIN OPENSSH PRIVATE KEY-----\nfake\n-----END OPENSSH PRIVATE KEY-----',
        publicKey: 'ssh-ed25519 AAAA comment',
        fingerprint: 'SHA256:abc',
        createdAt: DateTime(2024),
      );

      final config = service.buildConnectionConfig(host, sshKey: sshKey);

      expect(config.authMethod, AuthMethod.key);
      expect(config.privateKeyPem, sshKey.privateKey);
      expect(config.password, isNull);
      expect(config.passphrase, isNull);
    });

    test('key auth with passphrase forwards passphrase', () {
      final host = HostEntity(
        id: 'h3',
        name: 'Passphrase Host',
        hostname: 'secure.example.com',
        port: 22,
        username: 'user',
        authMethod: AuthMethod.key,
        keyId: 'key2',
      );
      final sshKey = SSHKeyEntity(
        id: 'key2',
        name: 'protected-key',
        type: KeyType.rsa4096,
        privateKey: '-----BEGIN OPENSSH PRIVATE KEY-----\nfake\n-----END OPENSSH PRIVATE KEY-----',
        publicKey: 'ssh-rsa AAAA comment',
        fingerprint: 'SHA256:xyz',
        passphrase: 'mypassphrase',
        createdAt: DateTime(2024),
      );

      final config = service.buildConnectionConfig(host, sshKey: sshKey);

      expect(config.passphrase, 'mypassphrase');
    });

    test('password auth does not expose key even if sshKey is provided', () {
      final host = HostEntity(
        id: 'h4',
        name: 'PW Host',
        hostname: 'host.example.com',
        port: 22,
        username: 'user',
        authMethod: AuthMethod.password,
        password: 'pw',
      );
      final sshKey = SSHKeyEntity(
        id: 'k1',
        name: 'irrelevant-key',
        type: KeyType.ed25519,
        privateKey: 'shouldNotBeUsed',
        publicKey: 'ssh-ed25519 xxx',
        fingerprint: 'SHA256:fff',
        createdAt: DateTime(2024),
      );

      final config = service.buildConnectionConfig(host, sshKey: sshKey);

      expect(config.privateKeyPem, isNull);
      expect(config.password, 'pw');
    });

    test('custom port is preserved', () {
      final host = HostEntity(
        id: 'h5',
        name: 'Custom Port Host',
        hostname: 'myserver.local',
        port: 4422,
        username: 'dev',
        authMethod: AuthMethod.password,
        password: 'devpw',
      );

      final config = service.buildConnectionConfig(host);

      expect(config.port, 4422);
    });

    test('starts with no active sessions', () {
      expect(service.activeSessionIds, isEmpty);
      expect(service.isActive('nonexistent'), isFalse);
    });

    test('stdout and stderr return null for unknown session', () {
      expect(service.stdout('ghost'), isNull);
      expect(service.stderr('ghost'), isNull);
    });
  });
}
