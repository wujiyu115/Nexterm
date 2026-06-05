import 'dart:typed_data';

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

/// Abstract interface for remote file operations.
///
/// Implementations include [SftpService] (SFTP over SSH) and, in the future,
/// WebDAV or other remote file protocols.
abstract class RemoteFileService {
  bool get isConnected;
  Future<String> homePath();
  void disconnect();
  Future<List<RemoteFileInfo>> listDirectory(String path);
  Future<Uint8List> readFile(String remotePath);
  Future<void> writeFile(String remotePath, Uint8List data);
  Future<void> downloadFile(String remotePath, String localPath, {TransferProgress? onProgress});
  Future<void> uploadFile(String localPath, String remotePath, {TransferProgress? onProgress});
  Future<void> mkdir(String path);
  Future<void> rename(String oldPath, String newPath);
  Future<void> remove(String path);
  Future<void> removeRecursive(String path);
  Future<void> chmod(String path, int permissions);
  Future<RemoteFileInfo> stat(String remotePath);
  Future<void> copyFile(String sourcePath, String destPath);
  Future<void> copyRecursive(String sourcePath, String destPath);

  String? videoUrl(String remotePath) => null;
  Future<Uint8List> readRange(String remotePath, int offset, int length) async {
    throw UnimplementedError('readRange not supported');
  }
  bool get supportsReadRange => false;
}
