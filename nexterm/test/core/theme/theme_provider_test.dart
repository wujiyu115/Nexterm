import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

class _FakeSettings extends StateNotifier<Map<String, String>>
    implements SettingsNotifier {
  _FakeSettings(super.state);

  /// Replaces state in a single shot — mirrors the real
  /// `SettingsNotifier.load()` which assigns `state = await dao.getAll()`.
  void hydrate(Map<String, String> snapshot) {
    state = Map<String, String>.from(snapshot);
  }

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

  test(
      'reacts to late settings hydration — applies stored theme_name '
      'arriving after construction', () async {
    // Mirrors production: SettingsNotifier starts empty and load() resolves
    // asynchronously after ThemeNotifier has already been constructed.
    final fake = _FakeSettings({});
    final notifier = ThemeNotifier(fake);
    expect(notifier.state, 'nexterm', reason: 'default while settings empty');

    // Simulate `settings.load()` completing.
    fake.hydrate({'theme_name': 'dracula'});
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state, 'dracula');
  });

  test(
      'reacts to late settings hydration — runs legacy migration when old '
      'keys arrive after construction', () async {
    final fake = _FakeSettings({});
    final notifier = ThemeNotifier(fake);
    expect(notifier.state, 'nexterm');

    // Simulate `settings.load()` resolving with legacy keys.
    fake.hydrate({'terminal_theme': 'catppuccin', 'theme': 'dark'});
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state, 'catppuccin-mocha');
    expect(fake.state['theme_name'], 'catppuccin-mocha');
    expect(fake.state.containsKey('terminal_theme'), false);
    expect(fake.state.containsKey('theme'), false);
  });
}
