import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/core/theme/theme_catalog.dart';

void main() {
  group('ThemeCatalog', () {
    test('exposes 10 themes', () {
      expect(ThemeCatalog.all.length, 10);
    });

    test('byKey returns nexterm fallback for unknown key', () {
      expect(ThemeCatalog.byKey('does-not-exist').accent,
          ThemeCatalog.byKey('nexterm').accent);
    });

    test('nexterm is dark with green accent', () {
      final p = ThemeCatalog.byKey('nexterm');
      expect(p.brightness, Brightness.dark);
      expect(p.accent, const Color(0xFF5CB85C));
    });

    test('solarized-light is light brightness', () {
      expect(
          ThemeCatalog.byKey('solarized-light').brightness, Brightness.light);
    });

    test('all light themes have Brightness.light', () {
      const lightKeys = [
        'solarized-light',
        'catppuccin-latte',
        'github-light',
        'rose-pine-dawn',
      ];
      for (final k in lightKeys) {
        expect(ThemeCatalog.byKey(k).brightness, Brightness.light, reason: k);
      }
    });

    test('all dark themes have Brightness.dark', () {
      const darkKeys = [
        'nexterm',
        'dracula',
        'nord',
        'solarized-dark',
        'gruvbox',
        'catppuccin-mocha',
      ];
      for (final k in darkKeys) {
        expect(ThemeCatalog.byKey(k).brightness, Brightness.dark, reason: k);
      }
    });
  });

  group('legacyThemeNameMap', () {
    test('maps legacy terminal_theme keys to new theme keys', () {
      expect(ThemeCatalog.mapLegacy('catppuccin'), 'catppuccin-mocha');
      expect(ThemeCatalog.mapLegacy('dracula'), 'dracula');
      expect(ThemeCatalog.mapLegacy('solarized-dark'), 'solarized-dark');
      expect(ThemeCatalog.mapLegacy('solarized-light'), 'solarized-light');
      expect(ThemeCatalog.mapLegacy('monokai'), 'nexterm'); // monokai dropped
      expect(ThemeCatalog.mapLegacy('unknown'), 'nexterm');
      expect(ThemeCatalog.mapLegacy(''), 'nexterm');
    });
  });
}
