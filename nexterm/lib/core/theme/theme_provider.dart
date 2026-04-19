import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreference { light, dark, system }

class ThemeState {
  final ThemePreference preference;
  final String terminalThemeName;

  const ThemeState({
    this.preference = ThemePreference.system,
    this.terminalThemeName = 'catppuccin',
  });

  ThemeState copyWith({ThemePreference? preference, String? terminalThemeName}) {
    return ThemeState(
      preference: preference ?? this.preference,
      terminalThemeName: terminalThemeName ?? this.terminalThemeName,
    );
  }

  ThemeMode get themeMode => switch (preference) {
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.system => ThemeMode.system,
  };
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void setThemePreference(ThemePreference preference) {
    state = state.copyWith(preference: preference);
  }

  void setTerminalTheme(String themeName) {
    state = state.copyWith(terminalThemeName: themeName);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
