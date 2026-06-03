import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';

class SttCredentialService {
  final FlutterSecureStorage _storage;
  const SttCredentialService([this._storage = const FlutterSecureStorage()]);

  static const _volcAppId = 'stt_volcengine_app_id';
  static const _volcAccessToken = 'stt_volcengine_access_token';

  static const _aliAccessKeyId = 'stt_aliyun_access_key_id';
  static const _aliAccessKeySecret = 'stt_aliyun_access_key_secret';
  static const _aliAppKey = 'stt_aliyun_app_key';

  // Volcengine
  Future<String?> get volcAppId => _storage.read(key: _volcAppId);
  Future<void> setVolcAppId(String v) => _storage.write(key: _volcAppId, value: v);
  Future<String?> get volcAccessToken => _storage.read(key: _volcAccessToken);
  Future<void> setVolcAccessToken(String v) => _storage.write(key: _volcAccessToken, value: v);

  // Alibaba
  Future<String?> get aliAccessKeyId => _storage.read(key: _aliAccessKeyId);
  Future<void> setAliAccessKeyId(String v) => _storage.write(key: _aliAccessKeyId, value: v);
  Future<String?> get aliAccessKeySecret => _storage.read(key: _aliAccessKeySecret);
  Future<void> setAliAccessKeySecret(String v) => _storage.write(key: _aliAccessKeySecret, value: v);
  Future<String?> get aliAppKey => _storage.read(key: _aliAppKey);
  Future<void> setAliAppKey(String v) => _storage.write(key: _aliAppKey, value: v);

  Future<bool> hasCredentials(SttProviderType type) async {
    switch (type) {
      case SttProviderType.system:
        return true;
      case SttProviderType.volcengine:
        final a = await volcAppId;
        final b = await volcAccessToken;
        return a != null && a.isNotEmpty && b != null && b.isNotEmpty;
      case SttProviderType.alibaba:
        final a = await aliAccessKeyId;
        final b = await aliAccessKeySecret;
        final c = await aliAppKey;
        return a != null && a.isNotEmpty && b != null && b.isNotEmpty && c != null && c.isNotEmpty;
    }
  }
}
