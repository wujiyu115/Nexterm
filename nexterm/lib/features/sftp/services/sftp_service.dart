import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';

/// Typedef for reporting transfer progress.
typedef TransferProgress = void Function(int transferred, int total);

/// Represents metadata about a remote file or directory.
class RemoteFileInfo {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime? modified;
  final int? permissions;
  final String? owner;
  final String? group;

  const RemoteFileInfo({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    this.modified,
    this.permissions,
    this.owner,
    this.group,
  });

  /// Returns the permissions formatted as a 9-character rwxrwxrwx string.
  String get permissionsString {
    final p = permissions;
    if (p == null) return '---------';

    String bit(int mask, String char) => (p & mask) != 0 ? char : '-';

    return '${bit(0x100, 'r')}${bit(0x080, 'w')}${bit(0x040, 'x')}'
        '${bit(0x020, 'r')}${bit(0x010, 'w')}${bit(0x008, 'x')}'
        '${bit(0x004, 'r')}${bit(0x002, 'w')}${bit(0x001, 'x')}';
  }

  @override
  String toString() =>
      'RemoteFileInfo(name: $name, path: $path, isDirectory: $isDirectory, '
      'size: $size, modified: $modified, permissions: $permissions)';
}

/// Service wrapping dartssh2's [SftpClient] to provide high-level SFTP
/// operations: directory listing, file read/write, upload/download with
/// progress, recursive delete, chmod, and stat.
class SftpService {
  SftpClient? _client;

  bool get isConnected => _client != null;

  // ---------------------------------------------------------------------------
  // Connection management
  // ---------------------------------------------------------------------------

  /// Opens an SFTP subsystem on the given [sshClient].
  Future<void> connect(SSHClient sshClient) async {
    _client = await sshClient.sftp();
  }

  /// Closes the SFTP session.
  void disconnect() {
    _client?.close();
    _client = null;
  }

  // ---------------------------------------------------------------------------
  // Directory listing
  // ---------------------------------------------------------------------------

  /// Lists the contents of [path].  Entries are sorted with directories first,
  /// then alphabetically by name.  The `.` and `..` entries are omitted.
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
  Future<void> mkdir(String path) async {
    _requireConnected();
    await _client!.mkdir(path);
  }

  /// Renames / moves [oldPath] to [newPath].
  Future<void> rename(String oldPath, String newPath) async {
    _requireConnected();
    await _client!.rename(oldPath, newPath);
  }

  /// Removes the file at [path].
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
  Future<void> chmod(String path, int permissions) async {
    _requireConnected();
    final attrs = SftpFileAttrs(mode: SftpFileMode.value(permissions));
    await _client!.setStat(path, attrs);
  }

  /// Returns a [RemoteFileInfo] describing [remotePath].
  Future<RemoteFileInfo> stat(String remotePath) async {
    _requireConnected();
    final attrs = await _client!.stat(remotePath);
    final name = remotePath.split('/').where((s) => s.isNotEmpty).last;
    return _attrsToInfo(name, remotePath, attrs);
  }

  /// Copies a remote file from [sourcePath] to [destPath] by reading and
  /// re-writing through the SFTP channel.
  Future<void> copyFile(String sourcePath, String destPath) async {
    final data = await readFile(sourcePath);
    await writeFile(destPath, data);
  }

  /// Recursively copies a directory from [sourcePath] to [destPath].
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
}
