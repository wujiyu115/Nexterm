import 'package:flutter/widgets.dart';
import 'package:xterm/xterm.dart';

/// Named terminal color schemes for the xterm.dart TerminalView widget.
///
/// Uses [Color] from flutter/widgets.dart (dart:ui Color), matching xterm's API.
class TerminalThemes {
  /// Catppuccin Mocha — default dark theme.
  static const catppuccin = TerminalTheme(
    cursor: Color(0xFFF5E0DC),
    selection: Color(0x66CBA6F7),
    foreground: Color(0xFFCDD6F4),
    background: Color(0xFF1E1E2E),
    black: Color(0xFF45475A),
    red: Color(0xFFF38BA8),
    green: Color(0xFFA6E3A1),
    yellow: Color(0xFFF9E2AF),
    blue: Color(0xFF89B4FA),
    magenta: Color(0xFFCBA6F7),
    cyan: Color(0xFF94E2D5),
    white: Color(0xFFBAC2DE),
    brightBlack: Color(0xFF585B70),
    brightRed: Color(0xFFF38BA8),
    brightGreen: Color(0xFFA6E3A1),
    brightYellow: Color(0xFFF9E2AF),
    brightBlue: Color(0xFF89B4FA),
    brightMagenta: Color(0xFFCBA6F7),
    brightCyan: Color(0xFF94E2D5),
    brightWhite: Color(0xFFA6ADC8),
    searchHitBackground: Color(0xFFF9E2AF),
    searchHitBackgroundCurrent: Color(0xFFA6E3A1),
    searchHitForeground: Color(0xFF1E1E2E),
  );

  /// Dracula theme.
  static const dracula = TerminalTheme(
    cursor: Color(0xFFF8F8F2),
    selection: Color(0x66BD93F9),
    foreground: Color(0xFFF8F8F2),
    background: Color(0xFF282A36),
    black: Color(0xFF21222C),
    red: Color(0xFFFF5555),
    green: Color(0xFF50FA7B),
    yellow: Color(0xFFF1FA8C),
    blue: Color(0xFFBD93F9),
    magenta: Color(0xFFFF79C6),
    cyan: Color(0xFF8BE9FD),
    white: Color(0xFFBFBFBF),
    brightBlack: Color(0xFF6272A4),
    brightRed: Color(0xFFFF6E6E),
    brightGreen: Color(0xFF69FF94),
    brightYellow: Color(0xFFFFFFA5),
    brightBlue: Color(0xFFD6ACFF),
    brightMagenta: Color(0xFFFF92DF),
    brightCyan: Color(0xFFA4FFFF),
    brightWhite: Color(0xFFFFFFFF),
    searchHitBackground: Color(0xFFF1FA8C),
    searchHitBackgroundCurrent: Color(0xFF50FA7B),
    searchHitForeground: Color(0xFF282A36),
  );

  /// Monokai theme.
  static const monokai = TerminalTheme(
    cursor: Color(0xFFF8F8F2),
    selection: Color(0x66A6E22E),
    foreground: Color(0xFFF8F8F2),
    background: Color(0xFF272822),
    black: Color(0xFF272822),
    red: Color(0xFFF92672),
    green: Color(0xFFA6E22E),
    yellow: Color(0xFFE6DB74),
    blue: Color(0xFF66D9EF),
    magenta: Color(0xFFAE81FF),
    cyan: Color(0xFFA1EFE4),
    white: Color(0xFFF8F8F2),
    brightBlack: Color(0xFF75715E),
    brightRed: Color(0xFFF92672),
    brightGreen: Color(0xFFA6E22E),
    brightYellow: Color(0xFFE6DB74),
    brightBlue: Color(0xFF66D9EF),
    brightMagenta: Color(0xFFAE81FF),
    brightCyan: Color(0xFFA1EFE4),
    brightWhite: Color(0xFFF9F8F5),
    searchHitBackground: Color(0xFFE6DB74),
    searchHitBackgroundCurrent: Color(0xFFA6E22E),
    searchHitForeground: Color(0xFF272822),
  );

  /// Solarized Dark theme.
  static const solarizedDark = TerminalTheme(
    cursor: Color(0xFF839496),
    selection: Color(0x66268BD2),
    foreground: Color(0xFF839496),
    background: Color(0xFF002B36),
    black: Color(0xFF073642),
    red: Color(0xFFDC322F),
    green: Color(0xFF859900),
    yellow: Color(0xFFB58900),
    blue: Color(0xFF268BD2),
    magenta: Color(0xFFD33682),
    cyan: Color(0xFF2AA198),
    white: Color(0xFFEEE8D5),
    brightBlack: Color(0xFF002B36),
    brightRed: Color(0xFFCB4B16),
    brightGreen: Color(0xFF586E75),
    brightYellow: Color(0xFF657B83),
    brightBlue: Color(0xFF839496),
    brightMagenta: Color(0xFF6C71C4),
    brightCyan: Color(0xFF93A1A1),
    brightWhite: Color(0xFFFDF6E3),
    searchHitBackground: Color(0xFFB58900),
    searchHitBackgroundCurrent: Color(0xFF859900),
    searchHitForeground: Color(0xFF002B36),
  );

  /// Solarized Light theme.
  static const solarizedLight = TerminalTheme(
    cursor: Color(0xFF586E75),
    selection: Color(0x66268BD2),
    foreground: Color(0xFF657B83),
    background: Color(0xFFFDF6E3),
    black: Color(0xFFEEE8D5),
    red: Color(0xFFDC322F),
    green: Color(0xFF859900),
    yellow: Color(0xFFB58900),
    blue: Color(0xFF268BD2),
    magenta: Color(0xFFD33682),
    cyan: Color(0xFF2AA198),
    white: Color(0xFF073642),
    brightBlack: Color(0xFFFDF6E3),
    brightRed: Color(0xFFCB4B16),
    brightGreen: Color(0xFF93A1A1),
    brightYellow: Color(0xFF839496),
    brightBlue: Color(0xFF657B83),
    brightMagenta: Color(0xFF6C71C4),
    brightCyan: Color(0xFF586E75),
    brightWhite: Color(0xFF002B36),
    searchHitBackground: Color(0xFFB58900),
    searchHitBackgroundCurrent: Color(0xFF859900),
    searchHitForeground: Color(0xFFFDF6E3),
  );

  /// Map of all available terminal themes by name.
  static const Map<String, TerminalTheme> all = {
    'catppuccin': catppuccin,
    'dracula': dracula,
    'monokai': monokai,
    'solarized-dark': solarizedDark,
    'solarized-light': solarizedLight,
  };

  /// Returns the theme for [name], falling back to [catppuccin] if not found.
  static TerminalTheme byName(String name) {
    return all[name] ?? catppuccin;
  }
}
