import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';

TransferItem _makeItem({
  String id = 't1',
  String fileName = 'file.txt',
  int totalBytes = 0,
  int transferredBytes = 0,
  TransferStatus status = TransferStatus.queued,
}) {
  return TransferItem(
    id: id,
    fileName: fileName,
    localPath: '/local/$fileName',
    remotePath: '/remote/$fileName',
    direction: TransferDirection.upload,
    totalBytes: totalBytes,
    transferredBytes: transferredBytes,
    status: status,
  );
}

void main() {
  group('TransferQueueNotifier', () {
    late TransferQueueNotifier notifier;

    setUp(() {
      notifier = TransferQueueNotifier();
    });

    test('addTransfer appends item to state', () {
      final item = _makeItem(id: 't1');
      notifier.addTransfer(item);
      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.id, equals('t1'));
    });

    test('addTransfer appends multiple items in order', () {
      notifier.addTransfer(_makeItem(id: 't1'));
      notifier.addTransfer(_makeItem(id: 't2'));
      notifier.addTransfer(_makeItem(id: 't3'));
      expect(notifier.state.map((i) => i.id).toList(),
          equals(['t1', 't2', 't3']));
    });

    test('updateProgress sets bytes on correct item by ID', () {
      notifier.addTransfer(_makeItem(id: 't1', totalBytes: 1000));
      notifier.addTransfer(_makeItem(id: 't2', totalBytes: 500));

      notifier.updateProgress('t1', 400, 1000);

      final t1 = notifier.state.firstWhere((i) => i.id == 't1');
      final t2 = notifier.state.firstWhere((i) => i.id == 't2');
      expect(t1.transferredBytes, equals(400));
      expect(t1.totalBytes, equals(1000));
      // t2 should remain unchanged
      expect(t2.transferredBytes, equals(0));
    });

    group('updateStatus transitions', () {
      test('queued → active', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.queued));
        notifier.updateStatus('t1', TransferStatus.active);
        expect(notifier.state.first.status, equals(TransferStatus.active));
      });

      test('active → completed', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.active));
        notifier.updateStatus('t1', TransferStatus.completed);
        expect(notifier.state.first.status, equals(TransferStatus.completed));
      });

      test('active → failed with error message', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.active));
        notifier.updateStatus('t1', TransferStatus.failed, error: 'Connection lost');
        final item = notifier.state.first;
        expect(item.status, equals(TransferStatus.failed));
        expect(item.error, equals('Connection lost'));
      });

      test('active → cancelled', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.active));
        notifier.updateStatus('t1', TransferStatus.cancelled);
        expect(notifier.state.first.status, equals(TransferStatus.cancelled));
      });

      test('only the targeted item changes status', () {
        notifier.addTransfer(_makeItem(id: 't1'));
        notifier.addTransfer(_makeItem(id: 't2'));
        notifier.updateStatus('t1', TransferStatus.completed);
        expect(notifier.state.firstWhere((i) => i.id == 't2').status,
            equals(TransferStatus.queued));
      });
    });

    group('removeCompleted', () {
      test('removes only completed items, keeps others', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.queued));
        notifier.addTransfer(_makeItem(id: 't2', status: TransferStatus.active));
        notifier.addTransfer(_makeItem(id: 't3', status: TransferStatus.completed));
        notifier.addTransfer(_makeItem(id: 't4', status: TransferStatus.failed));

        notifier.removeCompleted();

        final ids = notifier.state.map((i) => i.id).toList();
        expect(ids, containsAll(['t1', 't2', 't4']));
        expect(ids, isNot(contains('t3')));
      });

      test('removes all items when all are completed', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.completed));
        notifier.addTransfer(_makeItem(id: 't2', status: TransferStatus.completed));
        notifier.removeCompleted();
        expect(notifier.state, isEmpty);
      });

      test('keeps all items when none are completed', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.queued));
        notifier.addTransfer(_makeItem(id: 't2', status: TransferStatus.failed));
        notifier.removeCompleted();
        expect(notifier.state, hasLength(2));
      });
    });

    group('activeTransfers', () {
      test('excludes completed items', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.active));
        notifier.addTransfer(_makeItem(id: 't2', status: TransferStatus.completed));
        expect(notifier.activeTransfers.map((i) => i.id), contains('t1'));
        expect(notifier.activeTransfers.map((i) => i.id), isNot(contains('t2')));
      });

      test('excludes failed items', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.failed));
        expect(notifier.activeTransfers, isEmpty);
      });

      test('excludes cancelled items', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.cancelled));
        expect(notifier.activeTransfers, isEmpty);
      });

      test('includes queued and active items', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.queued));
        notifier.addTransfer(_makeItem(id: 't2', status: TransferStatus.active));
        expect(notifier.activeTransfers, hasLength(2));
      });
    });

    group('hasActiveTransfers', () {
      test('returns true when there are active or queued items', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.queued));
        expect(notifier.hasActiveTransfers, isTrue);
      });

      test('returns false when state is empty', () {
        expect(notifier.hasActiveTransfers, isFalse);
      });

      test('returns false when only completed/failed/cancelled items remain', () {
        notifier.addTransfer(_makeItem(id: 't1', status: TransferStatus.completed));
        notifier.addTransfer(_makeItem(id: 't2', status: TransferStatus.failed));
        notifier.addTransfer(_makeItem(id: 't3', status: TransferStatus.cancelled));
        expect(notifier.hasActiveTransfers, isFalse);
      });
    });
  });

  group('TransferItem.progress', () {
    test('returns 0 when totalBytes is 0', () {
      final item = _makeItem(totalBytes: 0, transferredBytes: 0);
      expect(item.progress, equals(0.0));
    });

    test('returns 0 when totalBytes is 0 even with non-zero transferred', () {
      final item = _makeItem(totalBytes: 0, transferredBytes: 100);
      expect(item.progress, equals(0.0));
    });

    test('returns correct ratio when totalBytes > 0', () {
      final item = _makeItem(totalBytes: 1000, transferredBytes: 250);
      expect(item.progress, closeTo(0.25, 0.0001));
    });

    test('returns 1.0 when fully transferred', () {
      final item = _makeItem(totalBytes: 500, transferredBytes: 500);
      expect(item.progress, equals(1.0));
    });
  });
}
