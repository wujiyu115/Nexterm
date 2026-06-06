@TestOn('vm')
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const _wsUrl = 'wss://openspeech.bytedance.com/api/v3/sauc/bigmodel_nostream';
const _resourceId = 'volc.seedasr.sauc.duration';

String _generateUuid() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
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
  frame[0] = 0x11;
  frame[1] = (messageType << 4) | (flags & 0x0F);
  frame[2] = (serialization << 4) | (compression & 0x0F);
  frame[3] = 0x00;
  ByteData.sublistView(frame, 4, 8).setInt32(0, seq);
  ByteData.sublistView(frame, 8, 12).setUint32(0, payload.length);
  frame.setRange(12, 12 + payload.length, payload);
  return frame;
}

Map<String, dynamic> _parseResponse(Uint8List msg) {
  final headerSize = (msg[0] & 0x0F) * 4;
  final msgType = (msg[1] >> 4) & 0x0F;
  final flags = msg[1] & 0x0F;
  final serializationMethod = (msg[2] >> 4) & 0x0F;
  final compression = msg[2] & 0x0F;

  var offset = headerSize;
  int payloadSequence = 0;
  bool isLast = false;
  int event = 0;

  if (flags & 0x01 != 0) {
    payloadSequence = ByteData.sublistView(msg, offset, offset + 4).getInt32(0);
    offset += 4;
  }
  if (flags & 0x02 != 0) {
    isLast = true;
  }
  if (flags & 0x04 != 0) {
    event = ByteData.sublistView(msg, offset, offset + 4).getInt32(0);
    offset += 4;
  }

  int code = 0;
  int payloadSize = 0;

  if (msgType == 0x09) {
    payloadSize = ByteData.sublistView(msg, offset, offset + 4).getUint32(0);
    offset += 4;
  } else if (msgType == 0x0F) {
    code = ByteData.sublistView(msg, offset, offset + 4).getInt32(0);
    payloadSize = ByteData.sublistView(msg, offset + 4, offset + 8).getUint32(0);
    offset += 8;
  }

  dynamic payloadMsg;
  if (offset < msg.length) {
    var payload = msg.sublist(offset);
    if (compression == 0x01) {
      payload = Uint8List.fromList(gzip.decode(payload));
    }
    if (serializationMethod == 0x01) {
      payloadMsg = jsonDecode(utf8.decode(payload));
    }
  }

  return {
    'code': code,
    'event': event,
    'is_last_package': isLast,
    'payload_sequence': payloadSequence,
    'payload_size': payloadSize,
    'payload_msg': payloadMsg,
  };
}

void main() {
  test('Volcengine STT recognizes Chinese speech from WAV file', () async {
    final appKey = Platform.environment['VOLC_APP_KEY'];
    final accessKey = Platform.environment['VOLC_ACCESS_KEY'];
    if (appKey == null || accessKey == null) {
      markTestSkipped('Set VOLC_APP_KEY and VOLC_ACCESS_KEY env vars');
      return;
    }

    final wavFile = File('${Directory.current.path}/../test_chinese.wav');
    if (!wavFile.existsSync()) {
      fail('test_chinese.wav not found at ${wavFile.path}');
    }
    final wavData = wavFile.readAsBytesSync();

    final requestId = _generateUuid();

    final ws = await WebSocket.connect(
      _wsUrl,
      headers: {
        'X-Api-Resource-Id': _resourceId,
        'X-Api-Request-Id': requestId,
        'X-Api-Access-Key': accessKey,
        'X-Api-App-Key': appKey,
      },
    );

    final responses = <Map<String, dynamic>>[];
    final done = Completer<void>();

    ws.listen(
      (data) {
        if (data is List<int>) {
          final resp = _parseResponse(Uint8List.fromList(data));
          responses.add(resp);
          if (resp['is_last_package'] == true || resp['code'] != 0) {
            if (!done.isCompleted) done.complete();
          }
        }
      },
      onError: (e) {
        if (!done.isCompleted) done.completeError(e);
      },
      onDone: () {
        if (!done.isCompleted) done.complete();
      },
    );

    var seq = 1;

    // Send config — match Python demo exactly
    final config = {
      'user': {'uid': 'test_uid'},
      'audio': {
        'format': 'wav',
        'codec': 'raw',
        'rate': 16000,
        'bits': 16,
        'channel': 1,
      },
      'request': {
        'model_name': 'bigmodel',
        'enable_itn': true,
        'enable_punc': true,
        'enable_ddc': true,
        'show_utterances': true,
        'enable_nonstream': false,
      },
    };

    final configBytes = utf8.encode(jsonEncode(config));
    final configCompressed = Uint8List.fromList(gzip.encode(configBytes));
    ws.add(_buildFrame(
      messageType: 0x01,
      flags: 0x01,
      serialization: 0x01,
      compression: 0x01,
      seq: seq,
      payload: configCompressed,
    ));
    seq++;

    // Split WAV into 200ms segments and send
    const segmentDuration = 200;
    const sizePerSec = 1 * 2 * 16000;
    const segmentSize = sizePerSec * segmentDuration ~/ 1000;

    final segments = <Uint8List>[];
    for (var i = 0; i < wavData.length; i += segmentSize) {
      var end = i + segmentSize;
      if (end > wavData.length) end = wavData.length;
      segments.add(Uint8List.fromList(wavData.sublist(i, end)));
    }

    for (var i = 0; i < segments.length; i++) {
      final isLast = i == segments.length - 1;
      final audioCompressed = Uint8List.fromList(gzip.encode(segments[i]));
      final s = isLast ? -seq : seq;

      ws.add(_buildFrame(
        messageType: 0x02,
        flags: isLast ? 0x03 : 0x01,
        serialization: 0x00,
        compression: 0x01,
        seq: s,
        payload: audioCompressed,
      ));

      if (!isLast) seq++;
      await Future.delayed(const Duration(milliseconds: segmentDuration));
    }

    await done.future.timeout(const Duration(seconds: 30));
    await ws.close();

    // Verify result
    final lastResponse = responses.last;
    expect(lastResponse['code'], equals(0), reason: 'Server returned error');
    expect(lastResponse['is_last_package'], isTrue);

    final text = lastResponse['payload_msg']?['result']?['text'] as String?;
    expect(text, isNotNull, reason: 'No recognized text in response');
    expect(text, contains('你好'), reason: 'Text should contain "你好", got: $text');

    // ignore: avoid_print
    print('Recognized: $text');
  }, timeout: const Timeout(Duration(seconds: 60)));
}
