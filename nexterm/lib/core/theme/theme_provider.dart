import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_catalog.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

/// Holds the active theme name (key into `ThemeCatalog`).
///
/// The notifier reacts to [SettingsNotifier] state changes so that it can
/// hydrate (and run a one-time legacy migration) once settings finish loading
/// from disk. `SettingsNotifier.load()` is fired-and-forgotten in its provider
/// factory, so subscribing via `addListener` is the only safe way to observe
/// the late-arriving snapshot.
class ThemeNotifier extends StateNotifier<String> {
  final SettingsNotifier _settings;
  late final RemoveListener _removeSettingsListener;
  bool _migratedOnce = false;

  ThemeNotifier(this._settings) : super('nexterm') {
    // `addListener` defaults to `fireImmediately: true`, so this both syncs
    // against the current snapshot AND subscribes to future updates.
    _removeSettingsListener = _settings.addListener(_syncFromSettings);
  }

  @override
  void dispose() {
    _removeSettingsListener();
    super.dispose();
  }

  void _syncFromSettings(Map<String, String> snapshot) {
    if (_migratedOnce) {
      // After the first successful sync, only react to explicit `setTheme`
      // writes — don't reinterpret legacy keys again.
      final stored = snapshot[SettingsKeys.themeName] ?? '';
      if (stored.isNotEmpty &&
          ThemeCatalog.all.containsKey(stored) &&
          stored != state) {
        state = stored;
      }
      return;
    }

    final legacyTerminal = snapshot[SettingsKeys.terminalTheme] ?? '';
    final stored = snapshot[SettingsKeys.themeName] ?? '';

    if (legacyTerminal.isNotEmpty) {
      // Assign FIRST so UI gets the correct palette immediately; persist the
      // migration in the background.
      final mapped = ThemeCatalog.mapLegacy(legacyTerminal);
      state = mapped;
      _migratedOnce = true;
      _settings.set(SettingsKeys.themeName, mapped);
      _settings.remove(SettingsKeys.terminalTheme);
      _settings.remove(SettingsKeys.theme);
    } else if (stored.isNotEmpty && ThemeCatalog.all.containsKey(stored)) {
      state = stored;
      _migratedOnce = true;
    } else if (snapshot.isNotEmpty) {
      // Settings hydrated but neither key present — first install. Lock in
      // the default so future hydration callbacks don't keep re-running the
      // migration branch.
      _migratedOnce = true;
    }
    // If snapshot is empty, settings hasn't hydrated yet — wait for the next
    // listener callback.
  }

  Future<void> setTheme(String key) async {
    if (!ThemeCatalog.all.containsKey(key)) {
      assert(false, 'Unknown theme key: $key');
      return;
    }
    state = key;
    _migratedOnce = true;
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
