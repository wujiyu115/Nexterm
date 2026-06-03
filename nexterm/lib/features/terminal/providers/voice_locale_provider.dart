import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/terminal/providers/stt_provider.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:speech_to_text/speech_to_text.dart';

final voiceLocaleIdProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings[SettingsKeys.voiceInputLocale] ?? '';
});

final availableSpeechLocalesProvider =
    FutureProvider.autoDispose<List<LocaleName>>((ref) async {
  final type = ref.watch(sttProviderTypeProvider);
  switch (type) {
    case SttProviderType.system:
      return _systemLocales();
    case SttProviderType.volcengine:
      return _volcengineLocales;
    case SttProviderType.alibaba:
      return _aliyunLocales;
  }
});

Future<List<LocaleName>> _systemLocales() async {
  final speech = SpeechToText();
  try {
    final ok = await speech.initialize();
    if (ok) {
      final locales = await speech.locales();
      if (locales.isNotEmpty) return locales;
    }
  } catch (_) {}
  return _fallbackLocales;
}

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

final List<LocaleName> _volcengineLocales = [
  LocaleName('zh-CN', '中文(中国大陆)'),
  LocaleName('en-US', 'English'),
  LocaleName('ja-JP', '日本語'),
  LocaleName('ko-KR', '한국어'),
  LocaleName('de-DE', 'Deutsch'),
  LocaleName('fr-FR', 'Français'),
  LocaleName('es-ES', 'Español'),
];

final List<LocaleName> _aliyunLocales = [
  LocaleName('zh-CN', '中文(中国大陆)'),
  LocaleName('zh-TW', '中文(台灣)'),
  LocaleName('zh-HK', '中文(香港/粤语)'),
  LocaleName('en-US', 'English (US)'),
  LocaleName('en-GB', 'English (UK)'),
  LocaleName('ja-JP', '日本語'),
  LocaleName('ko-KR', '한국어'),
  LocaleName('fr-FR', 'Français'),
  LocaleName('de-DE', 'Deutsch'),
  LocaleName('es-ES', 'Español'),
  LocaleName('ru-RU', 'Русский'),
  LocaleName('id-ID', 'Bahasa Indonesia'),
];
