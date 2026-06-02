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

    test('darkKeys + lightKeys partition all', () {
      final union = {...ThemeCatalog.darkKeys, ...ThemeCatalog.lightKeys};
      expect(union, equals(ThemeCatalog.all.keys.toSet()));
      final intersection = ThemeCatalog.darkKeys.toSet()
          .intersection(ThemeCatalog.lightKeys.toSet());
      expect(intersection, isEmpty);
    });

    test('every key in darkKeys resolves to a dark palette', () {
      for (final k in ThemeCatalog.darkKeys) {
        expect(ThemeCatalog.byKey(k).brightness, Brightness.dark, reason: k);
      }
    });

    test('every key in lightKeys resolves to a light palette', () {
      for (final k in ThemeCatalog.lightKeys) {
        expect(ThemeCatalog.byKey(k).brightness, Brightness.light, reason: k);
      }
    });

    test('every key in all has a non-fallback display name', () {
      for (final k in ThemeCatalog.all.keys) {
        expect(ThemeCatalog.displayName(k), isNot(equals(k)),
            reason: 'displayName fallback for $k means localization is broken');
      }
    });
  });

  group('ThemeCatalog.mapLegacy', () {
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
