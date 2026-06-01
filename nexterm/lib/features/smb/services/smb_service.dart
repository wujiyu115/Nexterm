import 'dart:io';
import 'dart:typed_data';

import 'package:smb_connect/smb_connect.dart';

import '../../sftp/services/remote_file_service.dart';
export '../../sftp/services/remote_file_service.dart';

/// Service wrapping [SmbConnect] to provide high-level SMB/CIFS file
/// operations that conform to the [RemoteFileService] interface.
class SmbService implements RemoteFileService {
  SmbConnect? _client;

  @override
  bool get isConnected => _client != null;

  // ---------------------------------------------------------------------------
  // Connection management
  // ---------------------------------------------------------------------------

  /// Connects to an SMB share on [host]/[shareName].
  ///
  /// This is SMB-specific and NOT part of [RemoteFileService].
  Future<void> connect(
    String host,
    String shareName, {
    int port = 445,
    String? username,
    String? password,
    String? domain,
  }) async {
    _client = await SmbConnect.connectAuth(
      host: host,
      username: username ?? '',
      password: password ?? '',
      domain: domain ?? '',
    );
  }

  @override
  Future<String> homePath() async {
    _requireConnected();
    return '/';
  }

  @override
  void disconnect() {
    _client?.close();
    _client = null;
  }

  // ---------------------------------------------------------------------------
  // Directory listing
  // ---------------------------------------------------------------------------

  /// Lists the contents of [path]. Entries are sorted with directories first,
  /// then alphabetically by name. The `.` and `..` entries are omitted by the
  /// underlying [SmbConnect.listFiles] call.
  @override
  Future<List<RemoteFileInfo>> listDirectory(String path) async {
    _requireConnected();

    final folder = await _client!.file(path);
    final files = await _client!.listFiles(folder);

    final entries = <RemoteFileInfo>[];
    for (final file in files) {
      entries.add(_smbFileToInfo(file));
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

  /// Reads [remotePath] entirely into memory and returns the bytes.
  @override
  Future<Uint8List> readFile(String remotePath) async {
    _requireConnected();

    final smbFile = await _client!.file(remotePath);
    final raf = await _client!.open(smbFile, mode: FileMode.read);
    try {
      final fileLength = await raf.length();
      if (fileLength == 0) return Uint8List(0);
      return await raf.read(fileLength);
    } finally {
      await raf.close();
    }
  }

  /// Writes [data] to [remotePath], creating or truncating the file.
  @override
  Future<void> writeFile(String remotePath, Uint8List data) async {
    _requireConnected();

    // Ensure the file exists on the share.
    await _client!.createFile(remotePath);
    final smbFile = await _client!.file(remotePath);
    final sink = await _client!.openWrite(smbFile);
    try {
      sink.add(data);
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Transfer: download
  // ---------------------------------------------------------------------------

  /// Downloads [remotePath] to [localPath]. [onProgress] receives
  /// (bytesTransferred, totalBytes) updates.
  @override
  Future<void> downloadFile(
    String remotePath,
    String localPath, {
    TransferProgress? onProgress,
  }) async {
    _requireConnected();

    final smbFile = await _client!.file(remotePath);
    final totalBytes = smbFile.size;

    final stream = await _client!.openRead(smbFile);
    final localFile = File(localPath);
    await localFile.parent.create(recursive: true);
    final sink = localFile.openWrite();
    var transferred = 0;

    try {
      await for (final chunk in stream) {
        sink.add(chunk);
        transferred += chunk.length;
        onProgress?.call(transferred, totalBytes);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Transfer: upload
  // ---------------------------------------------------------------------------

  /// Uploads [localPath] to [remotePath]. [onProgress] receives
  /// (bytesTransferred, totalBytes) updates.
  @override
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    TransferProgress? onProgress,
  }) async {
    _requireConnected();

    final localFile = File(localPath);
    final totalBytes = await localFile.length();

    // Ensure the remote file exists.
    await _client!.createFile(remotePath);
    final smbFile = await _client!.file(remotePath);
    final sink = await _client!.openWrite(smbFile);
    var transferred = 0;

    try {
      await for (final chunk in localFile.openRead()) {
        final bytes = chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
        sink.add(bytes);
        transferred += bytes.length;
        onProgress?.call(transferred, totalBytes);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Directory / file management
  // ---------------------------------------------------------------------------

  /// Creates the directory at [path].
  @override
  Future<void> mkdir(String path) async {
    _requireConnected();
    await _client!.createFolder(path);
  }

  /// Renames / moves [oldPath] to [newPath].
  @override
  Future<void> rename(String oldPath, String newPath) async {
    _requireConnected();
    final srcFile = await _client!.file(oldPath);
    await _client!.rename(srcFile, newPath);
  }

  /// Removes the file or empty directory at [path].
  @override
  Future<void> remove(String path) async {
    _requireConnected();
    final smbFile = await _client!.file(path);
    await _client!.delete(smbFile);
  }

  /// Recursively deletes [path] and all its contents.
  ///
  /// The underlying [SmbConnect.delete] for directories already recurses, but
  /// this implementation matches the explicit contract by walking children
  /// first.
  @override
  Future<void> removeRecursive(String path) async {
    _requireConnected();

    final smbFile = await _client!.file(path);
    if (!smbFile.isDirectory()) {
      await _client!.delete(smbFile);
      return;
    }

    // Delete children first.
    final children = await _client!.listFiles(smbFile);
    for (final child in children) {
      await removeRecursive(child.path);
    }

    // Now remove the (now-empty) directory itself.
    await _client!.delete(smbFile);
  }

  // ---------------------------------------------------------------------------
  // Permissions & stat
  // ---------------------------------------------------------------------------

  /// No-op: SMB does not support Unix permissions.
  @override
  Future<void> chmod(String path, int permissions) async {
    // SMB/CIFS has no concept of Unix permission bits; silently ignore.
  }

  /// Returns a [RemoteFileInfo] describing [remotePath].
  @override
  Future<RemoteFileInfo> stat(String remotePath) async {
    _requireConnected();
    final smbFile = await _client!.file(remotePath);
    return _smbFileToInfo(smbFile);
  }

  /// Copies a remote file from [sourcePath] to [destPath] by reading and
  /// re-writing through the SMB channel.
  @override
  Future<void> copyFile(String sourcePath, String destPath) async {
    final data = await readFile(sourcePath);
    await writeFile(destPath, data);
  }

  /// Recursively copies a directory from [sourcePath] to [destPath].
  @override
  Future<void> copyRecursive(String sourcePath, String destPath) async {
    _requireConnected();

    final srcFile = await _client!.file(sourcePath);
    if (!srcFile.isDirectory()) {
      await copyFile(sourcePath, destPath);
      return;
    }

    await mkdir(destPath);
    final children = await _client!.listFiles(srcFile);
    for (final child in children) {
      final childDst = _joinPath(destPath, child.name);
      await copyRecursive(child.path, childDst);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _requireConnected() {
    if (_client == null) {
      throw StateError('SmbService is not connected. Call connect() first.');
    }
  }

  /// Joins a parent directory path with a child name, handling trailing
  /// slashes.
  String _joinPath(String parent, String child) {
    final p = parent.endsWith('/') ? parent : '$parent/';
    return '$p$child';
  }

  /// Converts an [SmbFile] to a [RemoteFileInfo].
  RemoteFileInfo _smbFileToInfo(SmbFile file) {
    DateTime? modified;
    if (file.lastModified > 0) {
      modified = DateTime.fromMillisecondsSinceEpoch(
        file.lastModified,
        isUtc: true,
      );
    }

    return RemoteFileInfo(
      name: file.name,
      path: file.path,
      isDirectory: file.isDirectory(),
      size: file.size,
      modified: modified,
      // SMB has no Unix permission model.
      permissions: null,
      owner: null,
      group: null,
    );
  }
}
