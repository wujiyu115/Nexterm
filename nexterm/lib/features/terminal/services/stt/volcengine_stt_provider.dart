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
  int _seq = 1;

  static const _wsUrl = 'wss://openspeech.bytedance.com/api/v3/sauc/bigmodel_nostream';
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

      final requestId = const Uuid().v4();
      _seq = 1;

      _ws = IOWebSocketChannel.connect(
        _wsUrl,
        headers: {
          'X-Api-App-Key': appKey,
          'X-Api-Access-Key': accessKey,
          'X-Api-Resource-Id': _resourceId,
          'X-Api-Request-Id': requestId,
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
        'user': {'uid': requestId},
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

    final headerSize = (data[0] & 0x0F) * 4;
    final msgType = (data[1] >> 4) & 0x0F;
    final flags = data[1] & 0x0F;
    final serialization = (data[2] >> 4) & 0x0F;
    final compression = data[2] & 0x0F;

    var offset = headerSize;

    if (flags & 0x01 != 0) {
      if (data.length < offset + 4) return;
      offset += 4;
    }
    final isLast = (flags & 0x02) != 0;
    if (flags & 0x04 != 0) {
      if (data.length < offset + 4) return;
      offset += 4;
    }

    if (msgType == 0x09) {
      if (data.length < offset + 4) return;
      final payloadSize = ByteData.sublistView(data, offset, offset + 4).getUint32(0);
      offset += 4;
      if (data.length < offset + payloadSize) return;

      var payload = data.sublist(offset, offset + payloadSize);
      if (compression == 0x01) {
        payload = Uint8List.fromList(gzip.decode(payload));
      }

      if (serialization == 0x01 && payload.isNotEmpty) {
        try {
          final json = jsonDecode(utf8.decode(payload));
          _handleResult(json, isLast);
        } catch (_) {}
      }
    } else if (msgType == 0x0F) {
      if (data.length < offset + 8) return;
      final errorCode = ByteData.sublistView(data, offset, offset + 4).getInt32(0);
      final msgSize = ByteData.sublistView(data, offset + 4, offset + 8).getUint32(0);
      offset += 8;
      var errMsg = 'error code: $errorCode';
      if (data.length >= offset + msgSize && msgSize > 0) {
        errMsg = utf8.decode(data.sublist(offset, offset + msgSize));
      }
      _controller?.addError(Exception('Volcengine error ($errorCode): $errMsg'));
    }
  }

  void _handleResult(dynamic json, bool isLast) {
    if (json is! Map) return;
    final result = json['result'];
    if (result == null) return;

    final text = result['text'] as String? ?? '';
    if (text.isEmpty) return;

    final utterances = result['utterances'] as List?;
    final isFinal = isLast ||
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
      flags: 0x01, // POS_SEQUENCE
      serialization: 0x01,
      compression: 0x01,
      seq: _seq,
      payload: compressed,
    );
    _seq++;
    _ws?.sink.add(frame);
  }

  void _sendAudioData(Uint8List audio, {required bool last}) {
    final compressed = Uint8List.fromList(gzip.encode(audio));

    final seq = last ? -_seq : _seq;
    final frame = _buildFrame(
      messageType: 0x02,
      flags: last ? 0x03 : 0x01, // NEG_WITH_SEQUENCE or POS_SEQUENCE
      serialization: 0x00,
      compression: 0x01,
      seq: seq,
      payload: compressed,
    );
    if (!last) _seq++;
    _ws?.sink.add(frame);
  }

  Uint8List _buildFrame({
    required int messageType,
    required int flags,
    required int serialization,
    required int compression,
    required int seq,
    required Uint8List payload,
  }) {
    final frame = Uint8List(12 + payload.length);
    frame[0] = 0x11; // protocol v1, header size 1 (4 bytes)
    frame[1] = (messageType << 4) | (flags & 0x0F);
    frame[2] = (serialization << 4) | (compression & 0x0F);
    frame[3] = 0x00;
    ByteData.sublistView(frame, 4, 8).setInt32(0, seq);
    ByteData.sublistView(frame, 8, 12).setUint32(0, payload.length);
    frame.setRange(12, 12 + payload.length, payload);
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
    final requestId = const Uuid().v4();

    final ws = IOWebSocketChannel.connect(
      _wsUrl,
      headers: {
        'X-Api-App-Key': appKey,
        'X-Api-Access-Key': accessKey,
        'X-Api-Resource-Id': _resourceId,
        'X-Api-Request-Id': requestId,
      },
    );

    await ws.ready;

    final completer = Completer<void>();
    ws.stream.listen(
      (data) {
        if (data is List<int> && !completer.isCompleted) {
          final bytes = Uint8List.fromList(data);
          if (bytes.length >= 4) {
            final headerSize = (bytes[0] & 0x0F) * 4;
            final msgType = (bytes[1] >> 4) & 0x0F;
            final flags = bytes[1] & 0x0F;

            var offset = headerSize;
            if (flags & 0x01 != 0) offset += 4;
            if (flags & 0x04 != 0) offset += 4;

            if (msgType == 0x0F) {
              var errMsg = 'Unknown error';
              if (bytes.length >= offset + 8) {
                final code = ByteData.sublistView(bytes, offset, offset + 4).getInt32(0);
                final size = ByteData.sublistView(bytes, offset + 4, offset + 8).getUint32(0);
                offset += 8;
                if (bytes.length >= offset + size && size > 0) {
                  errMsg = utf8.decode(bytes.sublist(offset, offset + size));
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
      'user': {'uid': requestId},
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

    var testSeq = 1;
    final configJson = utf8.encode(jsonEncode(config));
    final configCompressed = Uint8List.fromList(gzip.encode(configJson));
    ws.sink.add(_buildFrame(
      messageType: 0x01,
      flags: 0x01, // POS_SEQUENCE
      serialization: 0x01,
      compression: 0x01,
      seq: testSeq,
      payload: configCompressed,
    ));
    testSeq++;

    // Send 1s silent PCM as last packet
    final silent = Uint8List(16000 * 2);
    final audioCompressed = Uint8List.fromList(gzip.encode(silent));
    ws.sink.add(_buildFrame(
      messageType: 0x02,
      flags: 0x03, // NEG_WITH_SEQUENCE
      serialization: 0x00,
      compression: 0x01,
      seq: -testSeq,
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
