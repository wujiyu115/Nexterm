import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/repositories/ssh_key_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/domain/repositories/ssh_key_repository.dart';
import 'package:nexterm/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinenacl/ed25519.dart' as pinenacl;
import 'package:pointycastle/export.dart';
import 'package:share_plus/share_plus.dart';
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
// OpenSSH PEM parsing helpers
// ---------------------------------------------------------------------------

/// Reads a uint32 from [data] at [offset] (big-endian).
int _readUint32(Uint8List data, int offset) {
  return (data[offset] << 24) |
      (data[offset + 1] << 16) |
      (data[offset + 2] << 8) |
      data[offset + 3];
}

/// Reads a length-prefixed string/bytes field from [data] at [offset].
/// Returns (bytes, newOffset).
(Uint8List, int) _readLenPrefixed(Uint8List data, int offset) {
  final len = _readUint32(data, offset);
  offset += 4;
  final bytes = data.sublist(offset, offset + len);
  return (bytes, offset + len);
}

/// Detects the [KeyType] from the SSH key-type string (e.g. "ssh-ed25519").
KeyType _detectKeyType(String keyTypeStr) {
  return switch (keyTypeStr) {
    'ssh-ed25519' => KeyType.ed25519,
    'ssh-rsa' => KeyType.rsa2048, // will be refined later if needed
    'ecdsa-sha2-nistp256' => KeyType.ecdsa256,
    'ecdsa-sha2-nistp384' => KeyType.ecdsa384,
    'ecdsa-sha2-nistp521' => KeyType.ecdsa521,
    _ => throw FormatException('不支持的密钥类型: $keyTypeStr'),
  };
}

// ---------------------------------------------------------------------------
// ASN.1 DER parsing helpers (for traditional PEM formats)
// ---------------------------------------------------------------------------

/// Reads an ASN.1 tag and length from [data] at [offset].
/// Returns (tag, contentBytes, newOffset).
(int, Uint8List, int) _readAsn1TLV(Uint8List data, int offset) {
  final tag = data[offset++];
  var length = data[offset++];
  if (length & 0x80 != 0) {
    final numLenBytes = length & 0x7F;
    length = 0;
    for (var i = 0; i < numLenBytes; i++) {
      length = (length << 8) | data[offset++];
    }
  }
  final content = data.sublist(offset, offset + length);
  return (tag, content, offset + length);
}

/// Reads an ASN.1 INTEGER and returns it as BigInt.
BigInt _readAsn1Integer(Uint8List data, int offset) {
  final (tag, content, _) = _readAsn1TLV(data, offset);
  if (tag != 0x02) throw FormatException('期望 ASN.1 INTEGER，得到 tag 0x${tag.toRadixString(16)}');
  // Parse as unsigned big-endian, skip leading zero if present
  var hex = content.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return BigInt.parse(hex, radix: 16);
}

/// Skips one ASN.1 TLV and returns the new offset.
int _skipAsn1TLV(Uint8List data, int offset) {
  final (_, _, newOffset) = _readAsn1TLV(data, offset);
  return newOffset;
}

/// Parses a traditional PKCS#1 RSA private key PEM.
/// Format: RSAPrivateKey ::= SEQUENCE { version, n, e, d, p, q, dp, dq, qinv }
/// Returns [keyType, publicKeyString, fingerprint].
List<dynamic> _parsePkcs1RsaPem(String pem, String comment) {
  final lines = pem.trim().split('\n');
  final b64 = lines
      .where((l) => !l.trim().startsWith('-----'))
      .map((l) => l.trim())
      .join();
  final data = base64.decode(b64);

  // Outer SEQUENCE
  final (seqTag, seqContent, _) = _readAsn1TLV(data, 0);
  if (seqTag != 0x30) throw const FormatException('无效的 PKCS#1 RSA 私钥格式');

  var offset = 0;
  // version (INTEGER, should be 0)
  offset = _skipAsn1TLV(seqContent, offset);
  // n (modulus)
  final n = _readAsn1Integer(seqContent, offset);
  offset = _skipAsn1TLV(seqContent, offset);
  // e (public exponent)
  final e = _readAsn1Integer(seqContent, offset);

  // Build SSH public blob: string("ssh-rsa") || mpint(e) || mpint(n)
  final blob = Uint8List.fromList([
    ..._wireLenPrefixed(utf8.encode('ssh-rsa')),
    ..._wireMpint(e),
    ..._wireMpint(n),
  ]);

  final publicKeyString = 'ssh-rsa ${base64.encode(blob)} $comment';
  final fp = _fingerprint(blob);

  // Determine RSA key size
  final nBytes = _mpintBytes(n);
  final nEffective = (nBytes.isNotEmpty && nBytes[0] == 0) ? nBytes.sublist(1) : nBytes;
  final bitLen = nEffective.length * 8;
  final keyType = bitLen > 2048 ? KeyType.rsa4096 : KeyType.rsa2048;

  return [keyType, publicKeyString, fp];
}

// ---------------------------------------------------------------------------
// Unified PEM parser
// ---------------------------------------------------------------------------

/// Parses a private key PEM (OpenSSH or traditional PKCS#1 RSA format)
/// and extracts key metadata.
/// Returns [keyType, publicKeyString, fingerprint, normalizedPem].
/// The 4th element is the normalized PEM string with proper headers,
/// ensuring it can be used by dartssh2's SSHKeyPair.fromPem().
/// Throws [FormatException] on invalid input.
List<dynamic> _parsePrivateKeyPem(String pem, String comment) {
  final trimmed = pem.trim();

  // Detect format from PEM header
  final firstLine = trimmed.split('\n').first.trim();

  // Handle raw base64 without PEM headers (treat as PKCS#1 RSA)
  if (!firstLine.startsWith('-----')) {
    // Wrap in PEM headers and try PKCS#1 RSA
    final wrapped = '-----BEGIN RSA PRIVATE KEY-----\n$trimmed\n-----END RSA PRIVATE KEY-----';
    final result = _parsePkcs1RsaPem(wrapped, comment);
    return [...result, wrapped];
  }

  if (firstLine.contains('BEGIN OPENSSH PRIVATE KEY')) {
    final result = _parseOpenSSHPem(trimmed, comment);
    return [...result, trimmed];
  } else if (firstLine.contains('BEGIN RSA PRIVATE KEY')) {
    final result = _parsePkcs1RsaPem(trimmed, comment);
    return [...result, trimmed];
  } else {
    throw FormatException('不支持的私钥格式: $firstLine');
  }
}

/// Parses an OpenSSH private key PEM and extracts key metadata.
/// Returns [keyType, publicKeyString, fingerprint].
List<dynamic> _parseOpenSSHPem(String pem, String comment) {
  final lines = pem.trim().split('\n');
  final b64 = lines
      .where((l) =>
          !l.trim().startsWith('-----BEGIN') &&
          !l.trim().startsWith('-----END'))
      .join();
  final data = base64.decode(b64);

  // Verify magic header "openssh-key-v1\0"
  const magic = 'openssh-key-v1';
  final magicEnd = magic.length + 1; // +1 for null terminator
  final magicStr = String.fromCharCodes(data.sublist(0, magic.length));
  if (magicStr != magic || data[magic.length] != 0) {
    throw const FormatException('无效的 OpenSSH 私钥魔数');
  }

  var offset = magicEnd;

  // Read cipher name
  final (cipherBytes, offset2) = _readLenPrefixed(data, offset);
  final cipher = utf8.decode(cipherBytes);
  offset = offset2;

  if (cipher != 'none') {
    throw const FormatException('暂不支持加密的私钥，请先解密后再导入');
  }

  // Read KDF name
  final (_, offset3) = _readLenPrefixed(data, offset);
  offset = offset3;

  // Read KDF options
  final (_, offset4) = _readLenPrefixed(data, offset);
  offset = offset4;

  // Read number of keys
  final numKeys = _readUint32(data, offset);
  offset += 4;
  if (numKeys != 1) {
    throw const FormatException('仅支持包含单个密钥的文件');
  }

  // Read public key blob
  final (publicBlob, offset5) = _readLenPrefixed(data, offset);
  offset = offset5;

  // Parse key type from public blob
  final (keyTypeBytes, _) = _readLenPrefixed(publicBlob, 0);
  final keyTypeStr = utf8.decode(keyTypeBytes);
  final keyType = _detectKeyType(keyTypeStr);

  // Build the public key one-line string
  final publicKeyString = '$keyTypeStr ${base64.encode(publicBlob)} $comment';

  // Compute fingerprint from public blob
  final fp = _fingerprint(publicBlob);

  // For RSA keys, try to determine the actual bit size from the modulus
  KeyType finalKeyType = keyType;
  if (keyTypeStr == 'ssh-rsa') {
    // Public blob format: string("ssh-rsa") || mpint(e) || mpint(n)
    var pbOffset = 0;
    final (_, pbOffset2) = _readLenPrefixed(publicBlob, pbOffset); // key type
    pbOffset = pbOffset2;
    final (_, pbOffset3) = _readLenPrefixed(publicBlob, pbOffset); // e
    pbOffset = pbOffset3;
    final (nBytes, _) = _readLenPrefixed(publicBlob, pbOffset); // n
    // Remove leading zero byte if present
    final nEffective =
        (nBytes.isNotEmpty && nBytes[0] == 0) ? nBytes.sublist(1) : nBytes;
    final bitLen = nEffective.length * 8;
    finalKeyType = bitLen > 2048 ? KeyType.rsa4096 : KeyType.rsa2048;
  }

  return [finalKeyType, publicKeyString, fp];
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
    String? passphrase,
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
        passphrase: passphrase,
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

  /// Imports a key from PEM text (file content or pasted text).
  Future<SSHKeyEntity?> importKey({
    required String name,
    required String privateKeyPem,
    String? passphrase,
  }) async {
    state = const AsyncValue.loading();
    SSHKeyEntity? result;
    state = await AsyncValue.guard(() async {
      final id = const Uuid().v4();
      final comment = name.replaceAll(' ', '_');
      final now = DateTime.now();

      final parts = _parsePrivateKeyPem(privateKeyPem, comment);
      final keyType = parts[0] as KeyType;
      final publicKeyString = parts[1] as String;
      final fingerprint = parts[2] as String;
      final normalizedPem = parts[3] as String;

      final entity = SSHKeyEntity(
        id: id,
        name: name,
        type: keyType,
        privateKey: normalizedPem,
        publicKey: publicKeyString,
        fingerprint: fingerprint,
        passphrase: passphrase,
        createdAt: now,
      );
      await _repo.insert(entity);
      result = entity;
    });
    return result;
  }

  /// Exports a key's private or public key to a file via share sheet.
  Future<void> exportKey(SSHKeyEntity key, {bool publicOnly = false}) async {
    final tempDir = await getTemporaryDirectory();
    final sanitizedName = key.name.replaceAll(RegExp(r'[^\w\-.]'), '_');

    if (publicOnly) {
      final pubFile = File('${tempDir.path}/$sanitizedName.pub');
      await pubFile.writeAsString(key.publicKey);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(pubFile.path)]),
      );
    } else {
      final privFile = File('${tempDir.path}/$sanitizedName');
      await privFile.writeAsString(key.privateKey);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(privFile.path)]),
      );
    }
  }
}

final keysNotifierProvider = StateNotifierProvider<KeysNotifier, AsyncValue<void>>((ref) {
  return KeysNotifier(ref.watch(sshKeyRepositoryProvider));
});
