import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/database/database_provider.dart';

class SettingsKeys {
  static const themeName = 'theme_name';
  static const language = 'language';
  static const startupPage = 'startup_page';
  static const terminalFontSize = 'terminal_font_size';
  static const cursorStyle = 'cursor_style';
  static const scrollbackLines = 'scrollback_lines';
  static const hapticFeedback = 'haptic_feedback';
  static const autoLockMinutes = 'auto_lock_minutes';
  static const biometricEnabled = 'biometric_enabled';
  static const clipboardAutoClear = 'clipboard_auto_clear';
  static const terminalFontFamily = 'terminal_font_family';
  static const voiceInputLocale = 'voice_input_locale';
  static const sttProvider = 'stt_provider';
}

final settingsStreamProvider = StreamProvider<Map<String, String>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.settingsDao.watchAll();
});

class SettingsNotifier extends StateNotifier<Map<String, String>> {
  final Ref _ref;
  SettingsNotifier(this._ref) : super({});

  Future<void> load() async {
    final db = _ref.read(databaseProvider);
    state = await db.settingsDao.getAll();
  }

  Future<void> set(String key, String value) async {
    final db = _ref.read(databaseProvider);
    await db.settingsDao.setValue(key, value);
    state = {...state, key: value};
  }

  Future<void> remove(String key) async {
    final db = _ref.read(databaseProvider);
    await db.settingsDao.deleteValue(key);
    state = Map.from(state)..remove(key);
  }

  String get(String key, {String defaultValue = ''}) => state[key] ?? defaultValue;
  int getInt(String key, {int defaultValue = 0}) => int.tryParse(state[key] ?? '') ?? defaultValue;
  bool getBool(String key, {bool defaultValue = false}) =>
    state[key] == 'true' ? true : (state[key] == 'false' ? false : defaultValue);
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, Map<String, String>>((ref) {
  final notifier = SettingsNotifier(ref);
  notifier.load();
  return notifier;
});
