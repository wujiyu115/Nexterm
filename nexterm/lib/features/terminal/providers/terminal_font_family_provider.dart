import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

const defaultFontFamily = 'JetBrains Mono';

const terminalFontFamilies = [
  'JetBrains Mono',
  'Source Code Pro',
  'Fira Code',
  'Ubuntu Mono',
];

class TerminalFontFamilyNotifier extends StateNotifier<String> {
  final SettingsNotifier _settings;

  TerminalFontFamilyNotifier(this._settings) : super(defaultFontFamily) {
    final raw = _settings.get(SettingsKeys.terminalFontFamily);
    if (raw.isNotEmpty && terminalFontFamilies.contains(raw)) {
      state = raw;
    }
  }

  Future<void> setFamily(String family) async {
    state = family;
    await _settings.set(SettingsKeys.terminalFontFamily, family);
  }
}

final terminalFontFamilyProvider =
    StateNotifierProvider<TerminalFontFamilyNotifier, String>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return TerminalFontFamilyNotifier(settings);
});
