import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/services/video_stream_server.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String? sessionId;
  final String filePath;
  final RemoteFileService? service;

  const VideoPlayerScreen({
    super.key,
    this.sessionId,
    required this.filePath,
    this.service,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  RemoteFileService? _fileService;
  bool _ownsService = false;

  late final Player _player;
  VideoController? _videoController;
  VideoStreamServer? _streamServer;

  bool _isLoading = true;
  String? _error;

  String get _fileName => p.basename(widget.filePath);

  @override
  void initState() {
    super.initState();
    _player = Player();
    _player.stream.error.listen((error) {
      debugPrint('[VideoPlayer] player error: $error');
      if (mounted && error.isNotEmpty && !error.contains('Connection refused')) {
        setState(() => _error = error);
      }
    });
    _init();
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    _streamServer?.dispose();
    if (_ownsService) _fileService?.disconnect();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await VideoStreamServer.cleanupOldTempFiles();

      final RemoteFileService fileService;
      if (widget.service != null) {
        fileService = widget.service!;
        _ownsService = false;
      } else {
        final sshService = ref.read(sshServiceProvider);
        final client = sshService.getClient(widget.sessionId!);
        if (client == null) throw StateError('No active SSH session');
        final sftpService = SftpService();
        await sftpService.connect(client);
        fileService = sftpService;
        _ownsService = true;
      }
      _fileService = fileService;

      if (fileService.supportsReadRange) {
        debugPrint('[VideoPlayer] using streaming proxy (readRange)');
        _streamServer = VideoStreamServer();
        final url = await _streamServer!.start(fileService, widget.filePath);

        final ext = p.extension(widget.filePath).toLowerCase();
        if (ext == '.ts' || ext == '.rmvb' || ext == '.rm') {
          (_player.platform as dynamic).setProperty('hwdec', 'no');
        }

        _videoController = VideoController(_player);
        debugPrint('[VideoPlayer] opening: $url');
        await _player.open(Media(url));
      } else {
        debugPrint('[VideoPlayer] readRange not supported, downloading first');
        // TODO: fallback to download-then-play for SFTP/WebDAV
        throw UnimplementedError('Streaming not supported for this protocol yet');
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e, st) {
      debugPrint('[VideoPlayer] ERROR: $e\n$st');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _fileName,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      ),
      body: _error != null
          ? _buildError(l)
          : _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(l.video_loading,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              : _videoController != null
                  ? Video(controller: _videoController!)
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildError(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_error!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              _streamServer?.dispose();
              _streamServer = null;
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _init();
            },
            child: Text(l.common_retry),
          ),
        ],
      ),
    );
  }
}
