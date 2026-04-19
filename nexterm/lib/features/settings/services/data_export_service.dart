import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:nexterm/core/crypto/crypto_service.dart';
import 'package:nexterm/domain/repositories/host_repository.dart';
import 'package:nexterm/domain/repositories/ssh_key_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataExportService {
  final HostRepository _hostRepo;
  final SSHKeyRepository _keyRepo;
  final CryptoService _crypto;

  DataExportService(this._hostRepo, this._keyRepo, this._crypto);

  Future<String> exportEncrypted(Uint8List encryptionKey) async {
    final hosts = await _hostRepo.getAll();
    final keys = await _keyRepo.getAll();

    final data = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'hosts_count': hosts.length,
      'keys_count': keys.length,
    };

    final jsonBytes = utf8.encode(jsonEncode(data));
    final encrypted = _crypto.encrypt(jsonBytes, encryptionKey);
    final b64 = base64Encode(encrypted);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/nexterm_backup_${DateTime.now().millisecondsSinceEpoch}.enc');
    await file.writeAsString(b64);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Nexterm 加密备份'));
    return file.path;
  }
}
