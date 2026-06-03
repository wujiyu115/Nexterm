import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;
  final _controller = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get stream => _controller.stream;

  Future<void> start() async {
    if (!await _recorder.hasPermission()) return;
    final recordStream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        sampleRate: 16000,
      ),
    );
    _sub = recordStream.listen(
      (data) => _controller.add(data),
      onError: (e) => _controller.addError(e),
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _recorder.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
    _recorder.dispose();
  }
}
