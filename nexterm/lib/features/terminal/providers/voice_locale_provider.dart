import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Currently selected voice-input locale id.
///
/// Empty string means "follow system default" — the keyboard toolbar will
/// then call `_speech.listen()` without a `localeId`.
final voiceLocaleIdProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings[SettingsKeys.voiceInputLocale] ?? '';
});

/// Locales the on-device speech recognizer reports it can handle.
///
/// Loaded lazily the first time the picker is opened so we don't trigger
/// the speech/microphone permission prompt at app launch. If `initialize()`
/// fails (permission denied, simulator without speech, etc.) we fall back
/// to a curated set of common locales so the user can still pick one.
final availableSpeechLocalesProvider =
    FutureProvider.autoDispose<List<LocaleName>>((ref) async {
  final speech = SpeechToText();
  try {
    final ok = await speech.initialize();
    if (ok) {
      final locales = await speech.locales();
      if (locales.isNotEmpty) return locales;
    }
  } catch (_) {
    // fall through to fallback list
  }
  return _fallbackLocales;
});

final List<LocaleName> _fallbackLocales = [
  LocaleName('zh-CN', '中文(中国大陆)'),
  LocaleName('zh-TW', '中文(台灣)'),
  LocaleName('zh-HK', '中文(香港)'),
  LocaleName('en-US', 'English (United States)'),
  LocaleName('en-GB', 'English (United Kingdom)'),
  LocaleName('ja-JP', '日本語'),
  LocaleName('ko-KR', '한국어'),
  LocaleName('fr-FR', 'Français (France)'),
  LocaleName('de-DE', 'Deutsch (Deutschland)'),
  LocaleName('es-ES', 'Español (España)'),
];
