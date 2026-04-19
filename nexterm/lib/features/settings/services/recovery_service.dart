import 'dart:convert';
import 'dart:typed_data';
import 'package:nexterm/core/crypto/crypto_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecoveryService {
  final CryptoService _crypto;
  final FlutterSecureStorage _storage;

  RecoveryService(this._crypto, this._storage);

  Future<String> generateRecoveryKey(Uint8List masterKey) async {
    final recoveryKey = _crypto.generateRandomKey(32);
    final encryptedMasterKey = _crypto.encrypt(masterKey, recoveryKey);
    await _storage.write(key: 'encrypted_master_key_backup', value: base64Encode(encryptedMasterKey));
    return base64Encode(recoveryKey);
  }

  Future<Uint8List?> recoverMasterKey(String recoveryKeyB64) async {
    try {
      final recoveryKey = base64Decode(recoveryKeyB64);
      final encryptedBackup = await _storage.read(key: 'encrypted_master_key_backup');
      if (encryptedBackup == null) return null;
      return _crypto.decrypt(base64Decode(encryptedBackup), Uint8List.fromList(recoveryKey));
    } catch (_) {
      return null;
    }
  }
}
