import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/terminal/models/toolbar_key_definition.dart';

const _settingsKey = 'toolbar_group_order';
const _visibleCountKey = 'toolbar_visible_groups';
const defaultVisibleGroupCount = 4;

/// Manages the toolbar key group configuration (order, enabled/disabled).
///
/// Persists the group order as a JSON list of group IDs in [SettingsNotifier].
class ToolbarConfigNotifier extends StateNotifier<List<ToolbarKeyGroup>> {
  final SettingsNotifier _settings;

  ToolbarConfigNotifier(this._settings) : super(defaultToolbarGroups) {
    _load();
  }

  // -------------------------------------------------------------------------
  // Persistence
  // -------------------------------------------------------------------------

  void _load() {
    final raw = _settings.get(_settingsKey);
    if (raw.isEmpty) {
      state = defaultToolbarGroups;
      return;
    }

    try {
      final orderedIds = (jsonDecode(raw) as List).cast<String>();
      final defaults = {for (final g in defaultToolbarGroups) g.id: g};

      // Rebuild the list in the saved order, skipping unknown IDs.
      final ordered = <ToolbarKeyGroup>[];
      for (final id in orderedIds) {
        final group = defaults.remove(id);
        if (group != null) ordered.add(group);
      }
      // Append any new default groups that weren't in the saved order.
      ordered.addAll(defaults.values);

      state = ordered;
    } catch (_) {
      state = defaultToolbarGroups;
    }
  }

  Future<void> _save() async {
    final ids = state.map((g) => g.id).toList();
    await _settings.set(_settingsKey, jsonEncode(ids));
  }

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Reorders a group from [oldIndex] to [newIndex].
  Future<void> reorderGroup(int oldIndex, int newIndex) async {
    final list = List<ToolbarKeyGroup>.from(state);
    final item = list.removeAt(oldIndex);
    // ReorderableListView passes newIndex that accounts for the removed item.
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(insertAt, item);
    state = list;
    await _save();
  }

  /// Removes a group by its [groupId].
  Future<void> removeGroup(String groupId) async {
    state = state.where((g) => g.id != groupId).toList();
    await _save();
  }

  /// Adds a group back (from the default set) at the end.
  Future<void> addGroup(String groupId) async {
    // Don't add duplicates.
    if (state.any((g) => g.id == groupId)) return;

    final defaults = defaultToolbarGroups;
    final group = defaults.firstWhere(
      (g) => g.id == groupId,
      orElse: () => throw ArgumentError('Unknown group: $groupId'),
    );
    state = [...state, group];
    await _save();
  }

  /// Returns the list of default groups that are currently removed.
  List<ToolbarKeyGroup> get removedGroups {
    final activeIds = state.map((g) => g.id).toSet();
    return defaultToolbarGroups.where((g) => !activeIds.contains(g.id)).toList();
  }

  /// Restores the default toolbar configuration.
  Future<void> restoreDefaults() async {
    state = defaultToolbarGroups;
    await _settings.remove(_settingsKey);
  }
}

final toolbarConfigProvider =
    StateNotifierProvider<ToolbarConfigNotifier, List<ToolbarKeyGroup>>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return ToolbarConfigNotifier(settings);
});

// ---------------------------------------------------------------------------
// Visible group count
// ---------------------------------------------------------------------------

class VisibleGroupCountNotifier extends StateNotifier<int> {
  final SettingsNotifier _settings;

  VisibleGroupCountNotifier(this._settings)
      : super(defaultVisibleGroupCount) {
    _load();
  }

  void _load() {
    final raw = _settings.get(_visibleCountKey);
    if (raw.isNotEmpty) {
      state = (int.tryParse(raw) ?? defaultVisibleGroupCount)
          .clamp(1, defaultToolbarGroups.length);
    }
  }

  Future<void> setCount(int count) async {
    state = count.clamp(1, defaultToolbarGroups.length);
    await _settings.set(_visibleCountKey, state.toString());
  }
}

final visibleGroupCountProvider =
    StateNotifierProvider<VisibleGroupCountNotifier, int>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return VisibleGroupCountNotifier(settings);
});
