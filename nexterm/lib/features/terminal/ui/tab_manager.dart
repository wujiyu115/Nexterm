import 'package:flutter/foundation.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:uuid/uuid.dart';

/// Represents a single terminal tab.
class TerminalTab {
  final String id;
  final String hostId;
  String title;
  ConnectionStatus status;
  ConnectionType connectionType;
  String? sessionId;
  int? localPort;
  String? forwardId;

  TerminalTab({
    required this.id,
    required this.hostId,
    required this.title,
    this.status = ConnectionStatus.disconnected,
    this.connectionType = ConnectionType.ssh,
    this.sessionId,
    this.localPort,
    this.forwardId,
  });

  TerminalTab copyWith({
    String? id,
    String? hostId,
    String? title,
    ConnectionStatus? status,
    ConnectionType? connectionType,
    String? Function()? sessionId,
  }) {
    return TerminalTab(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      title: title ?? this.title,
      status: status ?? this.status,
      connectionType: connectionType ?? this.connectionType,
      sessionId: sessionId != null ? sessionId() : this.sessionId,
    );
  }
}

/// Manages the list of open terminal tabs and which one is active.
class TabManager extends ChangeNotifier {
  final List<TerminalTab> _tabs = [];
  int _activeTabIndex = -1;

  static const _uuid = Uuid();

  /// Unmodifiable view of the current tab list.
  List<TerminalTab> get tabs => List.unmodifiable(_tabs);

  /// Index of the currently active tab, or -1 when there are no tabs.
  int get activeTabIndex => _activeTabIndex;

  /// The currently active tab, or null when there are no tabs.
  TerminalTab? get activeTab {
    if (_activeTabIndex < 0 || _activeTabIndex >= _tabs.length) return null;
    return _tabs[_activeTabIndex];
  }

  /// Creates a new tab for [hostId] with [title], sets it as active, and
  /// returns it.
  TerminalTab addTab({required String hostId, required String title}) {
    final tab = TerminalTab(
      id: _uuid.v4(),
      hostId: hostId,
      title: title,
    );
    _tabs.add(tab);
    _activeTabIndex = _tabs.length - 1;
    notifyListeners();
    return tab;
  }

  /// Removes the tab with [tabId]. Adjusts [activeTabIndex] so it remains
  /// valid, or sets it to -1 when the last tab is removed.
  void removeTab(String tabId) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;

    _tabs.removeAt(index);

    if (_tabs.isEmpty) {
      _activeTabIndex = -1;
    } else if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.length - 1;
    } else if (_activeTabIndex > index) {
      _activeTabIndex -= 1;
    }
    // If activeTabIndex == index we keep it as-is (now points to next tab).

    notifyListeners();
  }

  /// Sets the active tab to [index].
  void setActiveTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _activeTabIndex = index;
    notifyListeners();
  }

  /// Updates the [ConnectionStatus] of the tab identified by [tabId].
  void updateTabStatus(String tabId, ConnectionStatus status) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;
    _tabs[index].status = status;
    notifyListeners();
  }

  /// Updates the connection type of the tab identified by [tabId].
  void updateTabConnectionType(String tabId, ConnectionType type) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;
    _tabs[index].connectionType = type;
    notifyListeners();
  }

  /// Updates the session ID of the tab identified by [tabId].
  void updateTabSessionId(String tabId, String? sessionId) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;
    _tabs[index].sessionId = sessionId;
    notifyListeners();
  }

  /// Moves a tab from [oldIndex] to [newIndex] (same semantics as
  /// [ReorderableListView]).
  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _tabs.length ||
        newIndex < 0 ||
        newIndex > _tabs.length) {
      return;
    }

    // ReorderableListView passes newIndex after the removed element, so we
    // must decrement when moving downward.
    final effectiveNew = newIndex > oldIndex ? newIndex - 1 : newIndex;

    final tab = _tabs.removeAt(oldIndex);
    _tabs.insert(effectiveNew, tab);

    // Keep the same tab active.
    if (_activeTabIndex == oldIndex) {
      _activeTabIndex = effectiveNew;
    } else if (oldIndex < effectiveNew) {
      if (_activeTabIndex > oldIndex && _activeTabIndex <= effectiveNew) {
        _activeTabIndex -= 1;
      }
    } else {
      if (_activeTabIndex >= effectiveNew && _activeTabIndex < oldIndex) {
        _activeTabIndex += 1;
      }
    }

    notifyListeners();
  }
}
