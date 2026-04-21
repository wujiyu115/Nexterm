import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  final SettingsNotifier _settings;

  LocaleNotifier(this._settings) : super(null) {
    _load();
  }

  void _load() {
    final lang = _settings.get(SettingsKeys.language);
    state = _parseLocale(lang);
  }

  Future<void> setLocale(String languageCode) async {
    await _settings.set(SettingsKeys.language, languageCode);
    state = _parseLocale(languageCode);
  }

  static Locale? _parseLocale(String code) {
    return switch (code) {
      'zh' => const Locale('zh'),
      'en' => const Locale('en'),
      _ => null,
    };
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return LocaleNotifier(settings);
});
