import 'dart:io';
import 'dart:typed_data';

import 'package:webdav_client/webdav_client.dart' as webdav;

import '../../sftp/services/remote_file_service.dart';
export '../../sftp/services/remote_file_service.dart';

/// Service implementing [RemoteFileService] for WebDAV protocol.
///
/// Uses the `webdav_client` package to communicate with WebDAV servers.
/// Some operations (e.g. [chmod]) are no-ops because WebDAV does not
/// support Unix permissions.
class WebDavService implements RemoteFileService {
  webdav.Client? _client;
  String _basePath = '/';

  @override
  bool get isConnected => _client != null;

  // ---------------------------------------------------------------------------
  // Connection management
  // ---------------------------------------------------------------------------

  /// Connects to a WebDAV server at [url].
  ///
  /// The [url] should include the full base path, e.g.
  /// `https://example.com/remote.php/dav/files/user`.
  /// Optional [username] and [password] for HTTP Basic authentication.
  void connect(String url, {String? username, String? password}) {
    _client = webdav.newClient(
      url,
      user: username ?? '',
      password: password ?? '',
      debug: false,
    );
    // Extract base path from URL for homePath().
    final uri = Uri.parse(url);
    _basePath = uri.path.isEmpty ? '/' : uri.path;
    if (!_basePath.endsWith('/')) {
      _basePath = '$_basePath/';
    }
  }

  @override
  Future<String> homePath() async {
    _requireConnected();
    return _basePath;
  }

  @override
  void disconnect() {
    _client = null;
  }

  // ---------------------------------------------------------------------------
  // Directory listing
  // ---------------------------------------------------------------------------

  @override
  Future<List<RemoteFileInfo>> listDirectory(String path) async {
    _requireConnected();
    final normalizedPath = _normalizePath(path);

    final files = await _client!.readDir(normalizedPath);

    final entries = <RemoteFileInfo>[];
    for (final file in files) {
      final name = file.name ?? '';
      if (name.isEmpty || name == '.' || name == '..') continue;
      entries.add(_fileToInfo(file, normalizedPath));
    }

    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) {
        return a.isDirectory ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
  }

  // ---------------------------------------------------------------------------
  // File read / write
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List> readFile(String remotePath) async {
    _requireConnected();
    final normalizedPath = _normalizePath(remotePath);
    final bytes = await _client!.read(normalizedPath);
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> writeFile(String remotePath, Uint8List data) async {
    _requireConnected();
    final normalizedPath = _normalizePath(remotePath);
    await _client!.write(normalizedPath, data);
  }

  // ---------------------------------------------------------------------------
  // Transfer: download
  // ---------------------------------------------------------------------------

  @override
  Future<void> downloadFile(
    String remotePath,
    String localPath, {
    TransferProgress? onProgress,
  }) async {
    _requireConnected();
    final normalizedPath = _normalizePath(remotePath);

    // Read the entire file into memory, then write to disk.
    // The webdav_client package does not support streaming progress,
    // so we report progress at 0% and 100%.
    onProgress?.call(0, 0);

    final bytes = await _client!.read(normalizedPath);

    final localFile = File(localPath);
    await localFile.parent.create(recursive: true);
    await localFile.writeAsBytes(bytes);

    onProgress?.call(bytes.length, bytes.length);
  }

  // ---------------------------------------------------------------------------
  // Transfer: upload
  // ---------------------------------------------------------------------------

  @override
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    TransferProgress? onProgress,
  }) async {
    _requireConnected();
    final normalizedPath = _normalizePath(remotePath);

    final localFile = File(localPath);
    final bytes = await localFile.readAsBytes();
    final totalBytes = bytes.length;

    onProgress?.call(0, totalBytes);

    await _client!.write(normalizedPath, bytes);

    onProgress?.call(totalBytes, totalBytes);
  }

  // ---------------------------------------------------------------------------
  // Directory / file management
  // ---------------------------------------------------------------------------

  @override
  Future<void> mkdir(String path) async {
    _requireConnected();
    await _client!.mkdir(_normalizePath(path));
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    _requireConnected();
    await _client!.rename(
      _normalizePath(oldPath),
      _normalizePath(newPath),
      true, // overwrite
    );
  }

  @override
  Future<void> remove(String path) async {
    _requireConnected();
    await _client!.remove(_normalizePath(path));
  }

  /// WebDAV DELETE on a directory is recursive by default.
  @override
  Future<void> removeRecursive(String path) async {
    _requireConnected();
    await _client!.remove(_normalizePath(path));
  }

  // ---------------------------------------------------------------------------
  // Permissions & stat
  // ---------------------------------------------------------------------------

  /// No-op: WebDAV does not support Unix file permissions.
  @override
  Future<void> chmod(String path, int permissions) async {
    // WebDAV has no concept of Unix permission bits.
  }

  @override
  Future<RemoteFileInfo> stat(String remotePath) async {
    _requireConnected();
    final normalizedPath = _normalizePath(remotePath);

    // readDir on the parent to find this specific entry.
    final parentPath = _parentPath(normalizedPath);
    final fileName = _fileName(normalizedPath);

    final files = await _client!.readDir(parentPath);
    for (final file in files) {
      if (file.name == fileName) {
        return _fileToInfo(file, parentPath);
      }
    }

    throw FileSystemException('File not found', remotePath);
  }

  /// WebDAV COPY with Depth: infinity copies a single file.
  @override
  Future<void> copyFile(String sourcePath, String destPath) async {
    _requireConnected();
    await _client!.copy(
      _normalizePath(sourcePath),
      _normalizePath(destPath),
      true, // overwrite
    );
  }

  /// WebDAV COPY with Depth: infinity is recursive by default for directories.
  @override
  Future<void> copyRecursive(String sourcePath, String destPath) async {
    _requireConnected();
    await _client!.copy(
      _normalizePath(sourcePath),
      _normalizePath(destPath),
      true, // overwrite
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _requireConnected() {
    if (_client == null) {
      throw StateError(
        'WebDavService is not connected. Call connect() first.',
      );
    }
  }

  /// Ensures the path has a leading `/`.
  String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    if (!path.startsWith('/')) return '/$path';
    return path;
  }

  /// Returns the parent directory of [path].
  String _parentPath(String path) {
    final normalized = _normalizePath(path);
    final trimmed =
        normalized.endsWith('/') && normalized.length > 1
            ? normalized.substring(0, normalized.length - 1)
            : normalized;
    final lastSlash = trimmed.lastIndexOf('/');
    if (lastSlash <= 0) return '/';
    return trimmed.substring(0, lastSlash + 1);
  }

  /// Returns the file name portion of [path].
  String _fileName(String path) {
    final normalized = _normalizePath(path);
    final trimmed =
        normalized.endsWith('/') && normalized.length > 1
            ? normalized.substring(0, normalized.length - 1)
            : normalized;
    final lastSlash = trimmed.lastIndexOf('/');
    return trimmed.substring(lastSlash + 1);
  }

  /// Joins a parent directory path with a child name.
  String _joinPath(String parent, String child) {
    final p = parent.endsWith('/') ? parent : '$parent/';
    return '$p$child';
  }

  /// Converts a webdav [File] to [RemoteFileInfo].
  RemoteFileInfo _fileToInfo(webdav.File file, String parentPath) {
    final name = file.name ?? '';
    final filePath =
        file.path ??
        (name.isNotEmpty ? _joinPath(parentPath, name) : parentPath);
    return RemoteFileInfo(
      name: name,
      path: filePath,
      isDirectory: file.isDir ?? false,
      size: file.size ?? 0,
      modified: file.mTime,
      // WebDAV does not expose Unix permissions.
      permissions: null,
      owner: null,
      group: null,
    );
  }
}
