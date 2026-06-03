import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:nexterm/features/terminal/services/stt/audio_recorder_service.dart';
import 'package:nexterm/features/terminal/services/stt/stt_credential_service.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:uuid/uuid.dart';

class VolcengineSttProvider implements SttProvider {
  final SttCredentialService _credentials;
  final Dio _dio = Dio();
  AudioRecorderService? _recorder;
  StreamController<SttResult>? _controller;
  final _audioBuffer = BytesBuilder();
  StreamSubscription<Uint8List>? _audioSub;

  static const _submitUrl = 'https://openspeech.bytedance.com/api/v3/auc/bigmodel/submit';
  static const _queryUrl = 'https://openspeech.bytedance.com/api/v3/auc/bigmodel/query';

  VolcengineSttProvider({required SttCredentialService credentials})
      : _credentials = credentials;

  @override
  Future<bool> isAvailable() => _credentials.hasCredentials(SttProviderType.volcengine);

  @override
  Stream<SttResult> start({String? localeId}) {
    _controller?.close();
    _controller = StreamController<SttResult>();
    _audioBuffer.clear();
    _recorder = AudioRecorderService();

    _recorder!.start().then((_) {
      _audioSub = _recorder!.stream.listen((data) {
        _audioBuffer.add(data);
      });
    });

    return _controller!.stream;
  }

  @override
  Future<void> stop() async {
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder?.stop();

    final audio = _audioBuffer.toBytes();
    _audioBuffer.clear();

    if (audio.isEmpty) {
      _controller?.close();
      _controller = null;
      return;
    }

    try {
      final text = await _recognize(audio);
      if (text.isNotEmpty) {
        _controller?.add(SttResult(text: text, isFinal: true));
      }
    } catch (e) {
      _controller?.addError(e);
    } finally {
      _controller?.close();
      _controller = null;
      await _recorder?.dispose();
      _recorder = null;
    }
  }

  Future<String> _recognize(Uint8List audio, {String? language}) async {
    final appKey = await _credentials.volcAppId;
    final accessKey = await _credentials.volcAccessToken;
    final resourceId = await _credentials.volcResourceId;
    final requestId = const Uuid().v4().replaceAll('-', '');

    final headers = {
      'X-Api-App-Key': appKey,
      'X-Api-Access-Key': accessKey,
      'X-Api-Resource-Id': resourceId ?? 'volc.bigasr.auc',
      'X-Api-Request-Id': requestId,
      'X-Api-Sequence': '-1',
      'Content-Type': 'application/json',
    };

    final body = {
      'audio': {
        'format': 'raw',
        'codec': 'raw',
        'rate': 16000,
        'bits': 16,
        'channel': 1,
        if (language != null) 'language': language,
        'url': '',
      },
      'request': {
        'model_name': 'bigmodel',
        'enable_itn': true,
        'enable_punc': true,
      },
    };

    final audioBase64 = base64Encode(audio);
    body['audio'] = {
      ...(body['audio'] as Map<String, dynamic>),
      'data': audioBase64,
    };

    // Submit
    final submitResp = await _dio.post(
      _submitUrl,
      data: jsonEncode(body),
      options: Options(headers: headers),
    );

    if (submitResp.statusCode != 200) {
      throw Exception('Volcengine submit failed: ${submitResp.statusCode}');
    }

    // Poll for result
    final queryHeaders = {
      'X-Api-App-Key': appKey,
      'X-Api-Access-Key': accessKey,
      'X-Api-Resource-Id': resourceId ?? 'volc.bigasr.auc',
      'X-Api-Request-Id': requestId,
      'X-Api-Sequence': '-1',
    };

    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      final queryResp = await _dio.post(
        _queryUrl,
        options: Options(headers: queryHeaders),
      );

      final statusCode = queryResp.headers.value('X-Api-Status-Code');
      if (statusCode == '20000000') {
        final data = queryResp.data;
        if (data is Map && data['result'] != null) {
          return data['result']['text'] as String? ?? '';
        }
        return '';
      }
      if (statusCode != '20000001' && statusCode != '20000002') {
        throw Exception('Volcengine error: $statusCode');
      }
    }
    throw Exception('Volcengine recognition timeout');
  }

  @override
  Future<int> testSpeed() async {
    final sw = Stopwatch()..start();
    final silent = Uint8List(16000 * 2); // 1 second silence
    await _recognize(silent);
    sw.stop();
    return sw.elapsedMilliseconds;
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    _recorder?.dispose();
    _controller?.close();
    _dio.close();
  }
}
