# SFTP File Manager

This document describes the SFTP implementation in Nexterm, covering the `SftpService` abstraction, file browsing, transfer management, the built-in code editor, and permission management.

---

## Architecture Overview

```
UI Layer (features/sftp/ui/)
  ├── sftp_screen.dart          ← main file browser
  ├── file_editor_screen.dart   ← built-in code editor
  └── widgets/
        ├── file_list_view.dart     ← directory listing
        ├── file_breadcrumb.dart    ← path navigation
        ├── transfer_queue_bar.dart ← upload/download progress
        └── permission_dialog.dart  ← chmod UI

Provider Layer (features/sftp/providers/)
  ├── sftp_provider.dart         ← directory state, navigation
  └── transfer_provider.dart     ← upload/download queue

Service Layer (features/sftp/services/)
  └── sftp_service.dart          ← wraps dartssh2 SftpClient

Utility Layer (features/sftp/ui/utils/)
  ├── file_icon.dart             ← MIME-type → icon mapping
  └── file_size_format.dart      ← human-readable byte sizes
```

---

## SftpService — dartssh2 Wrapper

`SftpService` provides a high-level API over dartssh2's `SftpClient`. It is stateful: a single `SftpClient` instance is held for the lifetime of the SFTP session.

### Connection

```
// Open SFTP subsystem on an existing SSH connection:
await SftpService.connect(sshClient)
  → _client = await sshClient.sftp()

// Close:
SftpService.disconnect()
  → _client?.close()
```

SFTP runs as an SSH subsystem over the same authenticated connection. No separate TCP connection or authentication is required.

---

## File Browsing and Navigation

### Directory Listing

```
SftpService.listDirectory(path) → List<RemoteFileInfo>

1. _client.listdir(path)
     → List<SftpName> (raw SFTP v3 directory entries)
2. Filter out '.' and '..'
3. Convert each SftpName → RemoteFileInfo:
     name        = entry.filename
     path        = parent + '/' + name
     isDirectory = attrs.isDirectory
     size        = attrs.size ?? 0
     modified    = DateTime.fromMillisecondsSinceEpoch(attrs.modifyTime * 1000)
     permissions = attrs.mode.value & 0xFFF   (lower 12 bits: rwxrwxrwx + sticky)
     owner       = attrs.userID?.toString()   (numeric UID from SFTP v3)
     group       = attrs.groupID?.toString()
4. Sort: directories first, then alphabetically by name (case-insensitive)
```

### RemoteFileInfo

```dart
class RemoteFileInfo {
  final String name;
  final String path;
  final bool   isDirectory;
  final int    size;
  final DateTime? modified;
  final int?   permissions;  // Unix mode bits (lower 12)
  final String? owner;       // numeric UID as string
  final String? group;       // numeric GID as string

  // Computed: "rwxr-xr-x" format
  String get permissionsString { ... }
}
```

### Navigation

The `sftp_provider` maintains a navigation stack. Each directory push adds the new path; the breadcrumb widget allows jumping to any ancestor by index.

---

## Transfer Queue with Progress Tracking

### Download

```
SftpService.downloadFile(remotePath, localPath, onProgress?)

1. open(remotePath, mode: read)
2. stat() → get file size for progress denominator
3. Create local File + open write sink
4. remoteFile.read(onProgress: (bytesRead) { ... })
     → yields chunks; onProgress called with (transferred, total)
5. sink.flush() + sink.close()
6. remoteFile.close()
```

### Upload

```
SftpService.uploadFile(localPath, remotePath, onProgress?)

1. File(localPath).length() → totalBytes
2. open(remotePath, mode: write | create | truncate)
3. localFile.openRead()
     → Stream<List<int>> chunks (cast to Uint8List)
4. remoteFile.write(stream, onProgress: (bytesWritten) { ... })
     → onProgress called with (transferred, total)
5. writer.done awaited
6. remoteFile.close()
```

### Transfer Queue

The `transfer_provider` manages a queue of `TransferTask` objects. Each task carries:

- Remote path, local path
- Direction (upload / download)
- Current progress (bytes transferred, total bytes)
- Status (pending / in-progress / completed / failed)

The UI renders the queue in `transfer_queue_bar.dart` as a collapsible bottom sheet showing per-file progress bars.

---

## Built-in Code Editor

`file_editor_screen.dart` provides an in-app editor for text files fetched over SFTP:

```
Open file:
  1. SftpService.readFile(remotePath) → Uint8List
  2. utf8.decode(bytes) → String
  3. Display in flutter_highlight widget with syntax highlighting
       (language detected from file extension via mime package)

Save file:
  1. utf8.encode(editedText) → Uint8List
  2. SftpService.writeFile(remotePath, bytes)
```

Supported syntax highlighting languages include Dart, Python, JavaScript, TypeScript, Shell, YAML, JSON, Markdown, and all languages supported by the `highlight` package.

The editor does not stream large files — the entire file is read into memory. This is intentional for simplicity; very large files (>1 MB) show a warning before loading.

---

## Permission Management (chmod)

```
permission_dialog.dart
  → Presents a 9-checkbox grid: [ owner r | w | x ] [ group r | w | x ] [ other r | w | x ]
  → Integer mode built from toggled bits (e.g. 0o755 = 0x1ED)

SftpService.chmod(path, permissions)
  attrs = SftpFileAttrs(mode: SftpFileMode.value(permissions))
  _client.setStat(path, attrs)
```

The permission display in the file list uses `RemoteFileInfo.permissionsString` which formats the lower 9 bits as `rwxrwxrwx` (e.g. `rwxr-xr-x`).

---

## File Operations Reference

| Method | SFTP operation | Notes |
|--------|---------------|-------|
| `listDirectory(path)` | `listdir` | Sorted, filters `.` and `..` |
| `readFile(path)` | `open` + `readBytes` | Reads entirely into memory |
| `writeFile(path, data)` | `open(write|create|truncate)` + `writeBytes` | Creates or overwrites |
| `downloadFile(remote, local)` | `open` + streamed `read` | Progress callback |
| `uploadFile(local, remote)` | `open(write|create|truncate)` + `write` | Progress callback |
| `mkdir(path)` | `mkdir` | Creates directory |
| `rename(old, new)` | `rename` | Move or rename |
| `remove(path)` | `remove` | Delete file |
| `rmdir(path)` | `rmdir` | Delete empty directory |
| `removeRecursive(path)` | `stat` + `listdir` + recursive | Delete tree |
| `chmod(path, mode)` | `setStat` | Unix permission bits |
| `stat(path)` | `stat` | Returns `RemoteFileInfo` |

---

## Error Handling

All `SftpService` methods throw `StateError` if called before `connect()`. Network or permission errors from dartssh2 propagate as exceptions and are caught in the provider layer, which updates the UI state to show an error banner.

Transfer failures mark the affected `TransferTask` as failed with the error message. Other queued transfers continue unaffected.

---

## Limitations

- **File size**: Reading a file into memory for the editor is unsuitable for files larger than device RAM. Large file streaming editing is not implemented.
- **SFTP version**: dartssh2 implements SFTP protocol version 3. Owner/group names are not available (only numeric UID/GID).
- **Symlinks**: Symbolic links are not explicitly followed or distinguished; they appear as regular files with the target's attributes.
- **Dynamic SOCKS5 forward**: The dynamic port forward (SOCKS5 proxy) in `PortForwardService` binds the socket but closes all incoming connections immediately — full SOCKS5 negotiation is a future enhancement.
