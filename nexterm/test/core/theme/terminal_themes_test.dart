import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/core/theme/terminal_themes.dart';

void main() {
  group('TerminalThemes', () {
    test('all map has 9 entries (monokai dropped)', () {
      expect(TerminalThemes.all.length, 9);
      expect(TerminalThemes.all.containsKey('monokai'), false);
    });

    test('byName falls back to catppuccin for unknown', () {
      expect(TerminalThemes.byName('monokai'), TerminalThemes.catppuccin);
      expect(TerminalThemes.byName('does-not-exist'), TerminalThemes.catppuccin);
    });

    test('5 new themes are present and have correct backgrounds', () {
      expect(TerminalThemes.nord.background, const Color(0xFF2E3440));
      expect(TerminalThemes.gruvbox.background, const Color(0xFF282828));
      expect(TerminalThemes.catppuccinLatte.background, const Color(0xFFEFF1F5));
      expect(TerminalThemes.githubLight.background, const Color(0xFFFFFFFF));
      expect(TerminalThemes.rosePineDawn.background, const Color(0xFFFAF4ED));
    });
  });
}
