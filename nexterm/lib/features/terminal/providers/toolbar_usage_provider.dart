import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

const _usageKey = 'toolbar_key_usage';

class ToolbarUsageNotifier extends StateNotifier<Map<String, int>> {
  final SettingsNotifier _settings;

  ToolbarUsageNotifier(this._settings) : super({}) {
    _load();
  }

  void _load() {
    final raw = _settings.get(_usageKey);
    if (raw.isEmpty) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = map.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      state = {};
    }
  }

  Future<void> _save() async {
    await _settings.set(_usageKey, jsonEncode(state));
  }

  Future<void> increment(String keyId) async {
    final counts = Map<String, int>.from(state);
    counts[keyId] = (counts[keyId] ?? 0) + 1;
    state = counts;
    await _save();
  }
}

final toolbarUsageProvider =
    StateNotifierProvider<ToolbarUsageNotifier, Map<String, int>>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return ToolbarUsageNotifier(settings);
});