import 'dart:convert';

import 'package:dartssh2/dartssh2.dart' show SSHClient;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/services/ssh_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// SftpService provider
// ---------------------------------------------------------------------------

/// Provider.family that creates (and connects) an [SftpService] for a given
/// SSH session identified by [sessionId].
final sftpServiceProvider = FutureProvider.family<SftpService, String>((
  ref,
  sessionId,
) async {
  final sshService = ref.read(sshServiceProvider);

  // Retrieve the underlying SSHClient from the active session map.
  // SSHService exposes the session via its internal map; we use the public
  // SSHActiveSession by reading through the provider.
  final client = _getClientForSession(sshService, sessionId);
  if (client == null) {
    throw StateError('No active SSH session for id: $sessionId');
  }

  final sftpService = SftpService();
  await sftpService.connect(client);

  ref.onDispose(() => sftpService.disconnect());

  return sftpService;
});

/// Extracts the [SSHClient] from [SSHService] for a given session.
/// Uses a package-level helper to avoid coupling to private internals more than
/// necessary — the SSHService already exposes [isActive] and session listing,
/// so we use reflection-free access through the active session.
SSHClient? _getClientForSession(SSHService sshService, String sessionId) {
  if (!sshService.isActive(sessionId)) return null;

  // SSHService stores sessions in a private map.  We access via the public
  // getClient accessor we assume exists, or fall back to the internal cast.
  // Since SSHService is in our own codebase, we expose a helper method on it.
  return sshService.getClient(sessionId);
}

// ---------------------------------------------------------------------------
// SftpState
// ---------------------------------------------------------------------------

enum SortField { name, size, date, type }

class SftpState {
  final String currentPath;
  final List<RemoteFileInfo> files;
  final bool isLoading;
  final String? error;
  final Set<String> selectedPaths;
  final bool showHidden;
  final SortField sortField;
  final bool sortAscending;
  final List<String> copiedPaths;

  const SftpState({
    this.currentPath = '/',
    this.files = const [],
    this.isLoading = false,
    this.error,
    this.selectedPaths = const {},
    this.showHidden = false,
    this.sortField = SortField.name,
    this.sortAscending = true,
    this.copiedPaths = const [],
  });

  SftpState copyWith({
    String? currentPath,
    List<RemoteFileInfo>? files,
    bool? isLoading,
    Object? error = _sentinel,
    Set<String>? selectedPaths,
    bool? showHidden,
    SortField? sortField,
    bool? sortAscending,
    List<String>? copiedPaths,
  }) {
    return SftpState(
      currentPath: currentPath ?? this.currentPath,
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      showHidden: showHidden ?? this.showHidden,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      copiedPaths: copiedPaths ?? this.copiedPaths,
    );
  }

  /// Visible files — hides dot-files when [showHidden] is false, then sorts.
  List<RemoteFileInfo> get visibleFiles {
    var result = showHidden ? files : files.where((f) => !f.name.startsWith('.')).toList();
    return _sorted(result);
  }

  List<RemoteFileInfo> _sorted(List<RemoteFileInfo> input) {
    final sorted = List<RemoteFileInfo>.from(input);
    sorted.sort((a, b) {
      // Directories always first.
      if (a.isDirectory != b.isDirectory) {
        return a.isDirectory ? -1 : 1;
      }
      final cmp = switch (sortField) {
        SortField.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        SortField.size => a.size.compareTo(b.size),
        SortField.date => (a.modified ?? DateTime(0)).compareTo(b.modified ?? DateTime(0)),
        SortField.type => _ext(a.name).compareTo(_ext(b.name)),
      };
      return sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  static String _ext(String name) {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }

  bool get isMultiSelectMode => selectedPaths.isNotEmpty;

  bool get hasCopiedFiles => copiedPaths.isNotEmpty;
}

// Sentinel value for copyWith nullable fields.
const Object _sentinel = Object();

// ---------------------------------------------------------------------------
// SftpNotifier
// ---------------------------------------------------------------------------

class SftpNotifier extends StateNotifier<SftpState> {
  SftpNotifier(this._sftp, this._transferQueue) : super(const SftpState());

  final SftpService _sftp;
  final TransferQueueNotifier _transferQueue;

  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  Future<void> navigateTo(String path) async {
    state = state.copyWith(isLoading: true, error: null, selectedPaths: {});
    try {
      final files = await _sftp.listDirectory(path);
      state = state.copyWith(
        currentPath: path,
        files: files,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => navigateTo(state.currentPath);

  Future<void> navigateUp() {
    final parent = p.dirname(state.currentPath);
    final target = parent.isEmpty ? '/' : parent;
    if (target == state.currentPath) return Future.value();
    return navigateTo(target);
  }

  void toggleHidden() {
    state = state.copyWith(showHidden: !state.showHidden);
  }

  // ---------------------------------------------------------------------------
  // Sort
  // ---------------------------------------------------------------------------

  void setSort(SortField field) {
    if (state.sortField == field) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortField: field, sortAscending: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void toggleSelection(String path) {
    final current = Set<String>.from(state.selectedPaths);
    if (current.contains(path)) {
      current.remove(path);
    } else {
      current.add(path);
    }
    state = state.copyWith(selectedPaths: current);
  }

  void clearSelection() {
    state = state.copyWith(selectedPaths: {});
  }

  // ---------------------------------------------------------------------------
  // File/directory management
  // ---------------------------------------------------------------------------

  Future<void> createDirectory(String name) async {
    final newPath = _joinPath(state.currentPath, name);
    await _sftp.mkdir(newPath);
    await refresh();
  }

  Future<void> rename(String oldPath, String newName) async {
    final parent = p.dirname(oldPath);
    final newPath = _joinPath(parent, newName);
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
    final paths = Set<String>.from(state.selectedPaths);
    for (final path in paths) {
      final file = state.files.firstWhere(
        (f) => f.path == path,
        orElse: () => RemoteFileInfo(
          name: p.basename(path),
          path: path,
          isDirectory: false,
          size: 0,
        ),
      );
      await delete(path, isDirectory: file.isDirectory);
    }
    clearSelection();
  }

  // ---------------------------------------------------------------------------
  // Copy / Paste
  // ---------------------------------------------------------------------------

  void copyPaths(List<String> paths) {
    state = state.copyWith(copiedPaths: paths);
  }

  void clearCopied() {
    state = state.copyWith(copiedPaths: []);
  }

  Future<void> pasteFiles() async {
    if (state.copiedPaths.isEmpty) return;
    state = state.copyWith(isLoading: true);
    try {
      for (final srcPath in state.copiedPaths) {
        final name = p.basename(srcPath);
        final destPath = _joinPath(state.currentPath, name);
        final info = await _sftp.stat(srcPath);
        if (info.isDirectory) {
          await _sftp.copyRecursive(srcPath, destPath);
        } else {
          await _sftp.copyFile(srcPath, destPath);
        }
      }
      state = state.copyWith(copiedPaths: []);
      await refresh();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Upload
  // ---------------------------------------------------------------------------

  Future<void> uploadFiles() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;

    for (final picked in result.files) {
      final localPath = picked.path;
      if (localPath == null) continue;

      final fileName = picked.name;
      final remotePath = _joinPath(state.currentPath, fileName);
      final transferId = _uuid.v4();

      final item = TransferItem(
        id: transferId,
        fileName: fileName,
        localPath: localPath,
        remotePath: remotePath,
        direction: TransferDirection.upload,
      );
      _transferQueue.addTransfer(item);
      _transferQueue.updateStatus(transferId, TransferStatus.active);

      try {
        await _sftp.uploadFile(
          localPath,
          remotePath,
          onProgress: (transferred, total) {
            _transferQueue.updateProgress(transferId, transferred, total);
          },
        );
        _transferQueue.updateStatus(transferId, TransferStatus.completed);
      } catch (e) {
        _transferQueue.updateStatus(
          transferId,
          TransferStatus.failed,
          error: e.toString(),
        );
        debugPrint('SftpNotifier.uploadFiles error: $e');
      }
    }

    await refresh();
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------

  Future<void> downloadFile(RemoteFileInfo file) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final localPath = p.join(docsDir.path, 'sftp_downloads', file.name);

    final transferId = _uuid.v4();
    final item = TransferItem(
      id: transferId,
      fileName: file.name,
      localPath: localPath,
      remotePath: file.path,
      direction: TransferDirection.download,
    );
    _transferQueue.addTransfer(item);
    _transferQueue.updateStatus(transferId, TransferStatus.active);

    try {
      await _sftp.downloadFile(
        file.path,
        localPath,
        onProgress: (transferred, total) {
          _transferQueue.updateProgress(transferId, transferred, total);
        },
      );
      _transferQueue.updateStatus(transferId, TransferStatus.completed);
    } catch (e) {
      _transferQueue.updateStatus(
        transferId,
        TransferStatus.failed,
        error: e.toString(),
      );
      debugPrint('SftpNotifier.downloadFile error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // File content (for editor)
  // ---------------------------------------------------------------------------

  Future<String> readFileContent(String path) async {
    final bytes = await _sftp.readFile(path);
    return utf8.decode(bytes, allowMalformed: true);
  }

  Future<void> writeFileContent(String path, String content) async {
    final bytes = utf8.encode(content);
    await _sftp.writeFile(path, bytes);
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  Future<void> chmod(String path, int permissions) async {
    await _sftp.chmod(path, permissions);
    await refresh();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _joinPath(String parent, String child) {
    final base = parent.endsWith('/') ? parent : '$parent/';
    return '$base$child';
  }
}
