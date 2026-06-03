import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

@immutable
class ThemePalette extends ThemeExtension<ThemePalette> {
  final Brightness brightness;

  // Surfaces
  final Color bg;
  final Color bgElevated;
  final Color surface;
  final Color surfaceSolid;
  final Color cardBg;
  final Color navBg;
  final Color inputBg;

  // Foregrounds
  final Color fg;
  final Color fgSecondary;
  final Color fgTertiary;
  final Color tabInactive;

  // Borders
  final Color border;
  final Color glassBorder;

  // Accent
  final Color accent;
  final Color accentDim;
  final Color accentGlow;

  // Status
  final Color statusOnline;
  final Color statusConnecting;
  final Color statusOffline;
  final Color statusError;

  // Terminal helpers (UI text styled like a terminal prompt)
  final Color terminalBg;
  final Color termPrompt;
  final Color termPath;
  final Color termCommand;
  final Color termOutput;

  // Bundled xterm theme
  final TerminalTheme terminal;

  const ThemePalette({
    required this.brightness,
    required this.bg,
    required this.bgElevated,
    required this.surface,
    required this.surfaceSolid,
    required this.cardBg,
    required this.navBg,
    required this.inputBg,
    required this.fg,
    required this.fgSecondary,
    required this.fgTertiary,
    required this.tabInactive,
    required this.border,
    required this.glassBorder,
    required this.accent,
    required this.accentDim,
    required this.accentGlow,
    required this.statusOnline,
    required this.statusConnecting,
    required this.statusOffline,
    required this.statusError,
    required this.terminalBg,
    required this.termPrompt,
    required this.termPath,
    required this.termCommand,
    required this.termOutput,
    required this.terminal,
  });

  @override
  ThemePalette copyWith({
    Brightness? brightness,
    Color? bg,
    Color? bgElevated,
    Color? surface,
    Color? surfaceSolid,
    Color? cardBg,
    Color? navBg,
    Color? inputBg,
    Color? fg,
    Color? fgSecondary,
    Color? fgTertiary,
    Color? tabInactive,
    Color? border,
    Color? glassBorder,
    Color? accent,
    Color? accentDim,
    Color? accentGlow,
    Color? statusOnline,
    Color? statusConnecting,
    Color? statusOffline,
    Color? statusError,
    Color? terminalBg,
    Color? termPrompt,
    Color? termPath,
    Color? termCommand,
    Color? termOutput,
    TerminalTheme? terminal,
  }) {
    return ThemePalette(
      brightness: brightness ?? this.brightness,
      bg: bg ?? this.bg,
      bgElevated: bgElevated ?? this.bgElevated,
      surface: surface ?? this.surface,
      surfaceSolid: surfaceSolid ?? this.surfaceSolid,
      cardBg: cardBg ?? this.cardBg,
      navBg: navBg ?? this.navBg,
      inputBg: inputBg ?? this.inputBg,
      fg: fg ?? this.fg,
      fgSecondary: fgSecondary ?? this.fgSecondary,
      fgTertiary: fgTertiary ?? this.fgTertiary,
      tabInactive: tabInactive ?? this.tabInactive,
      border: border ?? this.border,
      glassBorder: glassBorder ?? this.glassBorder,
      accent: accent ?? this.accent,
      accentDim: accentDim ?? this.accentDim,
      accentGlow: accentGlow ?? this.accentGlow,
      statusOnline: statusOnline ?? this.statusOnline,
      statusConnecting: statusConnecting ?? this.statusConnecting,
      statusOffline: statusOffline ?? this.statusOffline,
      statusError: statusError ?? this.statusError,
      terminalBg: terminalBg ?? this.terminalBg,
      termPrompt: termPrompt ?? this.termPrompt,
      termPath: termPath ?? this.termPath,
      termCommand: termCommand ?? this.termCommand,
      termOutput: termOutput ?? this.termOutput,
      terminal: terminal ?? this.terminal,
    );
  }

  /// We don't animate between themes — return self.
  @override
  ThemePalette lerp(ThemeExtension<ThemePalette>? other, double t) => this;
}
