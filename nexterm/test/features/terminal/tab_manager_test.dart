import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';

void main() {
  group('TabManager', () {
    late TabManager manager;

    setUp(() {
      manager = TabManager();
    });

    tearDown(() {
      manager.dispose();
    });

    test('starts empty with activeTabIndex = -1', () {
      expect(manager.tabs, isEmpty);
      expect(manager.activeTabIndex, -1);
      expect(manager.activeTab, isNull);
    });

    test('addTab creates a tab and sets it active', () {
      final tab = manager.addTab(hostId: 'h1', title: 'My Host');

      expect(manager.tabs.length, 1);
      expect(manager.activeTabIndex, 0);
      expect(manager.activeTab, isNotNull);
      expect(manager.activeTab!.id, tab.id);
      expect(manager.activeTab!.hostId, 'h1');
      expect(manager.activeTab!.title, 'My Host');
      expect(manager.activeTab!.status, ConnectionStatus.disconnected);
    });

    test('addTab of a second tab makes it active', () {
      manager.addTab(hostId: 'h1', title: 'First');
      final second = manager.addTab(hostId: 'h2', title: 'Second');

      expect(manager.tabs.length, 2);
      expect(manager.activeTabIndex, 1);
      expect(manager.activeTab!.id, second.id);
    });

    test('removeTab on last tab sets activeTabIndex to -1', () {
      final tab = manager.addTab(hostId: 'h1', title: 'Only');
      manager.removeTab(tab.id);

      expect(manager.tabs, isEmpty);
      expect(manager.activeTabIndex, -1);
      expect(manager.activeTab, isNull);
    });

    test('removeTab of active tab (not last) keeps a valid index', () {
      final t1 = manager.addTab(hostId: 'h1', title: 'A');
      manager.addTab(hostId: 'h2', title: 'B');
      manager.setActiveTab(0);

      manager.removeTab(t1.id);

      expect(manager.tabs.length, 1);
      expect(manager.activeTabIndex, 0);
      expect(manager.activeTab!.title, 'B');
    });

    test('removeTab of non-active tab before active decrements index', () {
      final t1 = manager.addTab(hostId: 'h1', title: 'A');
      manager.addTab(hostId: 'h2', title: 'B');
      // active is index 1 (t2)
      expect(manager.activeTabIndex, 1);

      manager.removeTab(t1.id);

      expect(manager.tabs.length, 1);
      expect(manager.activeTabIndex, 0);
    });

    test('removeTab of unknown id is a no-op', () {
      manager.addTab(hostId: 'h1', title: 'A');
      manager.removeTab('nonexistent');

      expect(manager.tabs.length, 1);
    });

    test('setActiveTab changes activeTabIndex', () {
      manager.addTab(hostId: 'h1', title: 'A');
      manager.addTab(hostId: 'h2', title: 'B');

      manager.setActiveTab(0);
      expect(manager.activeTabIndex, 0);
      expect(manager.activeTab!.title, 'A');
    });

    test('setActiveTab with out-of-bounds index is a no-op', () {
      manager.addTab(hostId: 'h1', title: 'A');

      manager.setActiveTab(5);
      expect(manager.activeTabIndex, 0); // unchanged
    });

    test('updateTabStatus changes status', () {
      final tab = manager.addTab(hostId: 'h1', title: 'A');
      expect(manager.tabs.first.status, ConnectionStatus.disconnected);

      manager.updateTabStatus(tab.id, ConnectionStatus.connecting);
      expect(manager.tabs.first.status, ConnectionStatus.connecting);

      manager.updateTabStatus(tab.id, ConnectionStatus.connected);
      expect(manager.tabs.first.status, ConnectionStatus.connected);
    });

    test('updateTabStatus on unknown id is a no-op', () {
      manager.addTab(hostId: 'h1', title: 'A');
      manager.updateTabStatus('unknown', ConnectionStatus.connected);
      expect(manager.tabs.first.status, ConnectionStatus.disconnected);
    });

    test('reorderTabs moves tab from first to last position', () {
      final t1 = manager.addTab(hostId: 'h1', title: 'A');
      final t2 = manager.addTab(hostId: 'h2', title: 'B');
      final t3 = manager.addTab(hostId: 'h3', title: 'C');

      // Move index 0 (A) to position 3 (end) — ReorderableListView style
      manager.reorderTabs(0, 3);

      expect(manager.tabs[0].id, t2.id);
      expect(manager.tabs[1].id, t3.id);
      expect(manager.tabs[2].id, t1.id);
    });

    test('reorderTabs moves tab from last to first position', () {
      final t1 = manager.addTab(hostId: 'h1', title: 'A');
      final t2 = manager.addTab(hostId: 'h2', title: 'B');
      final t3 = manager.addTab(hostId: 'h3', title: 'C');

      // Move index 2 (C) to position 0 (start)
      manager.reorderTabs(2, 0);

      expect(manager.tabs[0].id, t3.id);
      expect(manager.tabs[1].id, t1.id);
      expect(manager.tabs[2].id, t2.id);
    });

    test('activeTab returns correct tab when multiple exist', () {
      manager.addTab(hostId: 'h1', title: 'A');
      final t2 = manager.addTab(hostId: 'h2', title: 'B');
      manager.addTab(hostId: 'h3', title: 'C');

      manager.setActiveTab(1);
      expect(manager.activeTab!.id, t2.id);
    });

    test('activeTab returns null when tabs list is empty', () {
      expect(manager.activeTab, isNull);
    });

    test('notifyListeners is called on addTab', () {
      var notified = false;
      manager.addListener(() => notified = true);

      manager.addTab(hostId: 'h1', title: 'A');
      expect(notified, isTrue);
    });

    test('notifyListeners is called on removeTab', () {
      final tab = manager.addTab(hostId: 'h1', title: 'A');
      var notified = false;
      manager.addListener(() => notified = true);

      manager.removeTab(tab.id);
      expect(notified, isTrue);
    });
  });
}
