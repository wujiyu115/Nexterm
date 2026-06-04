import 'dart:async';

import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SystemSttProvider implements SttProvider {
  final SpeechToText _speech = SpeechToText();
  StreamController<SttResult>? _controller;
  bool _initialized = false;

  @override
  Future<bool> isAvailable() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  @override
  Stream<SttResult> start({String? localeId}) {
    _controller?.close();
    _controller = StreamController<SttResult>();
    _speech.listen(
      onResult: (result) {
        _controller?.add(SttResult(
          text: result.recognizedWords,
          isFinal: result.finalResult,
        ));
        if (result.finalResult) {
          _controller?.close();
          _controller = null;
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        localeId: localeId,
      ),
    );
    _speech.statusListener = (status) {
      if (status == 'done' || status == 'notListening') {
        Future.delayed(const Duration(milliseconds: 200), () {
          _controller?.close();
          _controller = null;
        });
      }
    };
    return _controller!.stream;
  }

  @override
  Future<void> stop() async {
    await _speech.stop();
    _controller?.close();
    _controller = null;
  }

  @override
  Future<int> testSpeed() async => 0;

  @override
  void dispose() {
    _speech.stop();
    _controller?.close();
  }
}
