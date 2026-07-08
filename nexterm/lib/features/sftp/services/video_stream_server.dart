import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

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

  // Single remote connection: serialize reads so seeks never overlap on the
  // shared SMB session.
  Future<void> _readLock = Future.value();

  bool get isDisposed => _disposed;

  Future<String> start(RemoteFileService service, String remotePath) async {
    _service = service;
    _remotePath = remotePath;

    final stat = await service.stat(remotePath);
    _totalBytes = stat.size;
    debugPrint('[StreamServer] size: $_totalBytes bytes');

    final ext = p.extension(remotePath).replaceFirst('.', '').toLowerCase();
    _mime = _mimeTypes[ext] ?? 'application/octet-stream';

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handleRequest);
    debugPrint('[StreamServer] listening on port ${_server!.port}');

    return 'http://localhost:${_server!.port}/video';
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
      await _serveViaReadRange(request, start, length);
    } catch (e) {
      if (!_disposed) debugPrint('[StreamServer] serve error: $e');
    }
    try {
      await request.response.close();
    } catch (_) {}
  }

  Future<void> _serveViaReadRange(
      HttpRequest request, int start, int length) async {
    final service = _service;
    final remotePath = _remotePath;
    if (service == null || remotePath == null) return;

    debugPrint('[StreamServer] readRange $start +$length');
    int offset = start;
    int remaining = length;
    while (remaining > 0 && !_disposed) {
      final readLen = remaining > _readRangeChunk ? _readRangeChunk : remaining;
      final Uint8List chunk;
      try {
        chunk = await _lockedReadRange(service, remotePath, offset, readLen);
      } catch (e) {
        if (!_disposed) debugPrint('[StreamServer] readRange error: $e');
        break;
      }
      if (chunk.isEmpty || _disposed) break;
      request.response.add(chunk);
      offset += chunk.length;
      remaining -= chunk.length;
    }
  }

  Future<Uint8List> _lockedReadRange(
      RemoteFileService service, String remotePath, int offset, int len) {
    final completer = Completer<Uint8List>();
    _readLock = _readLock.then((_) async {
      try {
        completer.complete(await service.readRange(remotePath, offset, len));
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  Future<void> dispose() async {
    _disposed = true;
    await _server?.close(force: true);
    _server = null;
    _service = null;
    _remotePath = null;
    debugPrint('[StreamServer] disposed');
  }
}
