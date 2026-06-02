import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/terminal_themes.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class ThemeCatalog {
  ThemeCatalog._();

  static const Map<String, ThemePalette> all = {
    'nexterm': _nexterm,
    'dracula': _dracula,
    'nord': _nord,
    'solarized-dark': _solarizedDark,
    'gruvbox': _gruvbox,
    'catppuccin-mocha': _catppuccinMocha,
    'solarized-light': _solarizedLight,
    'catppuccin-latte': _catppuccinLatte,
    'github-light': _githubLight,
    'rose-pine-dawn': _rosePineDawn,
  };

  /// Returns the palette for [key], falling back to `nexterm` if absent.
  static ThemePalette byKey(String key) => all[key] ?? _nexterm;

  /// Maps legacy `terminal_theme` setting values (which used different keys
  /// before unified theming) to the new theme keys. `monokai` is dropped and
  /// remapped to `nexterm`.
  static String mapLegacy(String legacyName) {
    switch (legacyName) {
      case 'catppuccin':
        return 'catppuccin-mocha';
      case 'dracula':
        return 'dracula';
      case 'solarized-dark':
        return 'solarized-dark';
      case 'solarized-light':
        return 'solarized-light';
      default:
        return 'nexterm';
    }
  }

  /// Display name shown in the picker. Brand names are not localized.
  static String displayName(String key) {
    switch (key) {
      case 'nexterm':
        return 'Nexterm';
      case 'dracula':
        return 'Dracula';
      case 'nord':
        return 'Nord';
      case 'solarized-dark':
        return 'Solarized Dark';
      case 'gruvbox':
        return 'Gruvbox';
      case 'catppuccin-mocha':
        return 'Catppuccin Mocha';
      case 'solarized-light':
        return 'Solarized Light';
      case 'catppuccin-latte':
        return 'Catppuccin Latte';
      case 'github-light':
        return 'GitHub Light';
      case 'rose-pine-dawn':
        return 'Rosé Pine Dawn';
      default:
        assert(false, 'displayName missing for theme key: $key');
        return key;
    }
  }

  static const List<String> darkKeys = [
    'nexterm',
    'dracula',
    'nord',
    'solarized-dark',
    'gruvbox',
    'catppuccin-mocha',
  ];

  static const List<String> lightKeys = [
    'solarized-light',
    'catppuccin-latte',
    'github-light',
    'rose-pine-dawn',
  ];

  // ───────────────────────── Dark palettes ─────────────────────────

  static const _nexterm = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF0D1117),
    bgElevated: Color(0xFF161B22),
    surface: Color(0xC7161B22),
    surfaceSolid: Color(0xFF1C2128),
    cardBg: Color(0xA6161B22),
    navBg: Color(0xB80D1117),
    inputBg: Color(0xCC1E242C),
    fg: Color(0xFFE6EDF3),
    fgSecondary: Color(0xFF8B949E),
    fgTertiary: Color(0xFF484F58),
    tabInactive: Color(0xFF484F58),
    border: Color(0x9930363D),
    glassBorder: Color(0x145CB85C),
    accent: Color(0xFF5CB85C),
    accentDim: Color(0x265CB85C),
    accentGlow: Color(0x4D5CB85C),
    statusOnline: Color(0xFF3FB950),
    statusConnecting: Color(0xFFD29922),
    statusOffline: Color(0xFF484F58),
    statusError: Color(0xFFF85149),
    terminalBg: Color(0xFF0D1117),
    termPrompt: Color(0xFF5CB85C),
    termPath: Color(0xFF89B4FA),
    termCommand: Color(0xFFCDD6F4),
    termOutput: Color(0xFF8B949E),
    terminal: TerminalThemes.catppuccin,
  );

  static const _dracula = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF282A36),
    bgElevated: Color(0xFF343746),
    surface: Color(0xC744475A),
    surfaceSolid: Color(0xFF44475A),
    cardBg: Color(0xA644475A),
    navBg: Color(0xB8282A36),
    inputBg: Color(0xCC343746),
    fg: Color(0xFFF8F8F2),
    fgSecondary: Color(0xFF6272A4),
    fgTertiary: Color(0xFF44475A),
    tabInactive: Color(0xFF6272A4),
    border: Color(0x996272A4),
    glassBorder: Color(0x14BD93F9),
    accent: Color(0xFFBD93F9),
    accentDim: Color(0x26BD93F9),
    accentGlow: Color(0x4DBD93F9),
    statusOnline: Color(0xFF50FA7B),
    statusConnecting: Color(0xFFF1FA8C),
    statusOffline: Color(0xFF6272A4),
    statusError: Color(0xFFFF5555),
    terminalBg: Color(0xFF282A36),
    termPrompt: Color(0xFF50FA7B),
    termPath: Color(0xFF8BE9FD),
    termCommand: Color(0xFFF8F8F2),
    termOutput: Color(0xFF6272A4),
    terminal: TerminalThemes.dracula,
  );

  static const _nord = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF2E3440),
    bgElevated: Color(0xFF3B4252),
    surface: Color(0xC7434C5E),
    surfaceSolid: Color(0xFF434C5E),
    cardBg: Color(0xA63B4252),
    navBg: Color(0xB82E3440),
    inputBg: Color(0xCC3B4252),
    fg: Color(0xFFECEFF4),
    fgSecondary: Color(0xFFD8DEE9),
    fgTertiary: Color(0xFF4C566A),
    tabInactive: Color(0xFF4C566A),
    border: Color(0x99434C5E),
    glassBorder: Color(0x1488C0D0),
    accent: Color(0xFF88C0D0),
    accentDim: Color(0x2688C0D0),
    accentGlow: Color(0x4D88C0D0),
    statusOnline: Color(0xFFA3BE8C),
    statusConnecting: Color(0xFFEBCB8B),
    statusOffline: Color(0xFF4C566A),
    statusError: Color(0xFFBF616A),
    terminalBg: Color(0xFF2E3440),
    termPrompt: Color(0xFFA3BE8C),
    termPath: Color(0xFF81A1C1),
    termCommand: Color(0xFFECEFF4),
    termOutput: Color(0xFFD8DEE9),
    terminal: TerminalThemes.nord,
  );

  static const _solarizedDark = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF002B36),
    bgElevated: Color(0xFF073642),
    surface: Color(0xC7073642),
    surfaceSolid: Color(0xFF073642),
    cardBg: Color(0xA6073642),
    navBg: Color(0xB8002B36),
    inputBg: Color(0xCC073642),
    fg: Color(0xFF839496),
    fgSecondary: Color(0xFF93A1A1),
    fgTertiary: Color(0xFF586E75),
    tabInactive: Color(0xFF586E75),
    border: Color(0x99586E75),
    glassBorder: Color(0x14268BD2),
    accent: Color(0xFF268BD2),
    accentDim: Color(0x26268BD2),
    accentGlow: Color(0x4D268BD2),
    statusOnline: Color(0xFF859900),
    statusConnecting: Color(0xFFB58900),
    statusOffline: Color(0xFF586E75),
    statusError: Color(0xFFDC322F),
    terminalBg: Color(0xFF002B36),
    termPrompt: Color(0xFF859900),
    termPath: Color(0xFF268BD2),
    termCommand: Color(0xFF839496),
    termOutput: Color(0xFF93A1A1),
    terminal: TerminalThemes.solarizedDark,
  );

  static const _gruvbox = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF282828),
    bgElevated: Color(0xFF3C3836),
    surface: Color(0xC7504945),
    surfaceSolid: Color(0xFF3C3836),
    cardBg: Color(0xA63C3836),
    navBg: Color(0xB8282828),
    inputBg: Color(0xCC3C3836),
    fg: Color(0xFFEBDBB2),
    fgSecondary: Color(0xFFA89984),
    fgTertiary: Color(0xFF7C6F64),
    tabInactive: Color(0xFF7C6F64),
    border: Color(0x99504945),
    glassBorder: Color(0x14FE8019),
    accent: Color(0xFFFE8019),
    accentDim: Color(0x26FE8019),
    accentGlow: Color(0x4DFE8019),
    statusOnline: Color(0xFFB8BB26),
    statusConnecting: Color(0xFFFABD2F),
    statusOffline: Color(0xFF7C6F64),
    statusError: Color(0xFFFB4934),
    terminalBg: Color(0xFF282828),
    termPrompt: Color(0xFFB8BB26),
    termPath: Color(0xFF83A598),
    termCommand: Color(0xFFEBDBB2),
    termOutput: Color(0xFFA89984),
    terminal: TerminalThemes.gruvbox,
  );

  static const _catppuccinMocha = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF1E1E2E),
    bgElevated: Color(0xFF313244),
    surface: Color(0xC7313244),
    surfaceSolid: Color(0xFF313244),
    cardBg: Color(0xA6313244),
    navBg: Color(0xB81E1E2E),
    inputBg: Color(0xCC313244),
    fg: Color(0xFFCDD6F4),
    fgSecondary: Color(0xFFA6ADC8),
    fgTertiary: Color(0xFF6C7086),
    tabInactive: Color(0xFF6C7086),
    border: Color(0x99585B70),
    glassBorder: Color(0x14CBA6F7),
    accent: Color(0xFFCBA6F7),
    accentDim: Color(0x26CBA6F7),
    accentGlow: Color(0x4DCBA6F7),
    statusOnline: Color(0xFFA6E3A1),
    statusConnecting: Color(0xFFF9E2AF),
    statusOffline: Color(0xFF6C7086),
    statusError: Color(0xFFF38BA8),
    terminalBg: Color(0xFF1E1E2E),
    termPrompt: Color(0xFFA6E3A1),
    termPath: Color(0xFF89B4FA),
    termCommand: Color(0xFFCDD6F4),
    termOutput: Color(0xFFA6ADC8),
    terminal: TerminalThemes.catppuccin,
  );

  // ───────────────────────── Light palettes ─────────────────────────

  static const _solarizedLight = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFFDF6E3),
    bgElevated: Color(0xFFEEE8D5),
    surface: Color(0xC7FDF6E3),
    surfaceSolid: Color(0xFFFDF6E3),
    cardBg: Color(0xA6EEE8D5),
    navBg: Color(0xB8FDF6E3),
    inputBg: Color(0x14000000),
    fg: Color(0xFF586E75),
    fgSecondary: Color(0xFF657B83),
    fgTertiary: Color(0xFF93A1A1),
    tabInactive: Color(0xFF93A1A1),
    border: Color(0x33586E75),
    glassBorder: Color(0x1F268BD2),
    accent: Color(0xFF268BD2),
    accentDim: Color(0x26268BD2),
    accentGlow: Color(0x4D268BD2),
    statusOnline: Color(0xFF859900),
    statusConnecting: Color(0xFFB58900),
    statusOffline: Color(0xFF93A1A1),
    statusError: Color(0xFFDC322F),
    terminalBg: Color(0xFFFDF6E3),
    termPrompt: Color(0xFF859900),
    termPath: Color(0xFF268BD2),
    termCommand: Color(0xFF586E75),
    termOutput: Color(0xFF657B83),
    terminal: TerminalThemes.solarizedLight,
  );

  static const _catppuccinLatte = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFEFF1F5),
    bgElevated: Color(0xFFE6E9EF),
    surface: Color(0xC7DCE0E8),
    surfaceSolid: Color(0xFFE6E9EF),
    cardBg: Color(0xA6E6E9EF),
    navBg: Color(0xB8EFF1F5),
    inputBg: Color(0x14000000),
    fg: Color(0xFF4C4F69),
    fgSecondary: Color(0xFF5C5F77),
    fgTertiary: Color(0xFF9CA0B0),
    tabInactive: Color(0xFF9CA0B0),
    border: Color(0x33ACB0BE),
    glassBorder: Color(0x1F8839EF),
    accent: Color(0xFF8839EF),
    accentDim: Color(0x268839EF),
    accentGlow: Color(0x4D8839EF),
    statusOnline: Color(0xFF40A02B),
    statusConnecting: Color(0xFFDF8E1D),
    statusOffline: Color(0xFF9CA0B0),
    statusError: Color(0xFFD20F39),
    terminalBg: Color(0xFFEFF1F5),
    termPrompt: Color(0xFF40A02B),
    termPath: Color(0xFF1E66F5),
    termCommand: Color(0xFF4C4F69),
    termOutput: Color(0xFF5C5F77),
    terminal: TerminalThemes.catppuccinLatte,
  );

  static const _githubLight = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFFFFFFF),
    bgElevated: Color(0xFFF6F8FA),
    surface: Color(0xC7EAEEF2),
    surfaceSolid: Color(0xFFF6F8FA),
    cardBg: Color(0xA6F6F8FA),
    navBg: Color(0xB8FFFFFF),
    inputBg: Color(0x0A000000),
    fg: Color(0xFF1F2328),
    fgSecondary: Color(0xFF656D76),
    fgTertiary: Color(0xFF8C959F),
    tabInactive: Color(0xFF8C959F),
    border: Color(0x33D0D7DE),
    glassBorder: Color(0x1F0969DA),
    accent: Color(0xFF0969DA),
    accentDim: Color(0x260969DA),
    accentGlow: Color(0x4D0969DA),
    statusOnline: Color(0xFF1A7F37),
    statusConnecting: Color(0xFFBF8700),
    statusOffline: Color(0xFF8C959F),
    statusError: Color(0xFFCF222E),
    terminalBg: Color(0xFFFFFFFF),
    termPrompt: Color(0xFF1A7F37),
    termPath: Color(0xFF0969DA),
    termCommand: Color(0xFF1F2328),
    termOutput: Color(0xFF656D76),
    terminal: TerminalThemes.githubLight,
  );

  static const _rosePineDawn = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFFAF4ED),
    bgElevated: Color(0xFFFFFAF3),
    surface: Color(0xC7F2E9E1),
    surfaceSolid: Color(0xFFFFFAF3),
    cardBg: Color(0xA6FFFAF3),
    navBg: Color(0xB8FAF4ED),
    inputBg: Color(0x14000000),
    fg: Color(0xFF575279),
    fgSecondary: Color(0xFF797593),
    fgTertiary: Color(0xFF9893A5),
    tabInactive: Color(0xFF9893A5),
    border: Color(0x33DFDAD9),
    glassBorder: Color(0x1FB4637A),
    accent: Color(0xFFB4637A),
    accentDim: Color(0x26B4637A),
    accentGlow: Color(0x4DB4637A),
    statusOnline: Color(0xFF286983),
    statusConnecting: Color(0xFFEA9D34),
    statusOffline: Color(0xFF9893A5),
    statusError: Color(0xFFB4637A),
    terminalBg: Color(0xFFFAF4ED),
    termPrompt: Color(0xFF286983),
    termPath: Color(0xFF56949F),
    termCommand: Color(0xFF575279),
    termOutput: Color(0xFF797593),
    terminal: TerminalThemes.rosePineDawn,
  );
}
