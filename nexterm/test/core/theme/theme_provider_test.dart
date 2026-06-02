import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

class _FakeSettings extends StateNotifier<Map<String, String>>
    implements SettingsNotifier {
  _FakeSettings(super.state);

  @override
  Future<void> set(String key, String value) async {
    state = {...state, key: value};
  }

  @override
  Future<void> remove(String key) async {
    state = Map.from(state)..remove(key);
  }

  @override
  String get(String key, {String defaultValue = ''}) =>
      state[key] ?? defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) =>
      int.tryParse(state[key] ?? '') ?? defaultValue;

  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      state[key] == 'true' ? true : (state[key] == 'false' ? false : defaultValue);

  @override
  Future<void> load() async {}
}

void main() {
  test('defaults to "nexterm" when no settings present', () {
    final fake = _FakeSettings({});
    final notifier = ThemeNotifier(fake);
    expect(notifier.state, 'nexterm');
  });

  test('loads existing themeName setting', () {
    final fake = _FakeSettings({'theme_name': 'dracula'});
    final notifier = ThemeNotifier(fake);
    expect(notifier.state, 'dracula');
  });

  test('migrates legacy terminal_theme to theme_name and deletes old keys',
      () async {
    final fake = _FakeSettings({
      'terminal_theme': 'catppuccin',
      'theme': 'dark',
    });
    final notifier = ThemeNotifier(fake);
    // legacy migration is async — wait for it
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, 'catppuccin-mocha');
    expect(fake.state['theme_name'], 'catppuccin-mocha');
    expect(fake.state.containsKey('terminal_theme'), false);
    expect(fake.state.containsKey('theme'), false);
  });

  test('setTheme writes the new key', () async {
    final fake = _FakeSettings({});
    final notifier = ThemeNotifier(fake);
    await notifier.setTheme('nord');
    expect(notifier.state, 'nord');
    expect(fake.state['theme_name'], 'nord');
  });
}
