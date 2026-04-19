import 'dart:convert';
import 'dart:typed_data';
import 'package:nexterm/core/crypto/crypto_service.dart';
import 'package:nexterm/features/sync/services/sync_api_client.dart';

class SyncService {
  final SyncApiClient _api;
  final CryptoService _crypto;
  Uint8List? _encryptionKey;

  SyncService(this._api, this._crypto);

  void setEncryptionKey(Uint8List key) => _encryptionKey = key;

  Map<String, String> encryptRecord(Map<String, dynamic> plainRecord) {
    if (_encryptionKey == null) throw StateError('Encryption key not set');
    final jsonBytes = utf8.encode(jsonEncode(plainRecord));
    final encrypted = _crypto.encrypt(jsonBytes, _encryptionKey!);
    // encrypted format: IV(12) + ciphertext + tag(16)
    final iv = encrypted.sublist(0, 12);
    final payload = encrypted.sublist(12);
    return {'encrypted_payload': base64Encode(payload), 'iv': base64Encode(iv)};
  }

  Map<String, dynamic> decryptRecord(String encryptedPayloadB64, String ivB64) {
    if (_encryptionKey == null) throw StateError('Encryption key not set');
    final iv = base64Decode(ivB64);
    final payload = base64Decode(encryptedPayloadB64);
    final combined = Uint8List.fromList([...iv, ...payload]);
    final decrypted = _crypto.decrypt(combined, _encryptionKey!);
    return jsonDecode(utf8.decode(decrypted));
  }

  Future<List<Map<String, dynamic>>> pullAndDecrypt(String since, String accessToken) async {
    final response = await _api.pullChanges(since, accessToken);
    final records = (response['records'] as List).cast<Map<String, dynamic>>();
    return records.map((r) {
      final decrypted = decryptRecord(r['encrypted_payload'], r['iv']);
      return {...decrypted, 'id': r['id'], 'record_type': r['record_type'],
        'updated_at': r['updated_at'], 'is_deleted': r['is_deleted'], 'version': r['version']};
    }).toList();
  }

  Future<void> encryptAndPush(List<Map<String, dynamic>> records, String deviceId, String accessToken) async {
    final encrypted = records.map((r) {
      final encData = encryptRecord(r['data'] as Map<String, dynamic>);
      return {'id': r['id'], 'record_type': r['record_type'], ...encData,
        'updated_at': r['updated_at'], 'is_deleted': r['is_deleted'] ?? false, 'version': r['version'] ?? 1};
    }).toList();
    await _api.pushChanges(encrypted, deviceId, accessToken);
  }
}
