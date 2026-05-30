import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

const defaultScrollbackLines = 10000;
const scrollbackOptions = [1000, 5000, 10000, 50000, 100000];

class TerminalScrollbackNotifier extends StateNotifier<int> {
  final SettingsNotifier _settings;

  TerminalScrollbackNotifier(this._settings) : super(defaultScrollbackLines) {
    final raw = _settings.get(SettingsKeys.scrollbackLines);
    if (raw.isNotEmpty) {
      state = int.tryParse(raw) ?? defaultScrollbackLines;
    }
  }

  Future<void> setLines(int lines) async {
    state = lines;
    await _settings.set(SettingsKeys.scrollbackLines, lines.toString());
  }
}

final terminalScrollbackProvider =
    StateNotifierProvider<TerminalScrollbackNotifier, int>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return TerminalScrollbackNotifier(settings);
});
