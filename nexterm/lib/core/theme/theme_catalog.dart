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
    'one-dark': _oneDark,
    'tokyo-night': _tokyoNight,
    'monokai': _monokai,
    'everforest-dark': _everforestDark,
    'kanagawa': _kanagawa,
    'ayu-dark': _ayuDark,
    'solarized-light': _solarizedLight,
    'catppuccin-latte': _catppuccinLatte,
    'github-light': _githubLight,
    'rose-pine-dawn': _rosePineDawn,
    'one-light': _oneLight,
    'tokyo-night-light': _tokyoNightLight,
    'everforest-light': _everforestLight,
    'ayu-light': _ayuLight,
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
      case 'one-dark':
        return 'One Dark';
      case 'tokyo-night':
        return 'Tokyo Night';
      case 'monokai':
        return 'Monokai';
      case 'everforest-dark':
        return 'Everforest Dark';
      case 'kanagawa':
        return 'Kanagawa';
      case 'ayu-dark':
        return 'Ayu Dark';
      case 'one-light':
        return 'One Light';
      case 'tokyo-night-light':
        return 'Tokyo Night Light';
      case 'everforest-light':
        return 'Everforest Light';
      case 'ayu-light':
        return 'Ayu Light';
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
    'one-dark',
    'tokyo-night',
    'monokai',
    'everforest-dark',
    'kanagawa',
    'ayu-dark',
  ];

  static const List<String> lightKeys = [
    'solarized-light',
    'catppuccin-latte',
    'github-light',
    'rose-pine-dawn',
    'one-light',
    'tokyo-night-light',
    'everforest-light',
    'ayu-light',
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

  static const _oneDark = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF282C34),
    bgElevated: Color(0xFF21252B),
    surface: Color(0xC72C313A),
    surfaceSolid: Color(0xFF2C313A),
    cardBg: Color(0xA62C313A),
    navBg: Color(0xB8282C34),
    inputBg: Color(0xCC2C313A),
    fg: Color(0xFFABB2BF),
    fgSecondary: Color(0xFF7F848E),
    fgTertiary: Color(0xFF5C6370),
    tabInactive: Color(0xFF5C6370),
    border: Color(0x99454951),
    glassBorder: Color(0x1461AFEF),
    accent: Color(0xFF61AFEF),
    accentDim: Color(0x2661AFEF),
    accentGlow: Color(0x4D61AFEF),
    statusOnline: Color(0xFF98C379),
    statusConnecting: Color(0xFFE5C07B),
    statusOffline: Color(0xFF5C6370),
    statusError: Color(0xFFE06C75),
    terminalBg: Color(0xFF282C34),
    termPrompt: Color(0xFF98C379),
    termPath: Color(0xFF61AFEF),
    termCommand: Color(0xFFABB2BF),
    termOutput: Color(0xFF7F848E),
    terminal: TerminalThemes.oneDark,
  );

  static const _tokyoNight = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF1A1B26),
    bgElevated: Color(0xFF24283B),
    surface: Color(0xC724283B),
    surfaceSolid: Color(0xFF24283B),
    cardBg: Color(0xA624283B),
    navBg: Color(0xB81A1B26),
    inputBg: Color(0xCC24283B),
    fg: Color(0xFFC0CAF5),
    fgSecondary: Color(0xFFA9B1D6),
    fgTertiary: Color(0xFF565F89),
    tabInactive: Color(0xFF565F89),
    border: Color(0x99414868),
    glassBorder: Color(0x147AA2F7),
    accent: Color(0xFF7AA2F7),
    accentDim: Color(0x267AA2F7),
    accentGlow: Color(0x4D7AA2F7),
    statusOnline: Color(0xFF9ECE6A),
    statusConnecting: Color(0xFFE0AF68),
    statusOffline: Color(0xFF565F89),
    statusError: Color(0xFFF7768E),
    terminalBg: Color(0xFF1A1B26),
    termPrompt: Color(0xFF9ECE6A),
    termPath: Color(0xFF7AA2F7),
    termCommand: Color(0xFFC0CAF5),
    termOutput: Color(0xFFA9B1D6),
    terminal: TerminalThemes.tokyoNight,
  );

  static const _monokai = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF272822),
    bgElevated: Color(0xFF2D2E27),
    surface: Color(0xC73E3D32),
    surfaceSolid: Color(0xFF3E3D32),
    cardBg: Color(0xA63E3D32),
    navBg: Color(0xB8272822),
    inputBg: Color(0xCC3E3D32),
    fg: Color(0xFFF8F8F2),
    fgSecondary: Color(0xFFA59F85),
    fgTertiary: Color(0xFF75715E),
    tabInactive: Color(0xFF75715E),
    border: Color(0x9949483E),
    glassBorder: Color(0x14A6E22E),
    accent: Color(0xFFA6E22E),
    accentDim: Color(0x26A6E22E),
    accentGlow: Color(0x4DA6E22E),
    statusOnline: Color(0xFFA6E22E),
    statusConnecting: Color(0xFFF4BF75),
    statusOffline: Color(0xFF75715E),
    statusError: Color(0xFFF92672),
    terminalBg: Color(0xFF272822),
    termPrompt: Color(0xFFA6E22E),
    termPath: Color(0xFF66D9EF),
    termCommand: Color(0xFFF8F8F2),
    termOutput: Color(0xFFA59F85),
    terminal: TerminalThemes.monokai,
  );

  static const _everforestDark = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF2D353B),
    bgElevated: Color(0xFF343F44),
    surface: Color(0xC7343F44),
    surfaceSolid: Color(0xFF343F44),
    cardBg: Color(0xA6343F44),
    navBg: Color(0xB82D353B),
    inputBg: Color(0xCC3D484D),
    fg: Color(0xFFD3C6AA),
    fgSecondary: Color(0xFF9DA9A0),
    fgTertiary: Color(0xFF859289),
    tabInactive: Color(0xFF859289),
    border: Color(0x99475258),
    glassBorder: Color(0x14A7C080),
    accent: Color(0xFFA7C080),
    accentDim: Color(0x26A7C080),
    accentGlow: Color(0x4DA7C080),
    statusOnline: Color(0xFFA7C080),
    statusConnecting: Color(0xFFDBBC7F),
    statusOffline: Color(0xFF859289),
    statusError: Color(0xFFE67E80),
    terminalBg: Color(0xFF2D353B),
    termPrompt: Color(0xFFA7C080),
    termPath: Color(0xFF7FBBB3),
    termCommand: Color(0xFFD3C6AA),
    termOutput: Color(0xFF9DA9A0),
    terminal: TerminalThemes.everforestDark,
  );

  static const _kanagawa = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF1F1F28),
    bgElevated: Color(0xFF2A2A37),
    surface: Color(0xC72A2A37),
    surfaceSolid: Color(0xFF2A2A37),
    cardBg: Color(0xA62A2A37),
    navBg: Color(0xB81F1F28),
    inputBg: Color(0xCC2A2A37),
    fg: Color(0xFFDCD7BA),
    fgSecondary: Color(0xFFC8C093),
    fgTertiary: Color(0xFF727169),
    tabInactive: Color(0xFF727169),
    border: Color(0x9954546D),
    glassBorder: Color(0x147E9CD8),
    accent: Color(0xFF7E9CD8),
    accentDim: Color(0x267E9CD8),
    accentGlow: Color(0x4D7E9CD8),
    statusOnline: Color(0xFF76946A),
    statusConnecting: Color(0xFFC0A36E),
    statusOffline: Color(0xFF727169),
    statusError: Color(0xFFC34043),
    terminalBg: Color(0xFF1F1F28),
    termPrompt: Color(0xFF98BB6C),
    termPath: Color(0xFF7E9CD8),
    termCommand: Color(0xFFDCD7BA),
    termOutput: Color(0xFFC8C093),
    terminal: TerminalThemes.kanagawa,
  );

  static const _ayuDark = ThemePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF0D1017),
    bgElevated: Color(0xFF131721),
    surface: Color(0xC7131721),
    surfaceSolid: Color(0xFF131721),
    cardBg: Color(0xA6131721),
    navBg: Color(0xB80D1017),
    inputBg: Color(0xCC1A1F29),
    fg: Color(0xFFBFBDB6),
    fgSecondary: Color(0xFF858B91),
    fgTertiary: Color(0xFF626A73),
    tabInactive: Color(0xFF626A73),
    border: Color(0x99304357),
    glassBorder: Color(0x14E6B450),
    accent: Color(0xFFE6B450),
    accentDim: Color(0x26E6B450),
    accentGlow: Color(0x4DE6B450),
    statusOnline: Color(0xFFAAD94C),
    statusConnecting: Color(0xFFE6B450),
    statusOffline: Color(0xFF626A73),
    statusError: Color(0xFFF07178),
    terminalBg: Color(0xFF0D1017),
    termPrompt: Color(0xFFAAD94C),
    termPath: Color(0xFF59C2FF),
    termCommand: Color(0xFFBFBDB6),
    termOutput: Color(0xFF858B91),
    terminal: TerminalThemes.ayuDark,
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

  static const _oneLight = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFFAFAFA),
    bgElevated: Color(0xFFFFFFFF),
    surface: Color(0xC7E5E5E6),
    surfaceSolid: Color(0xFFF0F0F1),
    cardBg: Color(0xA6F0F0F1),
    navBg: Color(0xB8FAFAFA),
    inputBg: Color(0x0A000000),
    fg: Color(0xFF383A42),
    fgSecondary: Color(0xFF696C77),
    fgTertiary: Color(0xFFA0A1A7),
    tabInactive: Color(0xFFA0A1A7),
    border: Color(0x33D4D4D5),
    glassBorder: Color(0x1F4078F2),
    accent: Color(0xFF4078F2),
    accentDim: Color(0x264078F2),
    accentGlow: Color(0x4D4078F2),
    statusOnline: Color(0xFF50A14F),
    statusConnecting: Color(0xFFC18401),
    statusOffline: Color(0xFFA0A1A7),
    statusError: Color(0xFFE45649),
    terminalBg: Color(0xFFFAFAFA),
    termPrompt: Color(0xFF50A14F),
    termPath: Color(0xFF4078F2),
    termCommand: Color(0xFF383A42),
    termOutput: Color(0xFF696C77),
    terminal: TerminalThemes.oneLight,
  );

  static const _tokyoNightLight = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFD5D6DB),
    bgElevated: Color(0xFFE1E2E7),
    surface: Color(0xC7D5D6DB),
    surfaceSolid: Color(0xFFE1E2E7),
    cardBg: Color(0xA6E1E2E7),
    navBg: Color(0xB8D5D6DB),
    inputBg: Color(0x0A000000),
    fg: Color(0xFF3760BF),
    fgSecondary: Color(0xFF6172B0),
    fgTertiary: Color(0xFFA1A6C5),
    tabInactive: Color(0xFFA1A6C5),
    border: Color(0x33B4B5B9),
    glassBorder: Color(0x1F2E7DE9),
    accent: Color(0xFF2E7DE9),
    accentDim: Color(0x262E7DE9),
    accentGlow: Color(0x4D2E7DE9),
    statusOnline: Color(0xFF587539),
    statusConnecting: Color(0xFF8C6C3E),
    statusOffline: Color(0xFFA1A6C5),
    statusError: Color(0xFFF52A65),
    terminalBg: Color(0xFFD5D6DB),
    termPrompt: Color(0xFF587539),
    termPath: Color(0xFF2E7DE9),
    termCommand: Color(0xFF3760BF),
    termOutput: Color(0xFF6172B0),
    terminal: TerminalThemes.tokyoNightLight,
  );

  static const _everforestLight = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFFDF6E3),
    bgElevated: Color(0xFFF4F0D9),
    surface: Color(0xC7E5DFC5),
    surfaceSolid: Color(0xFFF4F0D9),
    cardBg: Color(0xA6F4F0D9),
    navBg: Color(0xB8FDF6E3),
    inputBg: Color(0x0A000000),
    fg: Color(0xFF5C6A72),
    fgSecondary: Color(0xFF829181),
    fgTertiary: Color(0xFF939F91),
    tabInactive: Color(0xFF939F91),
    border: Color(0x33D5CEB6),
    glassBorder: Color(0x1F8DA101),
    accent: Color(0xFF8DA101),
    accentDim: Color(0x268DA101),
    accentGlow: Color(0x4D8DA101),
    statusOnline: Color(0xFF8DA101),
    statusConnecting: Color(0xFFDFA000),
    statusOffline: Color(0xFF939F91),
    statusError: Color(0xFFF85552),
    terminalBg: Color(0xFFFDF6E3),
    termPrompt: Color(0xFF8DA101),
    termPath: Color(0xFF3A94C5),
    termCommand: Color(0xFF5C6A72),
    termOutput: Color(0xFF829181),
    terminal: TerminalThemes.everforestLight,
  );

  static const _ayuLight = ThemePalette(
    brightness: Brightness.light,
    bg: Color(0xFFFAFAFA),
    bgElevated: Color(0xFFFFFFFF),
    surface: Color(0xC7F0F0F0),
    surfaceSolid: Color(0xFFF8F8F8),
    cardBg: Color(0xA6F8F8F8),
    navBg: Color(0xB8FAFAFA),
    inputBg: Color(0x0A000000),
    fg: Color(0xFF575F66),
    fgSecondary: Color(0xFF828C99),
    fgTertiary: Color(0xFFABB0B6),
    tabInactive: Color(0xFFABB0B6),
    border: Color(0x33D8D8D8),
    glassBorder: Color(0x1FFF9940),
    accent: Color(0xFFFF9940),
    accentDim: Color(0x26FF9940),
    accentGlow: Color(0x4DFF9940),
    statusOnline: Color(0xFF86B300),
    statusConnecting: Color(0xFFF2AE49),
    statusOffline: Color(0xFFABB0B6),
    statusError: Color(0xFFF07171),
    terminalBg: Color(0xFFFAFAFA),
    termPrompt: Color(0xFF86B300),
    termPath: Color(0xFF399EE6),
    termCommand: Color(0xFF575F66),
    termOutput: Color(0xFF828C99),
    terminal: TerminalThemes.ayuLight,
  );
}
