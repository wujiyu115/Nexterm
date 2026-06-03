import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:nexterm/features/terminal/services/stt/aliyun_token_service.dart';
import 'package:nexterm/features/terminal/services/stt/audio_recorder_service.dart';
import 'package:nexterm/features/terminal/services/stt/stt_credential_service.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AliyunSttProvider implements SttProvider {
  final SttCredentialService _credentials;
  final AliyunTokenService _tokenService = AliyunTokenService();
  AudioRecorderService? _recorder;
  WebSocketChannel? _channel;
  StreamController<SttResult>? _controller;
  StreamSubscription? _wsSub;
  StreamSubscription<Uint8List>? _audioSub;
  String? _taskId;

  AliyunSttProvider({required SttCredentialService credentials})
      : _credentials = credentials;

  @override
  Future<bool> isAvailable() => _credentials.hasCredentials(SttProviderType.alibaba);

  String _randomHex(int length) {
    final r = Random.secure();
    return List.generate(length, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  @override
  Stream<SttResult> start({String? localeId}) {
    _controller?.close();
    _controller = StreamController<SttResult>();
    _startAsync();
    return _controller!.stream;
  }

  Future<void> _startAsync() async {
    try {
      final accessKeyId = await _credentials.aliAccessKeyId;
      final accessKeySecret = await _credentials.aliAccessKeySecret;
      final appKey = await _credentials.aliAppKey;

      if (accessKeyId == null || accessKeySecret == null || appKey == null) {
        throw Exception('Aliyun NLS credentials not configured');
      }

      final token = await _tokenService.getToken(
        accessKeyId: accessKeyId,
        accessKeySecret: accessKeySecret,
      );

      _taskId = _randomHex(32);
      final wsUrl = 'wss://nls-gateway-cn-shanghai.aliyuncs.com/ws/v1?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      _wsSub = _channel!.stream.listen(
        (data) {
          if (data is String) _handleMessage(jsonDecode(data));
        },
        onError: (e) => _controller?.addError(e),
        onDone: () => _controller?.close(),
      );

      // Send StartTranscription
      _channel!.sink.add(jsonEncode({
        'header': {
          'appkey': appKey,
          'message_id': _randomHex(32),
          'task_id': _taskId,
          'namespace': 'SpeechTranscriber',
          'name': 'StartTranscription',
        },
        'payload': {
          'format': 'pcm',
          'sample_rate': 16000,
          'enable_intermediate_result': true,
          'enable_punctuation_prediction': true,
          'enable_inverse_text_normalization': true,
          'max_sentence_silence': 800,
        },
      }));
    } catch (e) {
      _controller?.addError(e);
      _controller?.close();
    }
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final header = msg['header'] as Map<String, dynamic>?;
    if (header == null) return;
    final name = header['name'] as String?;
    final payload = msg['payload'] as Map<String, dynamic>?;

    switch (name) {
      case 'TranscriptionStarted':
        _startAudioCapture();
      case 'TranscriptionResultChanged':
        final text = payload?['result'] as String? ?? '';
        if (text.isNotEmpty) {
          _controller?.add(SttResult(text: text, isFinal: false));
        }
      case 'SentenceEnd':
        final text = payload?['result'] as String? ?? '';
        if (text.isNotEmpty) {
          _controller?.add(SttResult(text: text, isFinal: true));
        }
      case 'TranscriptionCompleted':
        _controller?.close();
      case 'TaskFailed':
        final statusText = header['status_message'] as String? ?? 'Unknown error';
        _controller?.addError(Exception('Aliyun NLS: $statusText'));
        _controller?.close();
    }
  }

  void _startAudioCapture() {
    _recorder = AudioRecorderService();
    _recorder!.start().then((_) {
      _audioSub = _recorder!.stream.listen((data) {
        _channel?.sink.add(data);
      });
    });
  }

  @override
  Future<void> stop() async {
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder?.stop();

    if (_channel != null && _taskId != null) {
      final appKey = await _credentials.aliAppKey;
      _channel!.sink.add(jsonEncode({
        'header': {
          'appkey': appKey,
          'message_id': _randomHex(32),
          'task_id': _taskId,
          'namespace': 'SpeechTranscriber',
          'name': 'StopTranscription',
        },
      }));

      await Future.delayed(const Duration(seconds: 2));
    }

    await _wsSub?.cancel();
    _wsSub = null;
    await _channel?.sink.close();
    _channel = null;
    _taskId = null;
    await _recorder?.dispose();
    _recorder = null;
  }

  @override
  Future<int> testSpeed() async {
    final accessKeyId = await _credentials.aliAccessKeyId;
    final accessKeySecret = await _credentials.aliAccessKeySecret;
    final appKey = await _credentials.aliAppKey;
    if (accessKeyId == null || accessKeySecret == null || appKey == null) {
      throw Exception('Credentials not configured');
    }

    final sw = Stopwatch()..start();
    final token = await _tokenService.getToken(
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
    );

    final taskId = _randomHex(32);
    final wsUrl = 'wss://nls-gateway-cn-shanghai.aliyuncs.com/ws/v1?token=$token';
    final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    await channel.ready;

    final completer = Completer<void>();
    channel.stream.listen((data) {
      if (data is String) {
        final msg = jsonDecode(data);
        final name = msg['header']?['name'];
        if (name == 'TranscriptionStarted' || name == 'TaskFailed') {
          completer.complete();
        }
      }
    });

    channel.sink.add(jsonEncode({
      'header': {
        'appkey': appKey,
        'message_id': _randomHex(32),
        'task_id': taskId,
        'namespace': 'SpeechTranscriber',
        'name': 'StartTranscription',
      },
      'payload': {
        'format': 'pcm',
        'sample_rate': 16000,
      },
    }));

    await completer.future.timeout(const Duration(seconds: 10));
    await channel.sink.close();
    sw.stop();
    return sw.elapsedMilliseconds;
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    _wsSub?.cancel();
    _channel?.sink.close();
    _recorder?.dispose();
    _controller?.close();
    _tokenService.dispose();
  }
}
