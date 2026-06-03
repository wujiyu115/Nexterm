import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nexterm/features/terminal/services/stt/audio_recorder_service.dart';
import 'package:nexterm/features/terminal/services/stt/stt_credential_service.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VolcengineSttProvider implements SttProvider {
  final SttCredentialService _credentials;
  AudioRecorderService? _recorder;
  StreamController<SttResult>? _controller;
  StreamSubscription<Uint8List>? _audioSub;
  WebSocketChannel? _ws;

  static const _wsUrl = 'wss://openspeech.bytedance.com/api/v3/sauc/bigmodel';
  static const _resourceId = 'volc.seedasr.sauc.duration';

  VolcengineSttProvider({required SttCredentialService credentials})
      : _credentials = credentials;

  @override
  Future<bool> isAvailable() => _credentials.hasCredentials(SttProviderType.volcengine);

  @override
  Stream<SttResult> start({String? localeId}) {
    _controller?.close();
    _controller = StreamController<SttResult>();
    _recorder = AudioRecorderService();

    _startStreaming(localeId: localeId);

    return _controller!.stream;
  }

  Future<void> _startStreaming({String? localeId}) async {
    try {
      final appKey = await _credentials.volcAppId;
      final accessKey = await _credentials.volcAccessToken;

      if (appKey == null || accessKey == null) {
        throw Exception('Volcengine credentials not configured');
      }

      final connectId = const Uuid().v4();
      _ws = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        headers: {
          'X-Api-App-Key': appKey,
          'X-Api-Access-Key': accessKey,
          'X-Api-Resource-Id': _resourceId,
          'X-Api-Connect-Id': connectId,
        },
      );

      await _ws!.ready;

      _ws!.stream.listen(
        (data) {
          if (data is List<int>) {
            _handleServerMessage(Uint8List.fromList(data));
          }
        },
        onError: (e) => _controller?.addError(e),
        onDone: () {},
      );

      final config = {
        'user': {'uid': connectId},
        'audio': {
          'format': 'pcm',
          'rate': 16000,
          'bits': 16,
          'channel': 1,
          'language': localeId ?? 'zh-CN',
        },
        'request': {
          'model_name': 'bigmodel',
          'enable_itn': true,
          'enable_punc': true,
          'result_type': 'full',
          'show_utterances': true,
        },
      };

      _sendFullClientRequest(config);

      await _recorder!.start();
      _audioSub = _recorder!.stream.listen((data) {
        _sendAudioData(data, last: false);
      });
    } catch (e) {
      _controller?.addError(e);
    }
  }

  @override
  Future<void> stop() async {
    await _audioSub?.cancel();
    _audioSub = null;
    await _recorder?.stop();

    if (_ws != null) {
      _sendAudioData(Uint8List(0), last: true);
      await Future.delayed(const Duration(seconds: 3));
    }

    await _cleanup();
  }

  Future<void> _cleanup() async {
    await _ws?.sink.close();
    _ws = null;
    _controller?.close();
    _controller = null;
    await _recorder?.dispose();
    _recorder = null;
  }

  void _handleServerMessage(Uint8List data) {
    if (data.length < 4) return;

    final msgType = (data[1] >> 4) & 0x0F;
    final flags = data[1] & 0x0F;
    final serialization = (data[2] >> 4) & 0x0F;
    final compression = data[2] & 0x0F;

    if (msgType == 0x09) {
      // Full server response: Header(4) + Sequence(4) + PayloadSize(4) + Payload
      if (data.length < 12) return;
      final payloadSize = ByteData.sublistView(data, 8, 12).getUint32(0);
      if (data.length < 12 + payloadSize) return;

      var payload = data.sublist(12, 12 + payloadSize);
      if (compression == 0x01) {
        payload = Uint8List.fromList(gzip.decode(payload));
      }

      if (serialization == 0x01 && payload.isNotEmpty) {
        try {
          final json = jsonDecode(utf8.decode(payload));
          _handleResult(json, flags);
        } catch (_) {}
      }
    } else if (msgType == 0x0F) {
      // Error: Header(4) + ErrorCode(4) + ErrorMsgSize(4) + ErrorMsg
      if (data.length < 12) return;
      final errorCode = ByteData.sublistView(data, 4, 8).getUint32(0);
      final msgSize = ByteData.sublistView(data, 8, 12).getUint32(0);
      var errMsg = 'error code: $errorCode';
      if (data.length >= 12 + msgSize && msgSize > 0) {
        errMsg = utf8.decode(data.sublist(12, 12 + msgSize));
      }
      _controller?.addError(Exception('Volcengine error ($errorCode): $errMsg'));
    }
  }

  void _handleResult(dynamic json, int flags) {
    if (json is! Map) return;
    final result = json['result'];
    if (result == null) return;

    final text = result['text'] as String? ?? '';
    if (text.isEmpty) return;

    final utterances = result['utterances'] as List?;
    final isFinal = (flags & 0x02) != 0 ||
        (utterances != null &&
            utterances.isNotEmpty &&
            utterances.last['definite'] == true);

    _controller?.add(SttResult(text: text, isFinal: isFinal));
  }

  void _sendFullClientRequest(Map<String, dynamic> config) {
    final jsonBytes = utf8.encode(jsonEncode(config));
    final compressed = Uint8List.fromList(gzip.encode(jsonBytes));

    final frame = _buildFrame(
      messageType: 0x01,
      flags: 0x00,
      serialization: 0x01,
      compression: 0x01,
      payload: compressed,
    );
    _ws?.sink.add(frame);
  }

  void _sendAudioData(Uint8List audio, {required bool last}) {
    final compressed = Uint8List.fromList(gzip.encode(audio));

    final frame = _buildFrame(
      messageType: 0x02,
      flags: last ? 0x02 : 0x00,
      serialization: 0x00,
      compression: 0x01,
      payload: compressed,
    );
    _ws?.sink.add(frame);
  }

  Uint8List _buildFrame({
    required int messageType,
    required int flags,
    required int serialization,
    required int compression,
    required Uint8List payload,
  }) {
    final frame = Uint8List(8 + payload.length);
    frame[0] = 0x11; // protocol v1, header size 1 (4 bytes)
    frame[1] = (messageType << 4) | (flags & 0x0F);
    frame[2] = (serialization << 4) | (compression & 0x0F);
    frame[3] = 0x00;
    ByteData.sublistView(frame, 4, 8).setUint32(0, payload.length);
    frame.setRange(8, 8 + payload.length, payload);
    return frame;
  }

  @override
  Future<int> testSpeed() async {
    final appKey = await _credentials.volcAppId;
    final accessKey = await _credentials.volcAccessToken;

    if (appKey == null || accessKey == null) {
      throw Exception('Volcengine credentials not configured');
    }

    final sw = Stopwatch()..start();
    final connectId = const Uuid().v4();

    final ws = IOWebSocketChannel.connect(
      Uri.parse(_wsUrl),
      headers: {
        'X-Api-App-Key': appKey,
        'X-Api-Access-Key': accessKey,
        'X-Api-Resource-Id': _resourceId,
        'X-Api-Connect-Id': connectId,
      },
    );

    await ws.ready;

    final completer = Completer<void>();
    ws.stream.listen(
      (data) {
        if (data is List<int> && !completer.isCompleted) {
          final bytes = Uint8List.fromList(data);
          if (bytes.length >= 4) {
            final msgType = (bytes[1] >> 4) & 0x0F;
            if (msgType == 0x0F) {
              // Error
              var errMsg = 'Unknown error';
              if (bytes.length >= 12) {
                final code = ByteData.sublistView(bytes, 4, 8).getUint32(0);
                final size = ByteData.sublistView(bytes, 8, 12).getUint32(0);
                if (bytes.length >= 12 + size && size > 0) {
                  errMsg = utf8.decode(bytes.sublist(12, 12 + size));
                }
                completer.completeError(Exception('Volcengine ($code): $errMsg'));
              }
            } else if (msgType == 0x09) {
              completer.complete();
            }
          }
        }
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
    );

    // Send config
    final config = {
      'user': {'uid': connectId},
      'audio': {
        'format': 'pcm',
        'rate': 16000,
        'bits': 16,
        'channel': 1,
        'language': 'zh-CN',
      },
      'request': {
        'model_name': 'bigmodel',
        'enable_itn': true,
        'enable_punc': true,
        'result_type': 'full',
      },
    };

    final configJson = utf8.encode(jsonEncode(config));
    final configCompressed = Uint8List.fromList(gzip.encode(configJson));
    ws.sink.add(_buildFrame(
      messageType: 0x01,
      flags: 0x00,
      serialization: 0x01,
      compression: 0x01,
      payload: configCompressed,
    ));

    // Send 1s silent PCM as last packet
    final silent = Uint8List(16000 * 2);
    final audioCompressed = Uint8List.fromList(gzip.encode(silent));
    ws.sink.add(_buildFrame(
      messageType: 0x02,
      flags: 0x02,
      serialization: 0x00,
      compression: 0x01,
      payload: audioCompressed,
    ));

    await completer.future.timeout(const Duration(seconds: 10));
    await ws.sink.close();

    sw.stop();
    return sw.elapsedMilliseconds;
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    _recorder?.dispose();
    _controller?.close();
    _ws?.sink.close();
  }
}
