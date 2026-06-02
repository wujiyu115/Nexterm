# Unified Theming (Moshi-Style) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Collapse the App's two independent theme settings (Light/Dark/System + terminal palette) into a single 10-theme picker that drives terminal colors, App brightness, surface colors, and accent simultaneously.

**Architecture:** A `ThemePalette extends ThemeExtension<ThemePalette>` carries every color the App reads. A `ThemeCatalog` of 10 named palettes is keyed by theme name. `paletteProvider` watches a single `theme_name` setting and returns the active palette. `AppTheme.fromPalette()` builds the `ThemeData` with `colorScheme` derived from palette + extension list `[palette]`. The 50 widget files that hardcode `OutdoorColors.X` migrate to `Theme.of(context).extension<ThemePalette>()!.X`. `OutdoorColors`'s color fields are deleted (radius constants stay).

**Tech Stack:** Flutter, Riverpod, xterm.dart, Drift (settings DB).

---

## Source spec

[docs/superpowers/specs/2026-06-02-unified-theming-design.md](../specs/2026-06-02-unified-theming-design.md)

## File structure

**New files (3):**
- `nexterm/lib/core/theme/theme_palette.dart` — `ThemePalette` data class (`ThemeExtension`)
- `nexterm/lib/core/theme/theme_catalog.dart` — 10 `ThemePalette` instances keyed by theme name + lookup helpers + legacy mapping
- `nexterm/test/core/theme/theme_catalog_test.dart` — unit tests for catalog + legacy mapping

**Modified files (≈55):**
- `nexterm/lib/core/theme/theme_provider.dart` — collapse `ThemeState` to `String`
- `nexterm/lib/core/theme/app_theme.dart` — replace `light()/dark()` with `fromPalette()`
- `nexterm/lib/core/theme/outdoor_colors.dart` — remove color fields, keep radius constants
- `nexterm/lib/core/theme/terminal_themes.dart` — drop `monokai`, add `nord/gruvbox/catppuccinLatte/githubLight/rosePineDawn`
- `nexterm/lib/app.dart` — switch `MaterialApp.router` wiring
- `nexterm/lib/features/settings/providers/settings_provider.dart` — add `themeName` key, drop `theme/terminalTheme`
- `nexterm/lib/features/settings/ui/settings_screen.dart` — replace App-theme + terminal-theme pickers with single picker
- `nexterm/lib/l10n/app_en.arb` + `app_zh.arb` — add `settings_themeGroupDark/Light`, drop obsolete keys
- The 50 files listed in the migration tasks (Tasks 6.1–6.9)

## Migration recipe (referenced by Tasks 6.1 – 6.9)

For every file that imports `OutdoorColors`:

1. **Add import** at top:
   ```dart
   import 'package:nexterm/core/theme/theme_palette.dart';
   ```
2. **Inside any `Widget build(BuildContext context, ...)` or method receiving `BuildContext`** — add at the very top of the function body:
   ```dart
   final p = Theme.of(context).extension<ThemePalette>()!;
   ```
3. **Substitute references**, applying these mappings (the palette already encodes brightness, so dark/light pairs collapse):

   | Before | After |
   |---|---|
   | `OutdoorColors.darkBg` / `OutdoorColors.lightBg` | `p.bg` |
   | `OutdoorColors.darkBgElevated` / `OutdoorColors.lightBgElevated` | `p.bgElevated` |
   | `OutdoorColors.darkSurface` / `OutdoorColors.lightSurface` | `p.surface` |
   | `OutdoorColors.darkSurfaceSolid` / `OutdoorColors.lightSurfaceSolid` | `p.surfaceSolid` |
   | `OutdoorColors.darkFg` / `OutdoorColors.lightFg` | `p.fg` |
   | `OutdoorColors.darkFgSecondary` / `OutdoorColors.lightFgSecondary` | `p.fgSecondary` |
   | `OutdoorColors.darkFgTertiary` / `OutdoorColors.lightFgTertiary` | `p.fgTertiary` |
   | `OutdoorColors.darkBorder` / `OutdoorColors.lightBorder` | `p.border` |
   | `OutdoorColors.darkNavBg` / `OutdoorColors.lightNavBg` | `p.navBg` |
   | `OutdoorColors.darkCardBg` / `OutdoorColors.lightCardBg` | `p.cardBg` |
   | `OutdoorColors.darkInputBg` / `OutdoorColors.lightInputBg` | `p.inputBg` |
   | `OutdoorColors.darkTabInactive` / `OutdoorColors.lightTabInactive` | `p.tabInactive` |
   | `OutdoorColors.darkStatusOnline` / `OutdoorColors.lightStatusOnline` | `p.statusOnline` |
   | `OutdoorColors.darkStatusConnecting` / `OutdoorColors.lightStatusConnecting` | `p.statusConnecting` |
   | `OutdoorColors.darkStatusOffline` / `OutdoorColors.lightStatusOffline` | `p.statusOffline` |
   | `OutdoorColors.darkStatusError` / `OutdoorColors.lightStatusError` | `p.statusError` |
   | `OutdoorColors.darkTerminalBg` / `OutdoorColors.lightTerminalBg` | `p.terminalBg` |
   | `OutdoorColors.darkGlassBorder` / `OutdoorColors.lightGlassBorder` | `p.glassBorder` |
   | `OutdoorColors.accent` | `p.accent` |
   | `OutdoorColors.accentDim` | `p.accentDim` |
   | `OutdoorColors.accentGlow` | `p.accentGlow` |
   | `OutdoorColors.termPrompt` | `p.termPrompt` |
   | `OutdoorColors.termPath` | `p.termPath` |
   | `OutdoorColors.termCommand` | `p.termCommand` |
   | `OutdoorColors.termOutput` | `p.termOutput` |
   | `OutdoorColors.radiusLg/Md/Sm` | **leave unchanged** (radius constants stay) |

4. **Drop `const` from any constructor call that now contains a non-const expression.** The Flutter analyzer will pinpoint each one — fix as it complains. Example:
   ```dart
   // before
   side: const BorderSide(color: OutdoorColors.lightBorder, width: 0.5),
   // after
   side: BorderSide(color: p.border, width: 0.5),
   ```
5. **`isDark` ternaries collapse:**
   ```dart
   final isDark = Theme.of(context).brightness == Brightness.dark;
   final color = isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg;
   // becomes
   final color = p.bg;
   ```
   The `isDark` local can usually be removed (search the rest of the function for other uses first).
6. **For `static const` or top-level helpers** that read `OutdoorColors` outside a `BuildContext` (rare — flag during migration): convert into a function `static Color X(ThemePalette p) => ...`. The audit finds none of these in the 50 files except `AppTheme.onlineGreen / errorRed / warningYellow` which are already deleted in Task 4.

After every batch: run `flutter analyze` and ensure 0 issues before committing.

---

## Task 1: Create `ThemePalette` data class

**Files:**
- Create: `nexterm/lib/core/theme/theme_palette.dart`
- Test: `nexterm/test/core/theme/theme_palette_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// nexterm/test/core/theme/theme_palette_test.dart
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
      accentDim: Color(0xFF265CB85C),
      accentGlow: Color(0xFF4D5CB85C),
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
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd nexterm && flutter test test/core/theme/theme_palette_test.dart
```
Expected: FAIL — `theme_palette.dart` doesn't exist yet.

- [ ] **Step 3: Implement `ThemePalette`**

```dart
// nexterm/lib/core/theme/theme_palette.dart
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd nexterm && flutter test test/core/theme/theme_palette_test.dart
```
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add nexterm/lib/core/theme/theme_palette.dart nexterm/test/core/theme/theme_palette_test.dart
git commit -m "feat(theme): add ThemePalette ThemeExtension data class"
```

---

## Task 2: Create `ThemeCatalog` with 10 themes

**Files:**
- Create: `nexterm/lib/core/theme/theme_catalog.dart`
- Modify: `nexterm/lib/core/theme/terminal_themes.dart` (add 5 new TerminalTheme constants)
- Test: `nexterm/test/core/theme/theme_catalog_test.dart`

### Substep 2.1: Add 5 new TerminalTheme constants

- [ ] **Step 1: Append to `terminal_themes.dart` (before the `all` map)**

Insert these constants between the existing `solarizedLight` const and the `all` map:

```dart
  /// Nord theme (https://www.nordtheme.com/).
  static const nord = TerminalTheme(
    cursor: Color(0xFFD8DEE9),
    selection: Color(0x66434C5E),
    foreground: Color(0xFFD8DEE9),
    background: Color(0xFF2E3440),
    black: Color(0xFF3B4252),
    red: Color(0xFFBF616A),
    green: Color(0xFFA3BE8C),
    yellow: Color(0xFFEBCB8B),
    blue: Color(0xFF81A1C1),
    magenta: Color(0xFFB48EAD),
    cyan: Color(0xFF88C0D0),
    white: Color(0xFFE5E9F0),
    brightBlack: Color(0xFF4C566A),
    brightRed: Color(0xFFBF616A),
    brightGreen: Color(0xFFA3BE8C),
    brightYellow: Color(0xFFEBCB8B),
    brightBlue: Color(0xFF81A1C1),
    brightMagenta: Color(0xFFB48EAD),
    brightCyan: Color(0xFF8FBCBB),
    brightWhite: Color(0xFFECEFF4),
    searchHitBackground: Color(0xFFEBCB8B),
    searchHitBackgroundCurrent: Color(0xFFA3BE8C),
    searchHitForeground: Color(0xFF2E3440),
  );

  /// Gruvbox Dark Hard theme.
  static const gruvbox = TerminalTheme(
    cursor: Color(0xFFEBDBB2),
    selection: Color(0x66504945),
    foreground: Color(0xFFEBDBB2),
    background: Color(0xFF282828),
    black: Color(0xFF282828),
    red: Color(0xFFCC241D),
    green: Color(0xFF98971A),
    yellow: Color(0xFFD79921),
    blue: Color(0xFF458588),
    magenta: Color(0xFFB16286),
    cyan: Color(0xFF689D6A),
    white: Color(0xFFA89984),
    brightBlack: Color(0xFF928374),
    brightRed: Color(0xFFFB4934),
    brightGreen: Color(0xFFB8BB26),
    brightYellow: Color(0xFFFABD2F),
    brightBlue: Color(0xFF83A598),
    brightMagenta: Color(0xFFD3869B),
    brightCyan: Color(0xFF8EC07C),
    brightWhite: Color(0xFFEBDBB2),
    searchHitBackground: Color(0xFFD79921),
    searchHitBackgroundCurrent: Color(0xFF98971A),
    searchHitForeground: Color(0xFF282828),
  );

  /// Catppuccin Latte (light).
  static const catppuccinLatte = TerminalTheme(
    cursor: Color(0xFFDC8A78),
    selection: Color(0x66ACB0BE),
    foreground: Color(0xFF4C4F69),
    background: Color(0xFFEFF1F5),
    black: Color(0xFF5C5F77),
    red: Color(0xFFD20F39),
    green: Color(0xFF40A02B),
    yellow: Color(0xFFDF8E1D),
    blue: Color(0xFF1E66F5),
    magenta: Color(0xFFEA76CB),
    cyan: Color(0xFF179299),
    white: Color(0xFFACB0BE),
    brightBlack: Color(0xFF6C6F85),
    brightRed: Color(0xFFD20F39),
    brightGreen: Color(0xFF40A02B),
    brightYellow: Color(0xFFDF8E1D),
    brightBlue: Color(0xFF1E66F5),
    brightMagenta: Color(0xFFEA76CB),
    brightCyan: Color(0xFF179299),
    brightWhite: Color(0xFFBCC0CC),
    searchHitBackground: Color(0xFFDF8E1D),
    searchHitBackgroundCurrent: Color(0xFF40A02B),
    searchHitForeground: Color(0xFFEFF1F5),
  );

  /// GitHub Light theme (palette derived from GitHub Primer Light).
  static const githubLight = TerminalTheme(
    cursor: Color(0xFF24292F),
    selection: Color(0x660969DA),
    foreground: Color(0xFF1F2328),
    background: Color(0xFFFFFFFF),
    black: Color(0xFF24292F),
    red: Color(0xFFCF222E),
    green: Color(0xFF116329),
    yellow: Color(0xFF4D2D00),
    blue: Color(0xFF0969DA),
    magenta: Color(0xFF8250DF),
    cyan: Color(0xFF1B7C83),
    white: Color(0xFF6E7781),
    brightBlack: Color(0xFF57606A),
    brightRed: Color(0xFFA40E26),
    brightGreen: Color(0xFF1A7F37),
    brightYellow: Color(0xFF633C01),
    brightBlue: Color(0xFF218BFF),
    brightMagenta: Color(0xFF8250DF),
    brightCyan: Color(0xFF3192AA),
    brightWhite: Color(0xFF8C959F),
    searchHitBackground: Color(0xFFFFF8C5),
    searchHitBackgroundCurrent: Color(0xFFDAFBE1),
    searchHitForeground: Color(0xFF24292F),
  );

  /// Rosé Pine Dawn (light) — https://rosepinetheme.com.
  static const rosePineDawn = TerminalTheme(
    cursor: Color(0xFF575279),
    selection: Color(0x66DFDAD9),
    foreground: Color(0xFF575279),
    background: Color(0xFFFAF4ED),
    black: Color(0xFFF2E9E1),
    red: Color(0xFFB4637A),
    green: Color(0xFF286983),
    yellow: Color(0xFFEA9D34),
    blue: Color(0xFF56949F),
    magenta: Color(0xFF907AA9),
    cyan: Color(0xFFD7827E),
    white: Color(0xFF575279),
    brightBlack: Color(0xFF9893A5),
    brightRed: Color(0xFFB4637A),
    brightGreen: Color(0xFF286983),
    brightYellow: Color(0xFFEA9D34),
    brightBlue: Color(0xFF56949F),
    brightMagenta: Color(0xFF907AA9),
    brightCyan: Color(0xFFD7827E),
    brightWhite: Color(0xFF575279),
    searchHitBackground: Color(0xFFEA9D34),
    searchHitBackgroundCurrent: Color(0xFF286983),
    searchHitForeground: Color(0xFFFAF4ED),
  );
```

- [ ] **Step 2: Update the `all` map and remove `monokai` reference**

Replace the existing `all` map and `byName` block in `terminal_themes.dart`:

```dart
  /// Map of all available terminal themes by name.
  static const Map<String, TerminalTheme> all = {
    'catppuccin': catppuccin,
    'dracula': dracula,
    'solarized-dark': solarizedDark,
    'solarized-light': solarizedLight,
    'nord': nord,
    'gruvbox': gruvbox,
    'catppuccin-latte': catppuccinLatte,
    'github-light': githubLight,
    'rose-pine-dawn': rosePineDawn,
  };

  /// Returns the theme for [name], falling back to [catppuccin] if not found.
  static TerminalTheme byName(String name) {
    return all[name] ?? catppuccin;
  }
```

Also delete the entire `monokai` const block (lines ~62–87 in the current file).

### Substep 2.2: Write failing catalog test

- [ ] **Step 3: Write the failing test**

```dart
// nexterm/test/core/theme/theme_catalog_test.dart
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
```

- [ ] **Step 4: Run test to verify it fails**

```bash
cd nexterm && flutter test test/core/theme/theme_catalog_test.dart
```
Expected: FAIL — `theme_catalog.dart` doesn't exist yet.

### Substep 2.3: Implement the catalog

- [ ] **Step 5: Create `theme_catalog.dart`**

```dart
// nexterm/lib/core/theme/theme_catalog.dart
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
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
cd nexterm && flutter test test/core/theme/theme_catalog_test.dart
```
Expected: PASS (all tests).

- [ ] **Step 7: Commit**

```bash
git add nexterm/lib/core/theme/theme_catalog.dart \
        nexterm/lib/core/theme/terminal_themes.dart \
        nexterm/test/core/theme/theme_catalog_test.dart
git commit -m "feat(theme): add 10-theme catalog + 5 new TerminalTheme constants"
```

---

## Task 3: Refactor `theme_provider.dart` and add legacy migration

**Files:**
- Modify: `nexterm/lib/core/theme/theme_provider.dart`
- Modify: `nexterm/lib/features/settings/providers/settings_provider.dart`
- Test: `nexterm/test/core/theme/theme_provider_test.dart`

- [ ] **Step 1: Add `themeName` to `SettingsKeys`**

In `settings_provider.dart`, add inside `SettingsKeys` class (next to other keys):

```dart
  static const themeName = 'theme_name';
```

Leave `theme` and `terminalTheme` keys for now — they get deleted in Task 9.

- [ ] **Step 2: Write the failing test**

```dart
// nexterm/test/core/theme/theme_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

class _FakeSettings extends StateNotifier<Map<String, String>>
    implements SettingsNotifier {
  _FakeSettings(super.state);

  @override
  Future<void> set(String key, String value) async {
    state = {...state, key: value};
  }

  @override
  Future<void> remove(String key) async {
    state = Map.from(state)..remove(key);
  }

  @override
  String get(String key, {String defaultValue = ''}) =>
      state[key] ?? defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) =>
      int.tryParse(state[key] ?? '') ?? defaultValue;

  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      state[key] == 'true' ? true : (state[key] == 'false' ? false : defaultValue);

  @override
  Future<void> load() async {}
}

void main() {
  test('defaults to "nexterm" when no settings present', () {
    final fake = _FakeSettings({});
    final notifier = ThemeNotifier(fake);
    expect(notifier.state, 'nexterm');
  });

  test('loads existing themeName setting', () {
    final fake = _FakeSettings({'theme_name': 'dracula'});
    final notifier = ThemeNotifier(fake);
    expect(notifier.state, 'dracula');
  });

  test('migrates legacy terminal_theme to theme_name and deletes old keys',
      () async {
    final fake = _FakeSettings({
      'terminal_theme': 'catppuccin',
      'theme': 'dark',
    });
    final notifier = ThemeNotifier(fake);
    // legacy migration is async — wait for it
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, 'catppuccin-mocha');
    expect(fake.state['theme_name'], 'catppuccin-mocha');
    expect(fake.state.containsKey('terminal_theme'), false);
    expect(fake.state.containsKey('theme'), false);
  });

  test('setTheme writes the new key', () async {
    final fake = _FakeSettings({});
    final notifier = ThemeNotifier(fake);
    await notifier.setTheme('nord');
    expect(notifier.state, 'nord');
    expect(fake.state['theme_name'], 'nord');
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

```bash
cd nexterm && flutter test test/core/theme/theme_provider_test.dart
```
Expected: FAIL — current ThemeNotifier doesn't accept SettingsNotifier or expose `setTheme`.

- [ ] **Step 4: Replace `theme_provider.dart` contents**

```dart
// nexterm/lib/core/theme/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_catalog.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';

/// Holds the active theme name (key into `ThemeCatalog`).
class ThemeNotifier extends StateNotifier<String> {
  final SettingsNotifier _settings;

  ThemeNotifier(this._settings) : super('nexterm') {
    _load();
  }

  Future<void> _load() async {
    final legacyTerminal = _settings.get(SettingsKeys.terminalTheme);
    final stored = _settings.get(SettingsKeys.themeName);

    if (legacyTerminal.isNotEmpty) {
      // One-time migration from old split settings.
      final mapped = ThemeCatalog.mapLegacy(legacyTerminal);
      await _settings.set(SettingsKeys.themeName, mapped);
      await _settings.remove(SettingsKeys.terminalTheme);
      await _settings.remove(SettingsKeys.theme);
      state = mapped;
    } else if (stored.isNotEmpty && ThemeCatalog.all.containsKey(stored)) {
      state = stored;
    } else {
      state = 'nexterm';
    }
  }

  Future<void> setTheme(String key) async {
    if (!ThemeCatalog.all.containsKey(key)) return;
    state = key;
    await _settings.set(SettingsKeys.themeName, key);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  final settings = ref.watch(settingsNotifierProvider.notifier);
  return ThemeNotifier(settings);
});

/// Active palette derived from [themeProvider].
final paletteProvider = Provider<ThemePalette>((ref) {
  final key = ref.watch(themeProvider);
  return ThemeCatalog.byKey(key);
});
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd nexterm && flutter test test/core/theme/theme_provider_test.dart
```
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add nexterm/lib/core/theme/theme_provider.dart \
        nexterm/lib/features/settings/providers/settings_provider.dart \
        nexterm/test/core/theme/theme_provider_test.dart
git commit -m "feat(theme): add palette provider + legacy settings migration"
```

---

## Task 4: Replace `app_theme.dart` with `fromPalette()`

**Files:**
- Modify: `nexterm/lib/core/theme/app_theme.dart` (full rewrite)

- [ ] **Step 1: Replace `app_theme.dart` contents**

```dart
// nexterm/lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class AppTheme {
  AppTheme._();

  /// Builds a [ThemeData] from a [ThemePalette]. Used by `app.dart`.
  static ThemeData fromPalette(ThemePalette p) {
    final isDark = p.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: p.accent,
              surface: p.surfaceSolid,
              onSurface: p.fg,
              onSurfaceVariant: p.fgSecondary,
              outline: p.border,
              primaryContainer: p.accentDim,
              onPrimaryContainer: p.accent,
            )
          : ColorScheme.light(
              primary: p.accent,
              surface: p.surfaceSolid,
              onSurface: p.fg,
              onSurfaceVariant: p.fgSecondary,
              outline: p.border,
              primaryContainer: p.accentDim,
              onPrimaryContainer: p.accent,
            ),
      scaffoldBackgroundColor: p.bg,
      extensions: [p],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: p.fg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: p.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
          side: BorderSide(color: p.glassBorder, width: 0.5),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.navBg,
        indicatorColor: p.accentDim,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500, color: p.accent);
          }
          return TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: p.tabInactive);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: p.accent, size: 24);
          }
          return IconThemeData(color: p.tabInactive, size: 24);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: isDark ? p.bg : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.inputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: BorderSide(color: p.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: BorderSide(color: p.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: BorderSide(color: p.accent, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(OutdoorColors.radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accent,
        thumbColor: Colors.white,
        inactiveTrackColor: p.border,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.accent;
          return p.fgTertiary;
        }),
      ),
    );
  }
}
```

Note: this file deletes the existing `light()`, `dark()`, `onlineGreen`, `errorRed`, `errorRedLight`, `onlineGreenLight`, `warningYellow` static fields. The 50-file migration moves any consumer of these to read directly from the palette / theme.

- [ ] **Step 2: Verify analyzer to find consumers of removed helpers**

```bash
cd nexterm && flutter analyze lib/core/theme/app_theme.dart 2>&1 | tail -10
```
Expected: 0 issues for this file (it should be self-contained).

```bash
cd nexterm && grep -rn "AppTheme\." lib/ --include="*.dart"
```
Expected output: any callers of `AppTheme.light()`, `AppTheme.dark()`, `AppTheme.onlineGreen`, `AppTheme.errorRed`, `AppTheme.warningYellow`. Note these as files needing migration in subsequent tasks.

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/core/theme/app_theme.dart
git commit -m "refactor(theme): replace AppTheme.light/dark with fromPalette()"
```

---

## Task 5: Wire `app.dart` to use the palette

**Files:**
- Modify: `nexterm/lib/app.dart`

- [ ] **Step 1: Replace `app.dart` body**

```dart
// nexterm/lib/app.dart
import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/locale/locale_provider.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/core/router/app_router.dart';

class NextermApp extends ConsumerWidget {
  const NextermApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(paletteProvider);
    final locale = ref.watch(localeProvider);
    final theme = AppTheme.fromPalette(palette);
    return MaterialApp.router(
      title: 'Nexterm',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.light, // ignored when theme==darkTheme
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 2: Run analyzer to confirm app.dart compiles**

```bash
cd nexterm && flutter analyze lib/app.dart
```
Expected: 0 issues.

- [ ] **Step 3: Run full analyze — expect MANY errors in widget files (next tasks)**

```bash
cd nexterm && flutter analyze 2>&1 | tail -30
```
Expected: errors in any file that referenced `AppTheme.onlineGreen` etc. (these get fixed during the 50-file migration). The error count here is the size of the upcoming migration backlog — note it.

- [ ] **Step 4: Commit**

```bash
git add nexterm/lib/app.dart
git commit -m "refactor(theme): wire MaterialApp to palette-based theme"
```

After this commit the app builds via `flutter run` only if the 50 files still compile. **They do** — they still reference `OutdoorColors.X` (which exists) and any `AppTheme.X` static fields removed in Task 4 will surface as errors. Fix those in the corresponding migration tasks below.

---

## Task 6: Migrate the 50 OutdoorColors call sites

Apply the migration recipe (top of this plan) to each batch. After each batch, run `flutter analyze` and ensure 0 issues, then commit.

### Task 6.1: Shared painters and widgets

**Files:**
- `nexterm/lib/shared/painters/ridge_painter.dart`
- `nexterm/lib/shared/painters/topo_painter.dart`
- `nexterm/lib/shared/widgets/decorative_background.dart`
- `nexterm/lib/shared/widgets/glass_card.dart`
- `nexterm/lib/shared/widgets/outdoor_search_bar.dart`
- `nexterm/lib/shared/widgets/section_label.dart`
- `nexterm/lib/shared/widgets/status_indicator.dart`

- [ ] **Step 1: Apply the migration recipe to each file in this batch.** For widgets without `BuildContext` access in their constructor (e.g., `CustomPainter`), pass the resolved palette as a constructor argument and read from there. The pattern:

```dart
class TopoPainter extends CustomPainter {
  final ThemePalette palette;
  const TopoPainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final color = palette.accent.withValues(alpha: 0.06);
    // ...
  }
}

// caller (in a widget's build):
final p = Theme.of(context).extension<ThemePalette>()!;
CustomPaint(painter: TopoPainter(p));
```

- [ ] **Step 2: Run analyzer**

```bash
cd nexterm && flutter analyze lib/shared/ 2>&1 | tail -10
```
Expected: 0 issues for the `shared/` subtree.

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/shared/
git commit -m "refactor(theme): migrate shared widgets to ThemePalette"
```

### Task 6.2: Terminal feature

**Files:**
- `nexterm/lib/features/terminal/ui/sessions_screen.dart`
- `nexterm/lib/features/terminal/ui/terminal_screen.dart`
- `nexterm/lib/features/terminal/ui/toolbar_customize_screen.dart`
- `nexterm/lib/features/terminal/ui/widgets/command_history_panel.dart`
- `nexterm/lib/features/terminal/ui/widgets/function_panel.dart`
- `nexterm/lib/features/terminal/ui/widgets/keyboard_toolbar.dart`
- `nexterm/lib/features/terminal/ui/widgets/terminal_tab_bar.dart`

Special: `terminal_screen.dart` reads `TerminalThemes.byName(...)`. Replace that with `Theme.of(context).extension<ThemePalette>()!.terminal`.

- [ ] **Step 1: Apply recipe; replace `TerminalThemes.byName(name)` with `p.terminal`**
- [ ] **Step 2: Analyze** — `flutter analyze lib/features/terminal/ 2>&1 | tail -10` → 0 issues.
- [ ] **Step 3: Commit** — `git add nexterm/lib/features/terminal/ && git commit -m "refactor(theme): migrate terminal feature to ThemePalette"`

### Task 6.3: SFTP feature

**Files:**
- `nexterm/lib/features/sftp/ui/file_editor_screen.dart`
- `nexterm/lib/features/sftp/ui/widgets/file_breadcrumb.dart`
- `nexterm/lib/features/sftp/ui/widgets/file_list_view.dart`
- `nexterm/lib/features/sftp/ui/widgets/sftp_content.dart`
- `nexterm/lib/features/sftp/ui/widgets/transfer_queue_bar.dart`

- [ ] **Step 1: Apply recipe**
- [ ] **Step 2: Analyze** — `flutter analyze lib/features/sftp/ 2>&1 | tail -10` → 0 issues.
- [ ] **Step 3: Commit** — `git add nexterm/lib/features/sftp/ && git commit -m "refactor(theme): migrate sftp feature to ThemePalette"`

### Task 6.4: Forwarding feature

**Files:**
- `nexterm/lib/features/forwarding/ui/forward_form_screen.dart`
- `nexterm/lib/features/forwarding/ui/forwarding_screen.dart`
- `nexterm/lib/features/forwarding/ui/port_detection_sheet.dart`
- `nexterm/lib/features/forwarding/ui/widgets/detected_port_tile.dart`
- `nexterm/lib/features/forwarding/ui/widgets/forward_list_tile.dart`

- [ ] **Step 1: Apply recipe**
- [ ] **Step 2: Analyze** — `flutter analyze lib/features/forwarding/ 2>&1 | tail -10` → 0 issues.
- [ ] **Step 3: Commit** — `git add nexterm/lib/features/forwarding/ && git commit -m "refactor(theme): migrate forwarding feature to ThemePalette"`

### Task 6.5: Git feature

**Files:**
- `nexterm/lib/features/git/ui/git_repos_screen.dart`
- `nexterm/lib/features/git/ui/git_screen.dart`
- `nexterm/lib/features/git/ui/widgets/branch_graph_screen.dart`
- `nexterm/lib/features/git/ui/widgets/branch_list.dart`
- `nexterm/lib/features/git/ui/widgets/commit_detail_sheet.dart`
- `nexterm/lib/features/git/ui/widgets/commit_list.dart`
- `nexterm/lib/features/git/ui/widgets/git_init_prompt.dart`
- `nexterm/lib/features/git/ui/widgets/status_file_list.dart`
- `nexterm/lib/features/git/ui/widgets/tag_list.dart`

- [ ] **Step 1: Apply recipe**
- [ ] **Step 2: Analyze** — `flutter analyze lib/features/git/ 2>&1 | tail -10` → 0 issues.
- [ ] **Step 3: Commit** — `git add nexterm/lib/features/git/ && git commit -m "refactor(theme): migrate git feature to ThemePalette"`

### Task 6.6: Snippets feature

**Files:**
- `nexterm/lib/features/snippets/ui/snippet_execute_sheet.dart`
- `nexterm/lib/features/snippets/ui/snippet_form_screen.dart`
- `nexterm/lib/features/snippets/ui/snippets_screen.dart`
- `nexterm/lib/features/snippets/ui/widgets/snippet_list_tile.dart`

- [ ] **Step 1: Apply recipe**
- [ ] **Step 2: Analyze** — `flutter analyze lib/features/snippets/ 2>&1 | tail -10` → 0 issues.
- [ ] **Step 3: Commit** — `git add nexterm/lib/features/snippets/ && git commit -m "refactor(theme): migrate snippets feature to ThemePalette"`

### Task 6.7: Keys feature

**Files:**
- `nexterm/lib/features/keys/ui/key_generate_screen.dart`
- `nexterm/lib/features/keys/ui/key_import_screen.dart`
- `nexterm/lib/features/keys/ui/keys_screen.dart`
- `nexterm/lib/features/keys/ui/widgets/key_list_tile.dart`

- [ ] **Step 1: Apply recipe**
- [ ] **Step 2: Analyze** — `flutter analyze lib/features/keys/ 2>&1 | tail -10` → 0 issues.
- [ ] **Step 3: Commit** — `git add nexterm/lib/features/keys/ && git commit -m "refactor(theme): migrate keys feature to ThemePalette"`

### Task 6.8: Hosts feature

**Files:**
- `nexterm/lib/features/hosts/ui/host_form_screen.dart`
- `nexterm/lib/features/hosts/ui/hosts_screen.dart`
- `nexterm/lib/features/hosts/ui/widgets/host_list_tile.dart`

- [ ] **Step 1: Apply recipe**
- [ ] **Step 2: Analyze** — `flutter analyze lib/features/hosts/ 2>&1 | tail -10` → 0 issues.
- [ ] **Step 3: Commit** — `git add nexterm/lib/features/hosts/ && git commit -m "refactor(theme): migrate hosts feature to ThemePalette"`

### Task 6.9: Vaults / SMB / WebDAV / settings/lock_screen

**Files:**
- `nexterm/lib/features/vaults/ui/vaults_screen.dart`
- `nexterm/lib/features/smb/ui/smb_connections_screen.dart`
- `nexterm/lib/features/webdav/ui/webdav_connections_screen.dart`
- `nexterm/lib/features/settings/ui/lock_screen.dart`

(`settings_screen.dart` is handled separately in Task 7 because its UI structure also changes.)

- [ ] **Step 1: Apply recipe**
- [ ] **Step 2: Analyze**

```bash
cd nexterm && flutter analyze lib/features/vaults/ lib/features/smb/ lib/features/webdav/ lib/features/settings/ui/lock_screen.dart 2>&1 | tail -10
```
Expected: 0 issues.

- [ ] **Step 3: Commit** — `git add nexterm/lib/features/vaults/ nexterm/lib/features/smb/ nexterm/lib/features/webdav/ nexterm/lib/features/settings/ui/lock_screen.dart && git commit -m "refactor(theme): migrate vaults/smb/webdav/lock_screen to ThemePalette"`

### Task 6.10: Final analyze — confirm only `settings_screen.dart` and `outdoor_colors.dart` remain

- [ ] **Step 1: Run repo-wide analyzer**

```bash
cd nexterm && flutter analyze 2>&1 | tail -20
```
Expected: errors only in `settings_screen.dart` (still references `OutdoorColors`, addressed in Task 7) and possibly `outdoor_colors.dart` itself if any internal helper depends on the removed fields. NO other files should have `OutdoorColors.X` references except those two.

- [ ] **Step 2: Sanity check**

```bash
cd nexterm && grep -rln "OutdoorColors\.\(dark\|light\|accent\|term\|status\)" lib/ --include="*.dart"
```
Expected output: only `lib/features/settings/ui/settings_screen.dart` and `lib/core/theme/outdoor_colors.dart` (and possibly `lib/core/theme/app_theme.dart` if any radius reference was kept).

If any other file appears, return to that file's batch and finish migration.

---

## Task 7: Replace settings UI with unified theme picker

**Files:**
- Modify: `nexterm/lib/features/settings/ui/settings_screen.dart`
- Modify: `nexterm/lib/l10n/app_en.arb`
- Modify: `nexterm/lib/l10n/app_zh.arb`

### Substep 7.1: Update l10n

- [ ] **Step 1: Edit `app_en.arb`** — remove these keys (and their adjacent metadata if any):

```
"settings_themeLight": "Light",
"settings_themeDark": "Dark",
"settings_themeSystem": "Follow System",
"settings_terminalTheme": "Terminal Color Scheme",
"settings_selectTerminalTheme": "Select Terminal Color Scheme",
```

Add these keys (placement: alongside `settings_theme`):

```json
"settings_themeGroupDark": "DARK",
"settings_themeGroupLight": "LIGHT",
```

- [ ] **Step 2: Edit `app_zh.arb`** — remove these keys:

```
"settings_themeLight": "浅色",
"settings_themeDark": "深色",
"settings_themeSystem": "跟随系统",
"settings_terminalTheme": "终端配色方案",
"settings_selectTerminalTheme": "选择终端配色",
```

Add:

```json
"settings_themeGroupDark": "暗色",
"settings_themeGroupLight": "亮色",
```

- [ ] **Step 3: Regenerate l10n**

```bash
cd nexterm && flutter gen-l10n
```
Expected: success, no warnings.

### Substep 7.2: Migrate settings_screen.dart's OutdoorColors references and replace pickers

- [ ] **Step 4: Apply the migration recipe to all `OutdoorColors.X` references in `settings_screen.dart`**

Same recipe as Task 6.

- [ ] **Step 5: Replace App-theme + Terminal-theme tiles**

In the `build` method's ListView children, **DELETE** these blocks:

```dart
ListTile(
  leading: const Icon(Icons.palette_outlined),
  title: Text(l.settings_theme),
  subtitle: Text(_themePreferenceLabel(themeState.preference, l)),
  onTap: () => _showThemePicker(context, themeState.preference, themeNotifier),
),
```

```dart
ListTile(
  leading: const Icon(Icons.color_lens_outlined),
  title: Text(l.settings_terminalTheme),
  subtitle: Text(_terminalThemeLabel(themeState.terminalThemeName)),
  onTap: () => _showTerminalThemePicker(context, themeState.terminalThemeName, themeNotifier),
),
```

**INSERT** under "General" section (next to the language tile):

```dart
ListTile(
  leading: const Icon(Icons.palette_outlined),
  title: Text(l.settings_theme),
  subtitle: Text(ThemeCatalog.displayName(ref.watch(themeProvider))),
  onTap: () => _showThemePicker(context, ref),
),
```

Add to imports at the top of the file:

```dart
import 'package:nexterm/core/theme/theme_catalog.dart';
```

- [ ] **Step 6: Delete dead helpers and old picker dialogs**

- Delete the static methods: `_themePreferenceLabel`, `_terminalThemeLabel`
- Delete the methods: `_showThemePicker(context, current, notifier)`, `_showTerminalThemePicker(context, current, notifier)` (existing 2-arg/3-arg signatures)
- Delete the classes: `_ThemePickerDialog`, `_TerminalThemePickerDialog`
- Delete the local read of `themeState`: `final themeState = ref.watch(themeProvider);` AND `final themeNotifier = ref.read(themeProvider.notifier);` — they no longer exist in their old form. Replace any other uses of `themeState.X` in the file with the new providers (`ref.watch(themeProvider)` returns a `String` now).

- [ ] **Step 7: Add the new picker dialog method and class**

Add a new method on `SettingsScreen` (alongside the other `_showXPicker` methods):

```dart
void _showThemePicker(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (ctx) => const _ThemePickerDialog(),
  );
}
```

Add the new dialog class at the end of the file (near `_AutoLockPickerDialog`):

```dart
class _ThemePickerDialog extends ConsumerWidget {
  const _ThemePickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final current = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.settings_selectTheme,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _Group(
                    label: l.settings_themeGroupDark,
                    keys: ThemeCatalog.darkKeys,
                    current: current,
                    accent: p.accent,
                    onSelect: (k) {
                      notifier.setTheme(k);
                      Navigator.of(context).pop();
                    },
                  ),
                  _Group(
                    label: l.settings_themeGroupLight,
                    keys: ThemeCatalog.lightKeys,
                    current: current,
                    accent: p.accent,
                    onSelect: (k) {
                      notifier.setTheme(k);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String label;
  final List<String> keys;
  final String current;
  final Color accent;
  final ValueChanged<String> onSelect;

  const _Group({
    required this.label,
    required this.keys,
    required this.current,
    required this.accent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final key in keys)
          _ThemeRow(
            themeKey: key,
            isSelected: key == current,
            accent: accent,
            onTap: () => onSelect(key),
          ),
      ],
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final String themeKey;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.themeKey,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = ThemeCatalog.byKey(themeKey);
    final swatches = [
      palette.terminal.black,
      palette.terminal.red,
      palette.terminal.green,
      palette.terminal.yellow,
      palette.terminal.blue,
    ];
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ThemeCatalog.displayName(themeKey),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            for (final swatch in swatches)
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.check,
              size: 18,
              color: isSelected ? accent : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
```

Add to imports:

```dart
import 'package:nexterm/core/theme/theme_palette.dart';
```

- [ ] **Step 8: Run analyzer**

```bash
cd nexterm && flutter analyze 2>&1 | tail -10
```
Expected: 0 issues across the entire repo. If `outdoor_colors.dart` still has the field declarations they're untouched but unused — that's OK; Task 9 cleans them up.

- [ ] **Step 9: Run tests**

```bash
cd nexterm && flutter test 2>&1 | tail -10
```
Expected: all green.

- [ ] **Step 10: Commit**

```bash
git add nexterm/lib/features/settings/ui/settings_screen.dart \
        nexterm/lib/l10n/app_en.arb \
        nexterm/lib/l10n/app_zh.arb \
        nexterm/lib/l10n/app_localizations*.dart
git commit -m "feat(settings): unified theme picker with 10 themes"
```

---

## Task 8: Manual smoke test on iOS Simulator

**Files:** none modified.

- [ ] **Step 1: Boot simulator and launch app**

```bash
cd nexterm && flutter run -d "iPhone 15 Pro" 2>&1 | head -60
```
Expected: app launches, no runtime errors. Hot-reload friendly.

- [ ] **Step 2: For each of 10 themes, switch and verify 6 screens**

Procedure for each theme:
1. Settings → 主题 → tap target theme
2. Confirm picker dismisses, settings tile subtitle shows the new name
3. Verify these screens render with theme colors (no white-on-white, accent visible, borders visible):
   - Vaults / Hosts list
   - Active sessions list
   - Settings root
   - SFTP file browser (open any host → connect → SFTP)
   - Terminal session
   - Snippet form (Snippets tab → +)

Themes to test: nexterm, dracula, nord, solarized-dark, gruvbox, catppuccin-mocha, solarized-light, catppuccin-latte, github-light, rose-pine-dawn.

- [ ] **Step 3: Verify legacy migration**

Stop the app. Inject legacy settings:
```bash
# In a new shell, while app is killed
sqlite3 ~/Library/Developer/CoreSimulator/Devices/<device-uuid>/data/Containers/Data/Application/<app-uuid>/Documents/nexterm.db \
  "DELETE FROM settings WHERE key='theme_name'; \
   INSERT OR REPLACE INTO settings(key,value) VALUES('terminal_theme','catppuccin'); \
   INSERT OR REPLACE INTO settings(key,value) VALUES('theme','dark');"
```
(Locate the actual db path with `find ~/Library/Developer/CoreSimulator -name "nexterm*.db" 2>/dev/null`.)

Relaunch app → Settings → 主题 → expect "Catppuccin Mocha" shown.

In sqlite check old keys are gone and `theme_name=catppuccin-mocha` is present.

If verification passes, no commit (this is QA).

- [ ] **Step 4: If any theme has bad contrast, patch its palette**

Open `theme_catalog.dart`, fix the offending color, re-run smoke test.

```bash
git add nexterm/lib/core/theme/theme_catalog.dart
git commit -m "fix(theme): tune <theme-name> contrast"
```

---

## Task 9: Cleanup OutdoorColors and SettingsKeys

**Files:**
- Modify: `nexterm/lib/core/theme/outdoor_colors.dart`
- Modify: `nexterm/lib/features/settings/providers/settings_provider.dart`

- [ ] **Step 1: Reduce `outdoor_colors.dart` to layout constants only**

Replace the entire file with:

```dart
// nexterm/lib/core/theme/outdoor_colors.dart
class OutdoorColors {
  OutdoorColors._();

  static const double radiusLg = 14.0;
  static const double radiusMd = 10.0;
  static const double radiusSm = 8.0;
}
```

- [ ] **Step 2: Drop legacy keys from `SettingsKeys`**

Edit `nexterm/lib/features/settings/providers/settings_provider.dart`:

```dart
// remove these two lines:
static const theme = 'theme';
static const terminalTheme = 'terminal_theme';
```

(`SettingsKeys.themeName` stays.)

The `ThemeNotifier._load()` method in `theme_provider.dart` uses string literals `'terminal_theme'` and `'theme'` for the legacy migration — change those to literals (since the keys no longer exist on `SettingsKeys`):

```dart
// before
final legacyTerminal = _settings.get(SettingsKeys.terminalTheme);
// after
final legacyTerminal = _settings.get('terminal_theme');
// and likewise for 'theme'
await _settings.remove('terminal_theme');
await _settings.remove('theme');
```

- [ ] **Step 3: Run analyzer**

```bash
cd nexterm && flutter analyze 2>&1 | tail -10
```
Expected: 0 issues. If anything still references the deleted color fields, fix per error.

- [ ] **Step 4: Run tests**

```bash
cd nexterm && flutter test 2>&1 | tail -10
```
Expected: all green.

- [ ] **Step 5: Commit**

```bash
git add nexterm/lib/core/theme/outdoor_colors.dart \
        nexterm/lib/core/theme/theme_provider.dart \
        nexterm/lib/features/settings/providers/settings_provider.dart
git commit -m "chore(theme): drop OutdoorColors color fields and legacy SettingsKeys"
```

---

## Task 10: Final verification

- [ ] **Step 1: Repo-wide analyze**

```bash
cd nexterm && flutter analyze 2>&1 | tail -5
```
Expected: `No issues found!`

- [ ] **Step 2: Repo-wide test**

```bash
cd nexterm && flutter test 2>&1 | tail -5
```
Expected: All tests pass.

- [ ] **Step 3: No leftover references**

```bash
cd nexterm && grep -rn "OutdoorColors\.\(dark\|light\|accent\|term\|status\)" lib/ --include="*.dart"
cd nexterm && grep -rn "SettingsKeys\.theme[^N]\|SettingsKeys\.terminalTheme" lib/ --include="*.dart"
cd nexterm && grep -rn "AppTheme\.light\|AppTheme\.dark\|AppTheme\.onlineGreen\|AppTheme\.errorRed\|AppTheme\.warningYellow" lib/ --include="*.dart"
cd nexterm && grep -rn "_TerminalThemePickerDialog\|_themePreferenceLabel\|_terminalThemeLabel" lib/ --include="*.dart"
cd nexterm && grep -rn "monokai" lib/ --include="*.dart"
```
Expected: each command returns no matches.

- [ ] **Step 4: Smoke test build for both platforms**

```bash
cd nexterm && flutter build ios --simulator --no-codesign 2>&1 | tail -10
```
Expected: build succeeds (release/AOT compile sanity).

- [ ] **Step 5: Push branch**

```bash
git push origin main
```

- [ ] **Step 6: Update CHANGELOG (if one exists)**

```bash
ls nexterm/CHANGELOG.md 2>/dev/null && echo "Add a new line under Unreleased"
```
If a CHANGELOG.md exists, prepend an entry:

```markdown
- Unified theming: a single picker replaces App-theme and Terminal-theme settings; 10 named themes (6 dark + 4 light) repaint terminal + App chrome together.
```
Commit with `docs: update changelog`.

If no CHANGELOG.md exists, skip this step.
