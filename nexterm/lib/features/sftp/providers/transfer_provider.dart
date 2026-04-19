import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransferDirection { upload, download }

enum TransferStatus { queued, active, completed, failed, cancelled }

class TransferItem {
  final String id;
  final String fileName;
  final String localPath;
  final String remotePath;
  final TransferDirection direction;
  int totalBytes;
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

  List<TransferItem> get activeTransfers => state
      .where((t) =>
          t.status == TransferStatus.active ||
          t.status == TransferStatus.queued)
      .toList();

  bool get hasActiveTransfers => activeTransfers.isNotEmpty;
}

final transferQueueProvider =
    StateNotifierProvider<TransferQueueNotifier, List<TransferItem>>((ref) {
  return TransferQueueNotifier();
});
