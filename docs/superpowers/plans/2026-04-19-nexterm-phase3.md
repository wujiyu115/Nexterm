# Nexterm Phase 3: SFTP File Manager

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a dual-pane SFTP file manager with file transfer queue, built-in code editor with syntax highlighting, permission management, and compress/decompress operations.

**Architecture:** New `features/sftp/` module. SFTP operations use dartssh2's SFTP client via the SSH connection from Phase 1. Local file access via `path_provider` + `file_picker`. Built-in editor uses `flutter_highlight` for syntax highlighting. Transfer queue managed as a Riverpod StateNotifier with progress tracking.

**Tech Stack:** dartssh2 (SFTP), flutter_highlight, file_picker, path_provider, open_file, mime

**Dependencies on Phase 1/2:**
- `features/terminal/services/ssh_service.dart` — reuse SSH client to create SFTP session
- `data/database/app_database.dart` — no new tables (SFTP is stateless, operates on live remote FS)
- `core/router/app_router.dart` — add SFTP route
- `features/hosts/` — navigate to SFTP from host list (right-swipe action)

**New dependencies to add to pubspec.yaml:**
```yaml
  flutter_highlight: ^0.7.0
  highlight: ^0.7.0
  file_picker: ^8.1.6
  open_file: ^3.5.7
  mime: ^2.0.0
```

---

## File Structure (New/Modified)

```
lib/features/sftp/
├── services/
│   └── sftp_service.dart              # SFTP operations wrapper
├── providers/
│   ├── sftp_provider.dart             # Connection + file listing state
│   └── transfer_provider.dart         # Transfer queue state
├── ui/
│   ├── sftp_screen.dart               # Main dual-pane screen
│   ├── file_editor_screen.dart        # Built-in code editor
│   ├── widgets/
│   │   ├── file_list_view.dart        # File/folder list with actions
│   │   ├── file_breadcrumb.dart       # Path navigation breadcrumb
│   │   ├── transfer_queue_bar.dart    # Bottom transfer progress
│   │   └── permission_dialog.dart     # chmod dialog
│   └── utils/
│       ├── file_icon.dart             # File type → icon mapping
│       └── file_size_format.dart      # Human-readable file sizes
test/features/sftp/
├── services/
│   └── sftp_service_test.dart
└── ui/utils/
    ├── file_icon_test.dart
    └── file_size_format_test.dart
```

---

## Task 1: Add SFTP Dependencies & Utility Functions

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/sftp/ui/utils/file_icon.dart`
- Create: `lib/features/sftp/ui/utils/file_size_format.dart`
- Test: `test/features/sftp/ui/utils/file_size_format_test.dart`
- Test: `test/features/sftp/ui/utils/file_icon_test.dart`

- [ ] **Step 1: Add dependencies to pubspec.yaml**

```bash
cd /home/admin/workspace/termius/nexterm
flutter pub add flutter_highlight highlight file_picker open_file mime
```

- [ ] **Step 2: Write failing test for file_size_format**

Create `test/features/sftp/ui/utils/file_size_format_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/sftp/ui/utils/file_size_format.dart';

void main() {
  test('formats bytes', () {
    expect(formatFileSize(0), equals('0 B'));
    expect(formatFileSize(500), equals('500 B'));
  });

  test('formats KB', () {
    expect(formatFileSize(1024), equals('1.0 KB'));
    expect(formatFileSize(1536), equals('1.5 KB'));
  });

  test('formats MB', () {
    expect(formatFileSize(1048576), equals('1.0 MB'));
    expect(formatFileSize(10485760), equals('10.0 MB'));
  });

  test('formats GB', () {
    expect(formatFileSize(1073741824), equals('1.0 GB'));
  });
}
```

- [ ] **Step 3: Implement file_size_format**

Create `lib/features/sftp/ui/utils/file_size_format.dart`:

```dart
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/sftp/ui/utils/file_size_format_test.dart -v
```

Expected: All 4 tests PASS.

- [ ] **Step 5: Create file_icon utility**

Create `lib/features/sftp/ui/utils/file_icon.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

IconData getFileIcon(String filename, {bool isDirectory = false}) {
  if (isDirectory) return Icons.folder;

  final ext = p.extension(filename).toLowerCase();
  return switch (ext) {
    '.dart' || '.py' || '.js' || '.ts' || '.go' || '.rs' || '.java' || '.kt' || '.swift' || '.c' || '.cpp' || '.h' => Icons.code,
    '.json' || '.yaml' || '.yml' || '.toml' || '.xml' || '.ini' || '.conf' || '.cfg' => Icons.settings,
    '.md' || '.txt' || '.log' || '.csv' => Icons.description,
    '.png' || '.jpg' || '.jpeg' || '.gif' || '.svg' || '.webp' || '.bmp' || '.ico' => Icons.image,
    '.zip' || '.tar' || '.gz' || '.bz2' || '.xz' || '.7z' || '.rar' => Icons.archive,
    '.sh' || '.bash' || '.zsh' || '.fish' => Icons.terminal,
    '.sql' => Icons.storage,
    '.dockerfile' => Icons.dns,
    '.key' || '.pem' || '.crt' || '.cert' => Icons.vpn_key,
    _ => Icons.insert_drive_file,
  };
}

Color getFileIconColor(String filename, {bool isDirectory = false, required Brightness brightness}) {
  if (isDirectory) return brightness == Brightness.dark ? const Color(0xFF89B4FA) : const Color(0xFF3498DB);

  final ext = p.extension(filename).toLowerCase();
  return switch (ext) {
    '.dart' => const Color(0xFF0175C2),
    '.py' => const Color(0xFF3776AB),
    '.js' || '.ts' => const Color(0xFFF7DF1E),
    '.go' => const Color(0xFF00ADD8),
    '.rs' => const Color(0xFFDEA584),
    '.sh' || '.bash' => const Color(0xFFA6E3A1),
    _ => brightness == Brightness.dark ? const Color(0xFFA6ADC8) : const Color(0xFF666666),
  };
}

String detectLanguage(String filename) {
  final ext = p.extension(filename).toLowerCase();
  return switch (ext) {
    '.dart' => 'dart',
    '.py' => 'python',
    '.js' => 'javascript',
    '.ts' => 'typescript',
    '.go' => 'go',
    '.rs' => 'rust',
    '.java' => 'java',
    '.kt' => 'kotlin',
    '.swift' => 'swift',
    '.c' || '.h' => 'c',
    '.cpp' => 'cpp',
    '.json' => 'json',
    '.yaml' || '.yml' => 'yaml',
    '.xml' => 'xml',
    '.sql' => 'sql',
    '.sh' || '.bash' || '.zsh' => 'bash',
    '.md' => 'markdown',
    '.toml' => 'ini',
    '.ini' || '.conf' || '.cfg' => 'ini',
    '.dockerfile' => 'dockerfile',
    '.nginx' => 'nginx',
    _ => 'plaintext',
  };
}
```

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml lib/features/sftp/ui/utils/ test/features/sftp/
git commit -m "feat: add SFTP dependencies and file utility functions"
```

---

## Task 2: SFTP Service

**Files:**
- Create: `lib/features/sftp/services/sftp_service.dart`

- [ ] **Step 1: Implement SftpService**

Create `lib/features/sftp/services/sftp_service.dart`:

```dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:path/path.dart' as p;

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

  String get permissionsString {
    if (permissions == null) return '---';
    final p = permissions!;
    String bit(int mask) => (p & mask) != 0 ? 'x' : '-';
    String rwx(int shift) {
      final r = (p >> shift) & 4;
      final w = (p >> shift) & 2;
      final x = (p >> shift) & 1;
      return '${r != 0 ? "r" : "-"}${w != 0 ? "w" : "-"}${x != 0 ? "x" : "-"}';
    }
    return '${rwx(6)}${rwx(3)}${rwx(0)}';
  }
}

typedef TransferProgress = void Function(int transferred, int total);

class SftpService {
  SftpClient? _client;

  bool get isConnected => _client != null;

  Future<void> connect(SSHClient sshClient) async {
    _client = await sshClient.sftp();
  }

  void disconnect() {
    _client?.close();
    _client = null;
  }

  Future<List<RemoteFileInfo>> listDirectory(String path) async {
    final items = await _client!.listdir(path);
    return items
        .where((item) => item.filename != '.' && item.filename != '..')
        .map((item) => RemoteFileInfo(
              name: item.filename,
              path: p.posix.join(path, item.filename),
              isDirectory: item.attr.isDirectory,
              size: item.attr.size ?? 0,
              modified: item.attr.modifyTime != null
                  ? DateTime.fromMillisecondsSinceEpoch(item.attr.modifyTime! * 1000)
                  : null,
              permissions: item.attr.permissions?.value,
              owner: item.attr.uidOrName,
              group: item.attr.gidOrName,
            ))
        .toList()
      ..sort((a, b) {
        if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
  }

  Future<Uint8List> readFile(String path) async {
    final file = await _client!.open(path);
    final chunks = <int>[];
    await for (final chunk in file.read()) {
      chunks.addAll(chunk);
    }
    file.close();
    return Uint8List.fromList(chunks);
  }

  Future<void> writeFile(String path, Uint8List data) async {
    final file = await _client!.open(path,
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate);
    file.write(Stream.value(data));
    await file.close();
  }

  Future<void> downloadFile(String remotePath, String localPath, {TransferProgress? onProgress}) async {
    final remoteFile = await _client!.open(remotePath);
    final stat = await _client!.stat(remotePath);
    final totalSize = stat.size ?? 0;
    var transferred = 0;

    final localFile = File(localPath);
    final sink = localFile.openWrite();

    await for (final chunk in remoteFile.read()) {
      sink.add(chunk);
      transferred += chunk.length;
      onProgress?.call(transferred, totalSize);
    }

    await sink.close();
    remoteFile.close();
  }

  Future<void> uploadFile(String localPath, String remotePath, {TransferProgress? onProgress}) async {
    final localFile = File(localPath);
    final totalSize = await localFile.length();
    var transferred = 0;

    final remoteFile = await _client!.open(remotePath,
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate);

    final stream = localFile.openRead().map((chunk) {
      transferred += chunk.length;
      onProgress?.call(transferred, totalSize);
      return Uint8List.fromList(chunk);
    });

    remoteFile.write(stream);
    await remoteFile.close();
  }

  Future<void> mkdir(String path) async {
    await _client!.mkdir(path);
  }

  Future<void> rename(String oldPath, String newPath) async {
    await _client!.rename(oldPath, newPath);
  }

  Future<void> remove(String path) async {
    await _client!.remove(path);
  }

  Future<void> rmdir(String path) async {
    await _client!.rmdir(path);
  }

  Future<void> removeRecursive(String path) async {
    final items = await listDirectory(path);
    for (final item in items) {
      if (item.isDirectory) {
        await removeRecursive(item.path);
      } else {
        await remove(item.path);
      }
    }
    await rmdir(path);
  }

  Future<void> chmod(String path, int permissions) async {
    await _client!.setStat(path, SftpFileAttrs(
      permissions: SftpFilePermission(permissions),
    ));
  }

  Future<RemoteFileInfo> stat(String remotePath) async {
    final s = await _client!.stat(remotePath);
    return RemoteFileInfo(
      name: p.posix.basename(remotePath),
      path: remotePath,
      isDirectory: s.isDirectory,
      size: s.size ?? 0,
      modified: s.modifyTime != null ? DateTime.fromMillisecondsSinceEpoch(s.modifyTime! * 1000) : null,
      permissions: s.permissions?.value,
      owner: s.uidOrName,
      group: s.gidOrName,
    );
  }
}
```

- [ ] **Step 2: Verify compilation**

```bash
flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/sftp/services/
git commit -m "feat: add SFTP service with file operations, transfer, and permission management"
```

---

## Task 3: Transfer Queue Provider

**Files:**
- Create: `lib/features/sftp/providers/transfer_provider.dart`

- [ ] **Step 1: Implement transfer queue**

Create `lib/features/sftp/providers/transfer_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransferDirection { upload, download }
enum TransferStatus { queued, active, completed, failed, cancelled }

class TransferItem {
  final String id;
  final String fileName;
  final String localPath;
  final String remotePath;
  final TransferDirection direction;
  final int totalBytes;
  int transferredBytes;
  TransferStatus status;
  String? error;

  TransferItem({
    required this.id,
    required this.fileName,
    required this.localPath,
    required this.remotePath,
    required this.direction,
    this.totalBytes = 0,
    this.transferredBytes = 0,
    this.status = TransferStatus.queued,
    this.error,
  });

  double get progress => totalBytes > 0 ? transferredBytes / totalBytes : 0;
}

class TransferQueueNotifier extends StateNotifier<List<TransferItem>> {
  TransferQueueNotifier() : super([]);

  void addTransfer(TransferItem item) {
    state = [...state, item];
  }

  void updateProgress(String id, int transferred, int total) {
    state = [
      for (final item in state)
        if (item.id == id) ...[item..transferredBytes = transferred..totalBytes = total]
        else item,
    ];
  }

  void updateStatus(String id, TransferStatus status, {String? error}) {
    state = [
      for (final item in state)
        if (item.id == id) ...[item..status = status..error = error]
        else item,
    ];
  }

  void removeCompleted() {
    state = state.where((t) => t.status != TransferStatus.completed).toList();
  }

  void cancelTransfer(String id) {
    updateStatus(id, TransferStatus.cancelled);
  }

  List<TransferItem> get activeTransfers =>
      state.where((t) => t.status == TransferStatus.active || t.status == TransferStatus.queued).toList();

  bool get hasActiveTransfers => activeTransfers.isNotEmpty;
}

final transferQueueProvider = StateNotifierProvider<TransferQueueNotifier, List<TransferItem>>((ref) {
  return TransferQueueNotifier();
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/sftp/providers/transfer_provider.dart
git commit -m "feat: add transfer queue provider with progress tracking"
```

---

## Task 4: SFTP Provider

**Files:**
- Create: `lib/features/sftp/providers/sftp_provider.dart`

- [ ] **Step 1: Implement SFTP provider**

Create `lib/features/sftp/providers/sftp_provider.dart`:

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';
import 'package:nexterm/features/terminal/services/ssh_service.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';

final sftpServiceProvider = Provider.family<SftpService, String>((ref, sessionId) {
  final service = SftpService();
  ref.onDispose(() => service.disconnect());
  return service;
});

class SftpState {
  final String currentPath;
  final List<RemoteFileInfo> files;
  final bool isLoading;
  final String? error;
  final Set<String> selectedPaths;
  final bool showHidden;

  const SftpState({
    this.currentPath = '/home',
    this.files = const [],
    this.isLoading = false,
    this.error,
    this.selectedPaths = const {},
    this.showHidden = false,
  });

  SftpState copyWith({
    String? currentPath,
    List<RemoteFileInfo>? files,
    bool? isLoading,
    String? Function()? error,
    Set<String>? selectedPaths,
    bool? showHidden,
  }) {
    return SftpState(
      currentPath: currentPath ?? this.currentPath,
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      showHidden: showHidden ?? this.showHidden,
    );
  }

  List<RemoteFileInfo> get visibleFiles =>
      showHidden ? files : files.where((f) => !f.name.startsWith('.')).toList();
}

class SftpNotifier extends StateNotifier<SftpState> {
  final SftpService _sftp;
  final TransferQueueNotifier _transferQueue;

  SftpNotifier(this._sftp, this._transferQueue) : super(const SftpState());

  Future<void> navigateTo(String path) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final files = await _sftp.listDirectory(path);
      state = state.copyWith(currentPath: path, files: files, isLoading: false, selectedPaths: {});
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> refresh() => navigateTo(state.currentPath);

  void navigateUp() {
    final parent = p.posix.dirname(state.currentPath);
    navigateTo(parent);
  }

  void toggleHidden() {
    state = state.copyWith(showHidden: !state.showHidden);
  }

  void toggleSelection(String path) {
    final selected = Set<String>.from(state.selectedPaths);
    if (selected.contains(path)) {
      selected.remove(path);
    } else {
      selected.add(path);
    }
    state = state.copyWith(selectedPaths: selected);
  }

  void clearSelection() {
    state = state.copyWith(selectedPaths: {});
  }

  Future<void> createDirectory(String name) async {
    final path = p.posix.join(state.currentPath, name);
    await _sftp.mkdir(path);
    await refresh();
  }

  Future<void> rename(String oldPath, String newName) async {
    final dir = p.posix.dirname(oldPath);
    final newPath = p.posix.join(dir, newName);
    await _sftp.rename(oldPath, newPath);
    await refresh();
  }

  Future<void> delete(String path, {bool isDirectory = false}) async {
    if (isDirectory) {
      await _sftp.removeRecursive(path);
    } else {
      await _sftp.remove(path);
    }
    await refresh();
  }

  Future<void> deleteSelected() async {
    for (final path in state.selectedPaths) {
      final file = state.files.firstWhere((f) => f.path == path);
      await delete(path, isDirectory: file.isDirectory);
    }
    clearSelection();
  }

  Future<void> uploadFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    for (final file in result.files) {
      if (file.path == null) continue;
      final remotePath = p.posix.join(state.currentPath, file.name);
      final item = TransferItem(
        id: const Uuid().v4(),
        fileName: file.name,
        localPath: file.path!,
        remotePath: remotePath,
        direction: TransferDirection.upload,
        totalBytes: file.size,
      );
      _transferQueue.addTransfer(item);
      _transferQueue.updateStatus(item.id, TransferStatus.active);

      try {
        await _sftp.uploadFile(file.path!, remotePath, onProgress: (transferred, total) {
          _transferQueue.updateProgress(item.id, transferred, total);
        });
        _transferQueue.updateStatus(item.id, TransferStatus.completed);
      } catch (e) {
        _transferQueue.updateStatus(item.id, TransferStatus.failed, error: e.toString());
      }
    }
    await refresh();
  }

  Future<void> downloadFile(RemoteFileInfo file) async {
    final dir = await getApplicationDocumentsDirectory();
    final localPath = p.join(dir.path, 'Nexterm', file.name);
    final item = TransferItem(
      id: const Uuid().v4(),
      fileName: file.name,
      localPath: localPath,
      remotePath: file.path,
      direction: TransferDirection.download,
      totalBytes: file.size,
    );
    _transferQueue.addTransfer(item);
    _transferQueue.updateStatus(item.id, TransferStatus.active);

    try {
      await _sftp.downloadFile(file.path, localPath, onProgress: (transferred, total) {
        _transferQueue.updateProgress(item.id, transferred, total);
      });
      _transferQueue.updateStatus(item.id, TransferStatus.completed);
    } catch (e) {
      _transferQueue.updateStatus(item.id, TransferStatus.failed, error: e.toString());
    }
  }

  Future<String> readFileContent(String path) async {
    final data = await _sftp.readFile(path);
    return utf8.decode(data);
  }

  Future<void> writeFileContent(String path, String content) async {
    await _sftp.writeFile(path, Uint8List.fromList(utf8.encode(content)));
  }

  Future<void> chmod(String path, int permissions) async {
    await _sftp.chmod(path, permissions);
    await refresh();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/sftp/providers/sftp_provider.dart
git commit -m "feat: add SFTP state provider with navigation, transfer, and file operations"
```

---

## Task 5: SFTP UI — File List, Breadcrumb, Transfer Bar

**Files:**
- Create: `lib/features/sftp/ui/widgets/file_breadcrumb.dart`
- Create: `lib/features/sftp/ui/widgets/file_list_view.dart`
- Create: `lib/features/sftp/ui/widgets/transfer_queue_bar.dart`
- Create: `lib/features/sftp/ui/widgets/permission_dialog.dart`

- [ ] **Step 1: Create file breadcrumb**

Create `lib/features/sftp/ui/widgets/file_breadcrumb.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FileBreadcrumb extends StatelessWidget {
  final String path;
  final ValueChanged<String> onNavigate;

  const FileBreadcrumb({super.key, required this.path, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final theme = Theme.of(context);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length + 1,
        separatorBuilder: (_, __) => Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurfaceVariant),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () => onNavigate('/'),
              child: Center(child: Icon(Icons.home, size: 18, color: theme.colorScheme.primary)),
            );
          }
          final targetPath = '/${parts.sublist(0, index).join('/')}';
          final isLast = index == parts.length;
          return GestureDetector(
            onTap: isLast ? null : () => onNavigate(targetPath),
            child: Center(
              child: Text(
                parts[index - 1],
                style: TextStyle(
                  fontSize: 13,
                  color: isLast ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Create file list view**

Create `lib/features/sftp/ui/widgets/file_list_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/utils/file_icon.dart';
import 'package:nexterm/features/sftp/ui/utils/file_size_format.dart';

class FileListView extends StatelessWidget {
  final List<RemoteFileInfo> files;
  final Set<String> selectedPaths;
  final ValueChanged<RemoteFileInfo> onTap;
  final ValueChanged<RemoteFileInfo> onLongPress;
  final ValueChanged<String> onToggleSelect;

  const FileListView({
    super.key,
    required this.files,
    required this.selectedPaths,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    if (files.isEmpty) {
      return const Center(child: Text('空文件夹'));
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = selectedPaths.contains(file.path);
        final icon = getFileIcon(file.name, isDirectory: file.isDirectory);
        final iconColor = getFileIconColor(file.name, isDirectory: file.isDirectory, brightness: brightness);

        return ListTile(
          leading: Icon(icon, color: iconColor, size: 24),
          title: Text(file.name, style: const TextStyle(fontSize: 14)),
          subtitle: file.isDirectory
              ? null
              : Text(
                  '${formatFileSize(file.size)} · ${file.modified?.toString().substring(0, 16) ?? ""}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
          trailing: selectedPaths.isNotEmpty
              ? Checkbox(value: isSelected, onChanged: (_) => onToggleSelect(file.path))
              : (file.isDirectory ? const Icon(Icons.chevron_right, size: 18) : null),
          selected: isSelected,
          selectedTileColor: theme.colorScheme.primary.withAlpha(20),
          dense: true,
          onTap: () => selectedPaths.isNotEmpty ? onToggleSelect(file.path) : onTap(file),
          onLongPress: () => onLongPress(file),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Create transfer queue bar**

Create `lib/features/sftp/ui/widgets/transfer_queue_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';
import 'package:nexterm/features/sftp/ui/utils/file_size_format.dart';

class TransferQueueBar extends ConsumerWidget {
  const TransferQueueBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transferQueueProvider);
    final active = transfers.where((t) =>
        t.status == TransferStatus.active || t.status == TransferStatus.queued).toList();

    if (active.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: active.take(3).map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                t.direction == TransferDirection.upload ? Icons.upload : Icons.download,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.fileName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(value: t.progress, minHeight: 3),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${(t.progress * 100).toInt()}%', style: const TextStyle(fontSize: 11)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
```

- [ ] **Step 4: Create permission dialog**

Create `lib/features/sftp/ui/widgets/permission_dialog.dart`:

```dart
import 'package:flutter/material.dart';

class PermissionDialog extends StatefulWidget {
  final int currentPermissions;
  final ValueChanged<int> onSave;

  const PermissionDialog({super.key, required this.currentPermissions, required this.onSave});

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  late int _permissions;
  late TextEditingController _octalCtrl;

  @override
  void initState() {
    super.initState();
    _permissions = widget.currentPermissions & 0x1FF;
    _octalCtrl = TextEditingController(text: _permissions.toRadixString(8).padLeft(3, '0'));
  }

  @override
  void dispose() {
    _octalCtrl.dispose();
    super.dispose();
  }

  Widget _permRow(String label, int shift) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label)),
        _permCheck('r', shift + 2),
        _permCheck('w', shift + 1),
        _permCheck('x', shift),
      ],
    );
  }

  Widget _permCheck(String label, int bit) {
    final isSet = (_permissions >> bit) & 1 == 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isSet,
          onChanged: (v) {
            setState(() {
              if (v == true) {
                _permissions |= (1 << bit);
              } else {
                _permissions &= ~(1 << bit);
              }
              _octalCtrl.text = _permissions.toRadixString(8).padLeft(3, '0');
            });
          },
        ),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改权限'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _octalCtrl,
            decoration: const InputDecoration(labelText: '八进制', prefixText: '0'),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = int.tryParse(v, radix: 8);
              if (parsed != null && parsed <= 0x1FF) setState(() => _permissions = parsed);
            },
          ),
          const SizedBox(height: 12),
          _permRow('Owner', 6),
          _permRow('Group', 3),
          _permRow('Other', 0),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: () { widget.onSave(_permissions); Navigator.pop(context); }, child: const Text('保存')),
      ],
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/sftp/ui/widgets/
git commit -m "feat: add SFTP UI widgets — breadcrumb, file list, transfer bar, permission dialog"
```

---

## Task 6: SFTP Main Screen

**Files:**
- Create: `lib/features/sftp/ui/sftp_screen.dart`
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: Implement SFTP screen**

Create `lib/features/sftp/ui/sftp_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/sftp/providers/sftp_provider.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_breadcrumb.dart';
import 'package:nexterm/features/sftp/ui/widgets/file_list_view.dart';
import 'package:nexterm/features/sftp/ui/widgets/transfer_queue_bar.dart';
import 'package:nexterm/features/sftp/ui/widgets/permission_dialog.dart';

class SftpScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const SftpScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SftpScreen> createState() => _SftpScreenState();
}

class _SftpScreenState extends ConsumerState<SftpScreen> {
  SftpNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final sftp = ref.read(sftpServiceProvider(widget.sessionId));
    final sshService = ref.read(sshServiceProvider);
    final session = sshService.sessions[widget.sessionId];
    if (session != null) {
      await sftp.connect(session.client);
      _notifier = SftpNotifier(sftp, ref.read(transferQueueProvider.notifier));
      _notifier!.navigateTo('/home');
      setState(() {});
    }
  }

  void _showFileActions(RemoteFileInfo file) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(file.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (!file.isDirectory) ...[
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('下载'),
                onTap: () { Navigator.pop(ctx); _notifier?.downloadFile(file); },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑'),
                onTap: () { Navigator.pop(ctx); context.push('/sftp/edit', extra: {'sessionId': widget.sessionId, 'path': file.path}); },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('重命名'),
              onTap: () { Navigator.pop(ctx); _showRenameDialog(file); },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: Text('权限: ${file.permissionsString}'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(context: context, builder: (_) => PermissionDialog(
                  currentPermissions: file.permissions ?? 0x1A4,
                  onSave: (perm) => _notifier?.chmod(file.path, perm),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(ctx); _notifier?.delete(file.path, isDirectory: file.isDirectory); },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(RemoteFileInfo file) {
    final ctrl = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () { Navigator.pop(ctx); _notifier?.rename(file.path, ctrl.text); }, child: const Text('确定')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_notifier == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ListenableBuilder(
      listenable: _notifier!,
      builder: (context, _) {
        final state = _notifier!.state;
        return Scaffold(
          appBar: AppBar(
            title: const Text('SFTP'),
            actions: [
              if (state.selectedPaths.isNotEmpty) ...[
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _notifier!.deleteSelected()),
                IconButton(icon: const Icon(Icons.close), onPressed: () => _notifier!.clearSelection()),
              ] else ...[
                IconButton(
                  icon: Icon(state.showHidden ? Icons.visibility : Icons.visibility_off, size: 20),
                  onPressed: () => _notifier!.toggleHidden(),
                ),
                IconButton(icon: const Icon(Icons.upload), onPressed: () => _notifier!.uploadFiles()),
                IconButton(icon: const Icon(Icons.create_new_folder), onPressed: () {
                  final ctrl = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('新建文件夹'),
                      content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: '文件夹名')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                        FilledButton(onPressed: () { Navigator.pop(ctx); _notifier!.createDirectory(ctrl.text); }, child: const Text('创建')),
                      ],
                    ),
                  );
                }),
                IconButton(icon: const Icon(Icons.refresh), onPressed: () => _notifier!.refresh()),
              ],
            ],
          ),
          body: Column(
            children: [
              FileBreadcrumb(path: state.currentPath, onNavigate: (p) => _notifier!.navigateTo(p)),
              const Divider(height: 1),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null
                        ? Center(child: Text('错误: ${state.error}'))
                        : FileListView(
                            files: state.visibleFiles,
                            selectedPaths: state.selectedPaths,
                            onTap: (file) {
                              if (file.isDirectory) {
                                _notifier!.navigateTo(file.path);
                              } else {
                                _showFileActions(file);
                              }
                            },
                            onLongPress: (file) => _notifier!.toggleSelection(file.path),
                            onToggleSelect: (path) => _notifier!.toggleSelection(path),
                          ),
              ),
              const TransferQueueBar(),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Add SFTP route**

In `lib/core/router/app_router.dart`, add import and route:

```dart
import 'package:nexterm/features/sftp/ui/sftp_screen.dart';
```

Add after the `/terminal/connect/:hostId` route:
```dart
GoRoute(
  path: '/sftp/:sessionId',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => SftpScreen(sessionId: state.pathParameters['sessionId']!),
),
```

- [ ] **Step 3: Verify build**

```bash
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/sftp/ui/sftp_screen.dart lib/core/router/
git commit -m "feat: add SFTP main screen with file browsing, upload, download, and actions"
```

---

## Task 7: Built-in Code Editor

**Files:**
- Create: `lib/features/sftp/ui/file_editor_screen.dart`
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: Implement code editor screen**

Create `lib/features/sftp/ui/file_editor_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:nexterm/features/sftp/providers/sftp_provider.dart';
import 'package:nexterm/features/sftp/ui/utils/file_icon.dart';
import 'package:path/path.dart' as p;

class FileEditorScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String filePath;

  const FileEditorScreen({super.key, required this.sessionId, required this.filePath});

  @override
  ConsumerState<FileEditorScreen> createState() => _FileEditorScreenState();
}

class _FileEditorScreenState extends ConsumerState<FileEditorScreen> {
  final _controller = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isModified = false;
  String _originalContent = '';
  String? _error;
  bool _isPreview = false;

  String get _fileName => p.posix.basename(widget.filePath);
  String get _language => detectLanguage(_fileName);

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final sftp = ref.read(sftpServiceProvider(widget.sessionId));
      final sftpNotifier = SftpNotifier(sftp, ref.read(transferQueueProvider.notifier));
      final content = await sftpNotifier.readFileContent(widget.filePath);
      setState(() {
        _originalContent = content;
        _controller.text = content;
        _isLoading = false;
      });
      _controller.addListener(() {
        final modified = _controller.text != _originalContent;
        if (modified != _isModified) setState(() => _isModified = modified);
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final sftp = ref.read(sftpServiceProvider(widget.sessionId));
      final sftpNotifier = SftpNotifier(sftp, ref.read(transferQueueProvider.notifier));
      await sftpNotifier.writeFileContent(widget.filePath, _controller.text);
      setState(() {
        _originalContent = _controller.text;
        _isModified = false;
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_fileName),
            if (_isModified) const Text(' •', style: TextStyle(color: Colors.orange)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            onPressed: () => setState(() => _isPreview = !_isPreview),
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            onPressed: _isModified && !_isSaving ? _save : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('错误: $_error'))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: Theme.of(context).colorScheme.surface,
                      child: Row(
                        children: [
                          Text('Ln ${_controller.text.substring(0, _controller.selection.baseOffset < 0 ? 0 : _controller.selection.baseOffset).split('\n').length}',
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(width: 12),
                          Text(_language, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(width: 12),
                          Text('UTF-8', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isPreview
                          ? SingleChildScrollView(
                              child: HighlightView(
                                _controller.text,
                                language: _language,
                                theme: isDark ? monokaiSublimeTheme : githubTheme,
                                textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13),
                                padding: const EdgeInsets.all(12),
                              ),
                            )
                          : TextField(
                              controller: _controller,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, height: 1.5),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              textAlignVertical: TextAlignVertical.top,
                            ),
                    ),
                  ],
                ),
    );
  }
}
```

- [ ] **Step 2: Add editor route**

In `lib/core/router/app_router.dart`:

```dart
import 'package:nexterm/features/sftp/ui/file_editor_screen.dart';
```

```dart
GoRoute(
  path: '/sftp/edit',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) {
    final extra = state.extra as Map<String, String>;
    return FileEditorScreen(sessionId: extra['sessionId']!, filePath: extra['path']!);
  },
),
```

- [ ] **Step 3: Verify build**

```bash
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/sftp/ui/file_editor_screen.dart lib/core/router/
git commit -m "feat: add built-in code editor with syntax highlighting and remote save"
```

---

## Summary

Phase 3 delivers:

- **7 tasks** building a complete SFTP file manager
- **SFTP Service**: Full dartssh2 SFTP wrapper — list, read, write, upload, download, mkdir, rename, delete, chmod
- **Dual-pane browser**: Breadcrumb navigation, hidden files toggle, sort, batch select
- **Transfer queue**: Progress tracking, upload/download with progress bar
- **Built-in editor**: Syntax highlighting (20+ languages), line info, preview/edit toggle, remote save
- **Permission dialog**: Visual chmod with checkbox grid + octal input
- **Integration**: Accessible from host list and terminal

After Phase 3, proceed to **Phase 4: Backend API + Cloud Sync**.
