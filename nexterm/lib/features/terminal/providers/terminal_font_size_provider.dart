import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

const _defaultFontSize = 13.0;
const _minFontSize = 8.0;
const _maxFontSize = 24.0;

class TerminalFontSizeNotifier extends StateNotifier<double> {
  final SettingsNotifier _settings;

  TerminalFontSizeNotifier(this._settings) : super(_defaultFontSize) {
    final raw = _settings.get(SettingsKeys.terminalFontSize);
    if (raw.isNotEmpty) {
      state = (double.tryParse(raw) ?? _defaultFontSize)
          .clamp(_minFontSize, _maxFontSize);
    }
  }

  Future<void> setSize(double size) async {
    state = size.clamp(_minFontSize, _maxFontSize);
    await _settings.set(
        SettingsKeys.terminalFontSize, state.round().toString());
  }
}

final terminalFontSizeProvider =
    StateNotifierProvider<TerminalFontSizeNotifier, double>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return TerminalFontSizeNotifier(settings);
});
