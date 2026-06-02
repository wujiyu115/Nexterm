import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:xterm/xterm.dart';

void main() {
  test('copyWith returns a palette with overridden field', () {
    final base = _samplePalette();
    final copy = base.copyWith(accent: const Color(0xFF000000));
    expect(copy.accent, const Color(0xFF000000));
    expect(copy.bg, base.bg); // others unchanged
  });

  test('lerp with t=0 returns this', () {
    final base = _samplePalette();
    expect(base.lerp(null, 1.0), base);
  });
}

ThemePalette _samplePalette() => const ThemePalette(
      brightness: Brightness.dark,
      bg: Color(0xFF000000),
      bgElevated: Color(0xFF111111),
      surface: Color(0xFF222222),
      surfaceSolid: Color(0xFF333333),
      cardBg: Color(0xFF444444),
      navBg: Color(0xFF555555),
      inputBg: Color(0xFF666666),
      fg: Color(0xFFFFFFFF),
      fgSecondary: Color(0xFFEEEEEE),
      fgTertiary: Color(0xFFCCCCCC),
      tabInactive: Color(0xFF888888),
      border: Color(0xFF222222),
      glassBorder: Color(0xFF111111),
      accent: Color(0xFF5CB85C),
      accentDim: Color(0x265CB85C),
      accentGlow: Color(0x4D5CB85C),
      statusOnline: Color(0xFF3FB950),
      statusConnecting: Color(0xFFD29922),
      statusOffline: Color(0xFF484F58),
      statusError: Color(0xFFF85149),
      terminalBg: Color(0xFF000000),
      termPrompt: Color(0xFF5CB85C),
      termPath: Color(0xFF89B4FA),
      termCommand: Color(0xFFCDD6F4),
      termOutput: Color(0xFF8B949E),
      terminal: TerminalTheme(
        cursor: Color(0xFFFFFFFF),
        selection: Color(0x66888888),
        foreground: Color(0xFFFFFFFF),
        background: Color(0xFF000000),
        black: Color(0xFF000000),
        red: Color(0xFFFF0000),
        green: Color(0xFF00FF00),
        yellow: Color(0xFFFFFF00),
        blue: Color(0xFF0000FF),
        magenta: Color(0xFFFF00FF),
        cyan: Color(0xFF00FFFF),
        white: Color(0xFFFFFFFF),
        brightBlack: Color(0xFF000000),
        brightRed: Color(0xFFFF0000),
        brightGreen: Color(0xFF00FF00),
        brightYellow: Color(0xFFFFFF00),
        brightBlue: Color(0xFF0000FF),
        brightMagenta: Color(0xFFFF00FF),
        brightCyan: Color(0xFF00FFFF),
        brightWhite: Color(0xFFFFFFFF),
        searchHitBackground: Color(0xFFFFFF00),
        searchHitBackgroundCurrent: Color(0xFF00FF00),
        searchHitForeground: Color(0xFF000000),
      ),
    );
