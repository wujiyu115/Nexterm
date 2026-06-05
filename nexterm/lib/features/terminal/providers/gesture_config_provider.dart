import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/terminal/models/gesture_config.dart';

const _settingsKey = 'gesture_bindings';

class GestureConfigNotifier extends StateNotifier<List<GestureBinding>> {
  final Ref _ref;

  GestureConfigNotifier(this._ref) : super(GestureBinding.defaultBindings) {
    _load();
  }

  void _load() {
    final raw = _ref.read(settingsNotifierProvider)[_settingsKey];
    if (raw != null && raw.isNotEmpty) {
      state = GestureBinding.decodeList(raw);
    }
  }

  GestureAction actionFor(GestureType gesture) {
    final binding = state.where((b) => b.gesture == gesture);
    return binding.isEmpty ? GestureAction.none : binding.first.action;
  }

  Future<void> updateBinding(GestureType gesture, GestureAction action) async {
    final updated = state.map((b) {
      if (b.gesture == gesture) return GestureBinding(gesture: gesture, action: action);
      return b;
    }).toList();
    state = updated;
    await _ref.read(settingsNotifierProvider.notifier).set(
      _settingsKey, GestureBinding.encodeList(updated));
  }
}

final gestureConfigProvider =
    StateNotifierProvider<GestureConfigNotifier, List<GestureBinding>>((ref) {
  return GestureConfigNotifier(ref);
});
