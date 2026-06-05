import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';

import 'remote_file_service.dart';
export 'remote_file_service.dart';

/// Service wrapping dartssh2's [SftpClient] to provide high-level SFTP
/// operations: directory listing, file read/write, upload/download with
/// progress, recursive delete, chmod, and stat.
class SftpService implements RemoteFileService {
  SftpClient? _client;

  @override
  bool get isConnected => _client != null;

  // ---------------------------------------------------------------------------
  // Connection management
  // ---------------------------------------------------------------------------

  /// Opens an SFTP subsystem on the given [sshClient].
  Future<void> connect(SSHClient sshClient) async {
    _client = await sshClient.sftp();
  }

  /// Returns the absolute path of the SFTP home directory.
  @override
  Future<String> homePath() async {
    _requireConnected();
    return await _client!.absolute('.');
  }

  /// Closes the SFTP session.
  @override
  void disconnect() {
    _client?.close();
    _client = null;
  }

  // ---------------------------------------------------------------------------
  // Directory listing
  // ---------------------------------------------------------------------------

  /// Lists the contents of [path].  Entries are sorted with directories first,
  /// then alphabetically by name.  The `.` and `..` entries are omitted.
  @override
  Future<List<RemoteFileInfo>> listDirectory(String path) async {
    _requireConnected();

    final names = await _client!.listdir(path);

    final entries = <RemoteFileInfo>[];
    for (final name in names) {
      if (name.filename == '.' || name.filename == '..') continue;
      entries.add(_nameToInfo(name, path));
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

    final file = await _client!.open(remotePath, mode: SftpFileOpenMode.read);
    try {
      return await file.readBytes();
    } finally {
      await file.close();
    }
  }

  /// Writes [data] to [remotePath], creating or truncating the file.
  @override
  Future<void> writeFile(String remotePath, Uint8List data) async {
    _requireConnected();

    final file = await _client!.open(
      remotePath,
      mode: SftpFileOpenMode.write |
          SftpFileOpenMode.create |
          SftpFileOpenMode.truncate,
    );
    try {
      await file.writeBytes(data);
    } finally {
      await file.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Transfer: download
  // ---------------------------------------------------------------------------

  /// Downloads [remotePath] to [localPath].  [onProgress] receives
  /// (bytesTransferred, totalBytes) updates.
  @override
  Future<void> downloadFile(
    String remotePath,
    String localPath, {
    TransferProgress? onProgress,
  }) async {
    _requireConnected();

    final remoteFile =
        await _client!.open(remotePath, mode: SftpFileOpenMode.read);
    try {
      final attrs = await remoteFile.stat();
      final totalBytes = attrs.size ?? 0;

      final localFile = File(localPath);
      await localFile.parent.create(recursive: true);
      final sink = localFile.openWrite();
      var transferred = 0;

      try {
        await for (final chunk in remoteFile.read(
          onProgress: (bytesRead) {
            transferred = bytesRead;
            onProgress?.call(transferred, totalBytes);
          },
        )) {
          sink.add(chunk);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
    } finally {
      await remoteFile.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Transfer: upload
  // ---------------------------------------------------------------------------

  /// Uploads [localPath] to [remotePath].  [onProgress] receives
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

    final remoteFile = await _client!.open(
      remotePath,
      mode: SftpFileOpenMode.write |
          SftpFileOpenMode.create |
          SftpFileOpenMode.truncate,
    );
    try {
      final stream = localFile.openRead().map((chunk) {
        // openRead yields List<int>; the write API expects Uint8List chunks.
        return chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
      });

      final writer = remoteFile.write(
        stream,
        onProgress: (bytesWritten) {
          onProgress?.call(bytesWritten, totalBytes);
        },
      );
      await writer.done;
    } finally {
      await remoteFile.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Directory / file management
  // ---------------------------------------------------------------------------

  /// Creates the directory at [path].
  @override
  Future<void> mkdir(String path) async {
    _requireConnected();
    await _client!.mkdir(path);
  }

  /// Renames / moves [oldPath] to [newPath].
  @override
  Future<void> rename(String oldPath, String newPath) async {
    _requireConnected();
    await _client!.rename(oldPath, newPath);
  }

  /// Removes the file at [path].
  @override
  Future<void> remove(String path) async {
    _requireConnected();
    await _client!.remove(path);
  }

  /// Removes the (empty) directory at [path].
  Future<void> rmdir(String path) async {
    _requireConnected();
    await _client!.rmdir(path);
  }

  /// Recursively deletes [path] and all its contents.
  @override
  Future<void> removeRecursive(String path) async {
    _requireConnected();

    // Determine whether [path] is a directory.
    final attrs = await _client!.stat(path);
    if (!attrs.isDirectory) {
      await _client!.remove(path);
      return;
    }

    // Delete children first.
    final names = await _client!.listdir(path);
    for (final name in names) {
      if (name.filename == '.' || name.filename == '..') continue;
      final childPath = _joinPath(path, name.filename);
      await removeRecursive(childPath);
    }

    // Now remove the (now-empty) directory itself.
    await _client!.rmdir(path);
  }

  // ---------------------------------------------------------------------------
  // Permissions & stat
  // ---------------------------------------------------------------------------

  /// Sets the Unix permission bits of [path] to [permissions]
  /// (e.g. `0o755` or `0x1ED`).
  @override
  Future<void> chmod(String path, int permissions) async {
    _requireConnected();
    final attrs = SftpFileAttrs(mode: SftpFileMode.value(permissions));
    await _client!.setStat(path, attrs);
  }

  /// Returns a [RemoteFileInfo] describing [remotePath].
  @override
  Future<RemoteFileInfo> stat(String remotePath) async {
    _requireConnected();
    final attrs = await _client!.stat(remotePath);
    final name = remotePath.split('/').where((s) => s.isNotEmpty).last;
    return _attrsToInfo(name, remotePath, attrs);
  }

  /// Copies a remote file from [sourcePath] to [destPath] by reading and
  /// re-writing through the SFTP channel.
  @override
  Future<void> copyFile(String sourcePath, String destPath) async {
    final data = await readFile(sourcePath);
    await writeFile(destPath, data);
  }

  /// Recursively copies a directory from [sourcePath] to [destPath].
  @override
  Future<void> copyRecursive(String sourcePath, String destPath) async {
    _requireConnected();
    final attrs = await _client!.stat(sourcePath);
    if (!attrs.isDirectory) {
      await copyFile(sourcePath, destPath);
      return;
    }
    await mkdir(destPath);
    final children = await _client!.listdir(sourcePath);
    for (final child in children) {
      if (child.filename == '.' || child.filename == '..') continue;
      final childSrc = _joinPath(sourcePath, child.filename);
      final childDst = _joinPath(destPath, child.filename);
      await copyRecursive(childSrc, childDst);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _requireConnected() {
    if (_client == null) {
      throw StateError('SftpService is not connected. Call connect() first.');
    }
  }

  /// Joins a parent directory path with a child name, handling trailing slashes.
  String _joinPath(String parent, String child) {
    final p = parent.endsWith('/') ? parent : '$parent/';
    return '$p$child';
  }

  /// Converts a [SftpName] returned by [SftpClient.listdir] to [RemoteFileInfo].
  RemoteFileInfo _nameToInfo(SftpName name, String parentPath) {
    return _attrsToInfo(
      name.filename,
      _joinPath(parentPath, name.filename),
      name.attr,
    );
  }

  /// Converts raw [SftpFileAttrs] to [RemoteFileInfo].
  RemoteFileInfo _attrsToInfo(
    String name,
    String path,
    SftpFileAttrs attrs,
  ) {
    DateTime? modified;
    if (attrs.modifyTime != null) {
      modified = DateTime.fromMillisecondsSinceEpoch(
        attrs.modifyTime! * 1000,
        isUtc: true,
      );
    }

    return RemoteFileInfo(
      name: name,
      path: path,
      isDirectory: attrs.isDirectory,
      size: attrs.size ?? 0,
      modified: modified,
      // attrs.mode?.value holds the full mode word (type bits + permission bits).
      // We extract only the lower 12 bits (rwxrwxrwx + setuid/setgid/sticky).
      permissions: attrs.mode != null ? (attrs.mode!.value & 0xFFF) : null,
      // dartssh2 exposes numeric UID/GID; no string owner/group from SFTP v3.
      owner: attrs.userID?.toString(),
      group: attrs.groupID?.toString(),
    );
  }

  @override
  String? videoUrl(String remotePath) => null;

  @override
  bool get supportsReadRange => true;

  @override
  Future<Uint8List> readRange(String remotePath, int offset, int length) async {
    _requireConnected();
    final file = await _client!.open(remotePath, mode: SftpFileOpenMode.read);
    try {
      return await file.readBytes(offset: offset, length: length);
    } finally {
      await file.close();
    }
  }
}
