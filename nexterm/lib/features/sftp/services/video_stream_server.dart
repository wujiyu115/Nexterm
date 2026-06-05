import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'remote_file_service.dart';

const _mimeTypes = {
  'mp4': 'video/mp4',
  'mkv': 'video/x-matroska',
  'avi': 'video/x-msvideo',
  'mov': 'video/quicktime',
  'wmv': 'video/x-ms-wmv',
  'flv': 'video/x-flv',
  'webm': 'video/webm',
  'm4v': 'video/x-m4v',
  'mpg': 'video/mpeg',
  'mpeg': 'video/mpeg',
  'ts': 'video/mp2t',
  '3gp': 'video/3gpp',
};

const _readRangeChunk = 2 * 1024 * 1024;

class VideoStreamServer {
  HttpServer? _server;
  RemoteFileService? _service;
  String? _remotePath;
  int _totalBytes = 0;
  String _mime = 'application/octet-stream';
  bool _disposed = false;

  String? _cachePath;
  int _cachedBytes = 0;
  bool _downloadComplete = false;

  bool get isDisposed => _disposed;

  void Function(int downloaded, int total)? onProgress;

  static Future<void> cleanupOldTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/nexterm_video_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  Future<String> start(RemoteFileService service, String remotePath) async {
    _service = service;
    _remotePath = remotePath;

    await cleanupOldTempFiles();

    final stat = await service.stat(remotePath);
    _totalBytes = stat.size;
    debugPrint('[StreamServer] size: $_totalBytes bytes');

    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/nexterm_video_cache');
    if (!await cacheDir.exists()) await cacheDir.create();
    _cachePath = '${cacheDir.path}/${p.basename(remotePath)}';

    _startBackgroundDownload(service, remotePath);

    final ext = p.extension(remotePath).replaceFirst('.', '').toLowerCase();
    _mime = _mimeTypes[ext] ?? 'application/octet-stream';

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handleRequest);
    debugPrint('[StreamServer] listening on port ${_server!.port}');

    return 'http://localhost:${_server!.port}/video';
  }

  void _startBackgroundDownload(RemoteFileService service, String remotePath) {
    debugPrint('[StreamServer] background download starting');
    service.downloadFile(
      remotePath,
      _cachePath!,
      onProgress: (downloaded, total) {
        _cachedBytes = downloaded;
        onProgress?.call(downloaded, total);
      },
    ).then((_) {
      _downloadComplete = true;
      _cachedBytes = _totalBytes;
      debugPrint('[StreamServer] background download complete');
      onProgress?.call(_totalBytes, _totalBytes);
    }).catchError((e) {
      if (!_disposed) debugPrint('[StreamServer] download error: $e');
    });
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (_disposed) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
      await request.response.close();
      return;
    }

    final rangeHeader = request.headers.value('range');
    int start = 0;
    int end = _totalBytes - 1;

    if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
      final parts = rangeHeader.substring(6).split('-');
      start = int.parse(parts[0]);
      if (parts[1].isNotEmpty) {
        end = int.parse(parts[1]);
      }
      end = end.clamp(start, _totalBytes - 1);

      request.response.statusCode = HttpStatus.partialContent;
      request.response.headers
          .set('Content-Range', 'bytes $start-$end/$_totalBytes');
    } else {
      request.response.statusCode = HttpStatus.ok;
    }

    final length = end - start + 1;
    request.response.headers.set('Content-Type', _mime);
    request.response.headers.set('Content-Length', '$length');
    request.response.headers.set('Accept-Ranges', 'bytes');

    try {
      if (_canServeFromCache(start, end)) {
        await _serveFromCache(request, start, length);
      } else {
        await _serveFromRemote(request, start, length);
      }
    } catch (e) {
      if (!_disposed) debugPrint('[StreamServer] serve error: $e');
    }
    try {
      await request.response.close();
    } catch (_) {}
  }

  bool _canServeFromCache(int start, int end) {
    return _downloadComplete || (end < _cachedBytes);
  }

  Future<void> _serveFromCache(HttpRequest request, int start, int length) async {
    final file = File(_cachePath!);
    await request.response.addStream(file.openRead(start, start + length));
  }

  Future<void> _serveFromRemote(HttpRequest request, int start, int length) async {
    final service = _service;
    final remotePath = _remotePath;
    if (service == null || remotePath == null) return;

    final isSequential = _cachedBytes > 0 && start < _cachedBytes + 10 * 1024 * 1024;

    if (isSequential) {
      while (_cachedBytes <= start && !_downloadComplete && !_disposed) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_canServeFromCache(start, start + length - 1)) {
        await _serveFromCache(request, start, length);
        return;
      }
    }

    int offset = start;
    int remaining = length;
    while (remaining > 0 && !_disposed) {
      if (_canServeFromCache(offset, offset + remaining - 1)) {
        await _serveFromCache(request, offset, remaining);
        break;
      }

      final readLen = remaining > _readRangeChunk ? _readRangeChunk : remaining;
      final Uint8List chunk;
      try {
        chunk = await service.readRange(remotePath, offset, readLen);
      } catch (e) {
        if (!_disposed) debugPrint('[StreamServer] readRange error at $offset: $e');
        break;
      }
      if (chunk.isEmpty || _disposed) break;
      request.response.add(chunk);
      offset += chunk.length;
      remaining -= chunk.length;
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _server?.close(force: true);
    _server = null;
    _service = null;
    _remotePath = null;
    if (_cachePath != null) {
      try {
        final file = File(_cachePath!);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    debugPrint('[StreamServer] disposed');
  }
}
