import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;

class ImageViewerScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String filePath;

  const ImageViewerScreen({
    super.key,
    required this.sessionId,
    required this.filePath,
  });

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  SftpService? _sftpService;
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _error;

  String get _fileName => p.basename(widget.filePath);

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _sftpService?.disconnect();
    super.dispose();
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sshService = ref.read(sshServiceProvider);
      final client = sshService.getClient(widget.sessionId);
      if (client == null) {
        throw StateError('No active SSH session for id: ${widget.sessionId}');
      }

      final sftpService = SftpService();
      await sftpService.connect(client);
      _sftpService = sftpService;

      final bytes = await sftpService.readFile(widget.filePath);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
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
      appBar: AppBar(
        title: Text(_fileName, style: const TextStyle(fontFamily: 'monospace')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(l)
              : _buildImageView(),
    );
  }

  Widget _buildError(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(l.fileEditor_loadFailed(_error!)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadImage,
            child: Text(l.common_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildImageView() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.fileEditor_loadFailed(error.toString())),
              ],
            );
          },
        ),
      ),
    );
  }
}
