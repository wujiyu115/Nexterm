import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class AliyunTokenService {
  final Dio _dio = Dio();
  String? _cachedToken;
  int _expireTime = 0;

  Future<String> getToken({
    required String accessKeyId,
    required String accessKeySecret,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (_cachedToken != null && _expireTime > now + 60) {
      return _cachedToken!;
    }

    final params = {
      'Action': 'CreateToken',
      'Version': '2019-02-28',
      'Format': 'JSON',
      'AccessKeyId': accessKeyId,
      'SignatureMethod': 'HMAC-SHA1',
      'SignatureVersion': '1.0',
      'SignatureNonce': DateTime.now().microsecondsSinceEpoch.toString(),
      'Timestamp': DateTime.now().toUtc().toIso8601String().replaceAll(RegExp(r'\.\d+'), ''),
    };

    final sortedKeys = params.keys.toList()..sort();
    final canonicalized = sortedKeys
        .map((k) => '${_percentEncode(k)}=${_percentEncode(params[k]!)}')
        .join('&');

    final stringToSign = 'GET&${_percentEncode("/")}&${_percentEncode(canonicalized)}';
    final signingKey = '$accessKeySecret&';
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final signature = base64Encode(hmac.convert(utf8.encode(stringToSign)).bytes);

    params['Signature'] = signature;

    final resp = await _dio.get(
      'https://nls-meta.cn-shanghai.aliyuncs.com/',
      queryParameters: params,
    );

    final data = resp.data;
    if (data is Map && data['Token'] != null) {
      _cachedToken = data['Token']['Id'] as String;
      _expireTime = data['Token']['ExpireTime'] as int;
      return _cachedToken!;
    }

    throw Exception('Failed to get Aliyun NLS token: $data');
  }

  static String _percentEncode(String s) {
    return Uri.encodeComponent(s)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }

  void dispose() {
    _dio.close();
  }
}
