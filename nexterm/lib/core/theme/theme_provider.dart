import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_catalog.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

/// Holds the active theme name (key into `ThemeCatalog`).
class ThemeNotifier extends StateNotifier<String> {
  final SettingsNotifier _settings;

  ThemeNotifier(this._settings) : super('nexterm') {
    _load();
  }

  Future<void> _load() async {
    final legacyTerminal = _settings.get(SettingsKeys.terminalTheme);
    final stored = _settings.get(SettingsKeys.themeName);

    if (legacyTerminal.isNotEmpty) {
      // One-time migration from old split settings.
      final mapped = ThemeCatalog.mapLegacy(legacyTerminal);
      await _settings.set(SettingsKeys.themeName, mapped);
      await _settings.remove(SettingsKeys.terminalTheme);
      await _settings.remove(SettingsKeys.theme);
      state = mapped;
    } else if (stored.isNotEmpty && ThemeCatalog.all.containsKey(stored)) {
      state = stored;
    } else {
      state = 'nexterm';
    }
  }

  Future<void> setTheme(String key) async {
    if (!ThemeCatalog.all.containsKey(key)) return;
    state = key;
    await _settings.set(SettingsKeys.themeName, key);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return ThemeNotifier(settings);
});

/// Active palette derived from [themeProvider].
final paletteProvider = Provider<ThemePalette>((ref) {
  final key = ref.watch(themeProvider);
  return ThemeCatalog.byKey(key);
});
