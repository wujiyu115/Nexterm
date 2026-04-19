import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/repositories/ssh_key_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/domain/repositories/ssh_key_repository.dart';
import 'package:nexterm/main.dart';
import 'package:pinenacl/ed25519.dart' as pinenacl;
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final sshKeyRepositoryProvider = Provider<SSHKeyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SSHKeyRepositoryImpl(db.sshKeysDao);
});

// ---------------------------------------------------------------------------
// Stream provider for live list
// ---------------------------------------------------------------------------

final keysStreamProvider = StreamProvider<List<SSHKeyEntity>>((ref) {
  return ref.watch(sshKeyRepositoryProvider).watchAll();
});

// ---------------------------------------------------------------------------
// SSH wire-format helpers
// ---------------------------------------------------------------------------

/// Serialises a BigInt as an SSH mpint (big-endian, no sign byte needed for
/// positive values, but prepend 0x00 if the high bit is set).
Uint8List _mpintBytes(BigInt value) {
  if (value == BigInt.zero) return Uint8List.fromList([0]);
  var hex = value.toRadixString(16);
  if (hex.length.isOdd) hex = '0$hex';
  final bytes = List<int>.generate(
    hex.length ~/ 2,
    (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
  );
  if (bytes[0] & 0x80 != 0) bytes.insert(0, 0);
  return Uint8List.fromList(bytes);
}

/// Writes a length-prefixed string field (SSH wire format).
Uint8List _wireLenPrefixed(List<int> data) {
  final len = ByteData(4)..setUint32(0, data.length);
  return Uint8List.fromList([...len.buffer.asUint8List(), ...data]);
}

/// Writes a length-prefixed mpint field.
Uint8List _wireMpint(BigInt value) => _wireLenPrefixed(_mpintBytes(value));

/// Builds the SSH public-key blob for Ed25519.
/// Format: string("ssh-ed25519") || string(pubkey bytes).
Uint8List _buildEd25519PublicBlob(Uint8List pubKeyBytes) {
  final buf = BytesBuilder()
    ..add(_wireLenPrefixed(utf8.encode('ssh-ed25519')))
    ..add(_wireLenPrefixed(pubKeyBytes));
  return buf.toBytes();
}

/// Returns the one-line public key string "ssh-ed25519 BASE64 COMMENT".
String _ed25519PublicKeyString(Uint8List pubKeyBytes, String comment) {
  final blob = _buildEd25519PublicBlob(pubKeyBytes);
  return 'ssh-ed25519 ${base64.encode(blob)} $comment';
}

/// Computes "SHA256:BASE64" fingerprint for an SSH public blob.
String _fingerprint(Uint8List blob) {
  final digest = SHA256Digest();
  final hash = Uint8List(digest.digestSize);
  digest.update(blob, 0, blob.length);
  digest.doFinal(hash, 0);
  return 'SHA256:${base64.encode(hash).replaceAll('=', '')}';
}

/// Builds an OpenSSH private key PEM for Ed25519.
String _ed25519PrivatePem(Uint8List pubKeyBytes, Uint8List signingKeyBytes, String comment) {
  final publicBlob = _buildEd25519PublicBlob(pubKeyBytes);
  final commentBytes = utf8.encode(comment);

  // Random check-int (for integrity validation on decrypt)
  final checkIntRaw = DateTime.now().microsecondsSinceEpoch & 0xFFFFFFFF;
  final ci = ByteData(4)..setUint32(0, checkIntRaw);

  final privBuf = BytesBuilder()
    ..add(ci.buffer.asUint8List()) // checkint1
    ..add(ci.buffer.asUint8List()) // checkint2
    ..add(_wireLenPrefixed(utf8.encode('ssh-ed25519'))) // key type
    ..add(_wireLenPrefixed(pubKeyBytes)) // public key
    ..add(_wireLenPrefixed(signingKeyBytes)) // private key (64-byte seed||pub)
    ..add(_wireLenPrefixed(commentBytes)); // comment
  // pad to 8-byte boundary with bytes 1,2,3,...
  var padIndex = 1;
  while (privBuf.length % 8 != 0) {
    privBuf.addByte(padIndex++);
  }
  final privateBlob = privBuf.toBytes();

  return _buildOpenSSHPem(publicBlob, privateBlob);
}

/// Assembles the outer "openssh-key-v1" PEM wrapper (unencrypted, one key).
String _buildOpenSSHPem(Uint8List publicBlob, Uint8List privateBlob) {
  const magic = 'openssh-key-v1';
  final outer = BytesBuilder()
    ..add(latin1.encode(magic))
    ..addByte(0) // null terminator
    ..add(_wireLenPrefixed(utf8.encode('none'))) // cipher: none
    ..add(_wireLenPrefixed(utf8.encode('none'))) // kdf: none
    ..add([0, 0, 0, 0]) // kdf options: empty string
    ..add([0, 0, 0, 1]) // key count: 1
    ..add(_wireLenPrefixed(publicBlob)) // public blob
    ..add(_wireLenPrefixed(privateBlob)); // private blob

  final encoded = base64.encode(outer.toBytes());
  final sb = StringBuffer()..writeln('-----BEGIN OPENSSH PRIVATE KEY-----');
  for (var i = 0; i < encoded.length; i += 70) {
    final end = (i + 70 < encoded.length) ? i + 70 : encoded.length;
    sb.writeln(encoded.substring(i, end));
  }
  sb.writeln('-----END OPENSSH PRIVATE KEY-----');
  return sb.toString();
}

// ---------------------------------------------------------------------------
// Ed25519 key generation
// ---------------------------------------------------------------------------

/// Generates an Ed25519 SSH key pair.
/// Returns [privateKeyPem, publicKeyString, fingerprint].
List<String> _generateEd25519(String comment) {
  final signingKey = pinenacl.SigningKey.generate();
  final pubBytes = signingKey.verifyKey.asTypedList;
  final privBytes = signingKey.asTypedList; // 64 bytes: seed || pubkey

  final publicBlob = _buildEd25519PublicBlob(pubBytes);
  return [
    _ed25519PrivatePem(pubBytes, privBytes, comment),
    _ed25519PublicKeyString(pubBytes, comment),
    _fingerprint(publicBlob),
  ];
}

// ---------------------------------------------------------------------------
// RSA key generation
// ---------------------------------------------------------------------------

/// Generates an RSA SSH key pair.
/// Returns [privateKeyPem, publicKeyString, fingerprint].
List<String> _generateRsa(int bits, String comment) {
  final keyGen = RSAKeyGenerator();
  final rng = FortunaRandom();
  final seedBytes = Uint8List(32);
  final now = DateTime.now().microsecondsSinceEpoch;
  for (var i = 0; i < 32; i++) {
    seedBytes[i] = (now >> i) & 0xFF ^ i * 3;
  }
  rng.seed(KeyParameter(seedBytes));
  keyGen.init(
    ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), bits, 64), rng),
  );

  final pair = keyGen.generateKeyPair();
  final pubKey = pair.publicKey as RSAPublicKey;
  final privKey = pair.privateKey as RSAPrivateKey;

  // SSH public blob: string("ssh-rsa") || mpint(e) || mpint(n)
  final blob = Uint8List.fromList([
    ..._wireLenPrefixed(utf8.encode('ssh-rsa')),
    ..._wireMpint(pubKey.exponent!),
    ..._wireMpint(pubKey.modulus!),
  ]);
  final publicKeyString = 'ssh-rsa ${base64.encode(blob)} $comment';
  final fp = _fingerprint(blob);

  // OpenSSH RSA private key blob fields: n, e, d, iqmp, p, q
  final n = privKey.n!;
  final e = pubKey.exponent!;
  final d = privKey.privateExponent!;
  final p = privKey.p!;
  final q = privKey.q!;
  final qp = q.modInverse(p);

  final commentBytes = utf8.encode(comment);
  final checkIntRaw = DateTime.now().microsecondsSinceEpoch & 0xFFFFFFFF;
  final ci = ByteData(4)..setUint32(0, checkIntRaw);

  final privBuf = BytesBuilder()
    ..add(ci.buffer.asUint8List())
    ..add(ci.buffer.asUint8List())
    ..add(_wireLenPrefixed(utf8.encode('ssh-rsa')))
    ..add(_wireMpint(n))
    ..add(_wireMpint(e))
    ..add(_wireMpint(d))
    ..add(_wireMpint(qp))
    ..add(_wireMpint(p))
    ..add(_wireMpint(q))
    ..add(_wireLenPrefixed(commentBytes));
  var padIdx = 1;
  while (privBuf.length % 8 != 0) {
    privBuf.addByte(padIdx++);
  }

  final privateKeyPem = _buildOpenSSHPem(blob, privBuf.toBytes());
  return [privateKeyPem, publicKeyString, fp];
}

// ---------------------------------------------------------------------------
// KeysNotifier
// ---------------------------------------------------------------------------

class KeysNotifier extends StateNotifier<AsyncValue<void>> {
  final SSHKeyRepository _repo;
  KeysNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<SSHKeyEntity?> generateKey({
    required String name,
    required KeyType type,
  }) async {
    state = const AsyncValue.loading();
    SSHKeyEntity? result;
    state = await AsyncValue.guard(() async {
      final id = const Uuid().v4();
      final comment = name.replaceAll(' ', '_');
      final now = DateTime.now();

      final List<String> parts;
      if (type == KeyType.ed25519) {
        parts = _generateEd25519(comment);
      } else {
        final bits = type == KeyType.rsa4096 ? 4096 : 2048;
        parts = _generateRsa(bits, comment);
      }

      final entity = SSHKeyEntity(
        id: id,
        name: name,
        type: type,
        privateKey: parts[0],
        publicKey: parts[1],
        fingerprint: parts[2],
        createdAt: now,
      );
      await _repo.insert(entity);
      result = entity;
    });
    return result;
  }

  Future<void> deleteKey(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }

  Future<void> updateKey(SSHKeyEntity key) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.update(key));
  }
}

final keysNotifierProvider = StateNotifierProvider<KeysNotifier, AsyncValue<void>>((ref) {
  return KeysNotifier(ref.watch(sshKeyRepositoryProvider));
});
