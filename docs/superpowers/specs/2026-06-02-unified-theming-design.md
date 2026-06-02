# Unified Theming (Moshi-Style)

## Context

Today the app exposes two unrelated theme settings:
1. **App theme** — Light / Dark / System (drives `OutdoorColors.lightX` vs `OutdoorColors.darkX`).
2. **Terminal theme** — Catppuccin / Dracula / Monokai / Solarized Dark / Solarized Light (only affects xterm color cells).

Picking "Solarized Light" for the terminal does nothing to the App chrome; picking "Dark" for the App keeps the terminal at its independently chosen palette. The two never coordinate.

Inspired by Moshi (see [docs/moshi-research.md](../../moshi-research.md), §11), we want a single picker where one selection drives **both** the terminal palette **and** the App's surface/text/accent colors. Each theme owns its brightness; the separate Light/Dark/System toggle goes away.

The visual reference is Moshi's theme picker — DARK / LIGHT grouped list with theme name + 5 ANSI swatches per row.

## Decisions

| Question | Decision |
|---|---|
| Coverage | **Full Moshi-style repaint** — each theme repaints terminal + App chrome (background, cards, nav, accent). |
| Light/Dark/System toggle | **Remove.** Each theme is intrinsically light or dark. |
| Default theme | **`nexterm`** — keeps current dark `OutdoorColors` palette + green `#5CB85C` accent. |
| System bar / iOS keyboard | Follow brightness only (Flutter's default `SystemUiOverlayStyle`). No background tinting. |
| Implementation phasing | **One-shot refactor in a single PR.** Avoids "half-tinted" intermediate state. |

## Architecture

### `ThemePalette extends ThemeExtension<ThemePalette>`

A single immutable struct carrying every color the App reads. New file: [nexterm/lib/core/theme/theme_palette.dart](../../../nexterm/lib/core/theme/theme_palette.dart). Fields:

```
brightness                         // Brightness.light | dark
// Surfaces
bg, bgElevated, surface, surfaceSolid, cardBg, navBg, inputBg
// Foregrounds
fg, fgSecondary, fgTertiary, tabInactive
// Borders
border, glassBorder
// Accent
accent, accentDim, accentGlow
// Status
statusOnline, statusConnecting, statusOffline, statusError
// Terminal helpers (used by code that displays terminal-styled text in UI)
terminalBg, termPrompt, termPath, termCommand, termOutput
// Bundled xterm theme
TerminalTheme terminal             // 22 ANSI fields
```

`ThemePalette` implements `copyWith` and `lerp` (no-op `return this` is acceptable — we don't animate between themes).

### Theme catalog

New file: [nexterm/lib/core/theme/theme_catalog.dart](../../../nexterm/lib/core/theme/theme_catalog.dart). Map of 10 entries:

| key | brightness | bg | accent | terminal source |
|---|---|---|---|---|
| `nexterm` (default) | dark | `#0D1117` | `#5CB85C` | reuse current `catppuccin` ANSI |
| `dracula` | dark | `#282A36` | `#BD93F9` | reuse `dracula` ANSI |
| `nord` | dark | `#2E3440` | `#88C0D0` | new (Nord palette) |
| `solarized-dark` | dark | `#002B36` | `#268BD2` | reuse `solarizedDark` ANSI |
| `gruvbox` | dark | `#282828` | `#FE8019` | new (Gruvbox Dark Hard) |
| `catppuccin-mocha` | dark | `#1E1E2E` | `#CBA6F7` | reuse `catppuccin` ANSI |
| `solarized-light` | light | `#FDF6E3` | `#268BD2` | reuse `solarizedLight` ANSI |
| `catppuccin-latte` | light | `#EFF1F5` | `#8839EF` | new (Catppuccin Latte) |
| `github-light` | light | `#FFFFFF` | `#0969DA` | new (GitHub Light) |
| `rose-pine-dawn` | light | `#FAF4ED` | `#B4637A` | new (Rosé Pine Dawn) |

Each entry's full color list comes from each theme's published reference. Light themes invert the bright/dim ANSI ramp (Moshi research §11) so terminal status lines stay readable on bright backgrounds.

`monokai` is dropped from terminal_themes.dart (not in the screenshot list).

### Hooking into Flutter

[nexterm/lib/core/theme/app_theme.dart](../../../nexterm/lib/core/theme/app_theme.dart) is rewritten to one factory:

```dart
ThemeData fromPalette(ThemePalette p) {
  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: ColorScheme(
      brightness: p.brightness,
      primary: p.accent,
      surface: p.surfaceSolid,
      onSurface: p.fg,
      onSurfaceVariant: p.fgSecondary,
      outline: p.border,
      primaryContainer: p.accentDim,
      onPrimaryContainer: p.accent,
      // ...remaining required ColorScheme fields derived from palette
    ),
    scaffoldBackgroundColor: p.bg,
    extensions: [p],
    // appBarTheme / cardTheme / inputDecorationTheme / etc — all read from `p`
  );
}
```

Material widgets that already lean on `colorScheme` (ListTile, Card, AppBar, FilledButton, TextField with default decoration) repaint for free.

### Provider wiring

[nexterm/lib/core/theme/theme_provider.dart](../../../nexterm/lib/core/theme/theme_provider.dart) collapses to:

```dart
class ThemeNotifier extends StateNotifier<String> {  // value = themeKey
  final SettingsNotifier _settings;
  ThemeNotifier(this._settings) : super('nexterm') { _load(); }
  void setTheme(String key) { state = key; _settings.set('theme_name', key); }
  // _load reads settings + runs migration (see below)
}

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) =>
    ThemeNotifier(ref.watch(settingsNotifierProvider.notifier)));

final paletteProvider = Provider<ThemePalette>((ref) {
  final key = ref.watch(themeProvider);
  return ThemeCatalog.byKey(key);  // falls back to nexterm
});
```

[nexterm/lib/main.dart](../../../nexterm/lib/main.dart) `MaterialApp.router` becomes:

```dart
final palette = ref.watch(paletteProvider);
final theme = AppTheme.fromPalette(palette);
return MaterialApp.router(
  theme: theme,
  darkTheme: theme,            // same — we never want system to override our pick
  themeMode: ThemeMode.light,  // ignored when theme==darkTheme
  ...
);
```

### Settings storage migration

One-time on first launch after upgrade, run in `ThemeNotifier._load()`:

```
old_terminalTheme = settings.get('terminal_theme')
old_appTheme      = settings.get('theme')          // light/dark/system

if old_terminalTheme.isNotEmpty {
  state = mapLegacy(old_terminalTheme)             // catppuccin → catppuccin-mocha,
                                                   // solarized-light/dark stay,
                                                   // dracula stays, monokai → nexterm
  settings.set('theme_name', state)
  settings.remove('terminal_theme')
  settings.remove('theme')
} else if settings.has('theme_name') {
  state = settings.get('theme_name')
} else {
  state = 'nexterm'
}
```

`SettingsKeys.theme` and `SettingsKeys.terminalTheme` are removed from the class.

## Settings UI

[nexterm/lib/features/settings/ui/settings_screen.dart](../../../nexterm/lib/features/settings/ui/settings_screen.dart):

- Delete the **App theme** ListTile + `_ThemePickerDialog` class
- Delete the **Terminal theme** ListTile + `_TerminalThemePickerDialog` class
- Add **Theme** ListTile (`Icons.palette_outlined`, `l.settings_theme`) — subtitle = current theme's display name
- New `_ThemePickerDialog` (full-screen sheet) matching the screenshot:

```
┌──────────────────────────────────┐
│  ←       主题                    │
├──────────────────────────────────┤
│ DARK                             │
│  Nexterm           ▢▢▢▢▢   ✓    │
│  Dracula           ▢▢▢▢▢        │
│  Nord              ▢▢▢▢▢        │
│  Solarized Dark    ▢▢▢▢▢        │
│  Gruvbox           ▢▢▢▢▢        │
│  Catppuccin Mocha  ▢▢▢▢▢        │
├──────────────────────────────────┤
│ LIGHT                            │
│  Solarized Light   ▢▢▢▢▢        │
│  Catppuccin Latte  ▢▢▢▢▢        │
│  GitHub Light      ▢▢▢▢▢        │
│  Rosé Pine Dawn    ▢▢▢▢▢        │
└──────────────────────────────────┘
```

5 swatches per row pull from `palette.terminal`'s `black, red, green, yellow, blue` (matches Moshi's row design). Selected row gets a check mark in the **currently active theme's** accent color.

### l10n changes

[nexterm/lib/l10n/app_en.arb](../../../nexterm/lib/l10n/app_en.arb) and [app_zh.arb](../../../nexterm/lib/l10n/app_zh.arb):

- **Delete**: `settings_themeLight`, `settings_themeDark`, `settings_themeSystem`, `settings_terminalTheme`, `settings_selectTerminalTheme` (no longer referenced after picker collapse)
- **Add**: `settings_themeGroupDark` ("DARK" / "暗色"), `settings_themeGroupLight` ("LIGHT" / "亮色")
- **Keep**: `settings_theme` ("Theme" / "主题") and `settings_selectTheme` ("Select Theme" / "选择主题") — repurposed to label the new unified picker
- Theme display names (Nexterm, Dracula, Nord, Gruvbox, Solarized Dark/Light, Catppuccin Mocha/Latte, GitHub Light, Rosé Pine Dawn) are brand names — render verbatim without l10n keys

## Migrating the 51 OutdoorColors call sites

`grep -l "OutdoorColors\." nexterm/lib/` → 51 files. Migration recipe per file:

1. **Inside a `build()` or method that has `BuildContext`**: add at the top
   ```dart
   final p = Theme.of(context).extension<ThemePalette>()!;
   ```
   Replace `OutdoorColors.darkBg` / `OutdoorColors.lightBg` → `p.bg` (the palette already encodes brightness).
2. **`const` constructors that wrap an `OutdoorColors.X`** must drop `const` (analyzer flags this; fix per error).
3. **Branching on brightness** like `isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg` collapses to `p.bg`.
4. **Outside `build()`** (static constants, top-level helpers, `AppTheme.onlineGreen` shims): convert to a function that takes `ThemePalette` or `BuildContext`. Audit list: `AppTheme.onlineGreen / errorRed / warningYellow` and any `static const Color` referencing `OutdoorColors`.

`OutdoorColors` itself stays as the file but is reduced to:
- Layout constants only (`radiusLg/Md/Sm`)
- Deleted: every per-mode color field

If any non-color helpers in `OutdoorColors` are still used, they survive; otherwise the file deletes.

## Testing

Manual on iOS (Simulator + 1 real device):

For each of the 10 themes, switch to it then verify these 6 screens render correctly (no white-on-white, no missing borders, accent shows up where expected):

1. Hosts list (Vaults tab)
2. Active sessions tab
3. Settings root (this is also where the picker lives — verify swatches accurate)
4. SFTP file browser
5. Terminal session (chrome around xterm + xterm itself)
6. Snippet form (forms / dialogs / radio lists)

Lock screen + login dialog count as smoke tests on the first dark and first light theme; not all 10.

Automated: existing widget tests should keep passing; if any reference `OutdoorColors.X` they get the same migration.

## Out of scope

- Status bar / iOS keyboard background per-theme tinting
- System Light/Dark auto-switching (user manually picks one of 10)
- Adding more themes beyond the 10 in the catalog
- Theming for third-party plugin UIs (file_picker sheet, speech permission prompt) — those use platform defaults
- Animating between themes — switch is instantaneous

## Risks

- **Color accuracy for the 6 new palettes.** Each new theme needs ~25 colors. Wrong values produce illegible text. Mitigation: use each project's published reference palette, build & eyeball each theme against the screenshot during testing.
- **Forgotten `const` removals.** Flutter analyzer catches these reliably; fix per error during the migration.
- **App startup before theme provider resolves.** `paletteProvider` reads from `settingsNotifierProvider`, which is async (`SettingsNotifier.load()`). For the brief window before settings load, the StateNotifier's initial state is `'nexterm'` so the palette falls back to that — verified safe. The native iOS launch screen (drawable in `ios/Runner/Assets.xcassets/LaunchImage.imageset`) is unaffected by Dart-side themes; we accept that briefly-visible default.

## Verification

1. `cd nexterm && flutter analyze` — 0 issues
2. `cd nexterm && flutter test` — existing tests green
3. Manual test matrix above
4. `git diff --stat` — touches the 51 OutdoorColors files + 4 new theme files + settings/main + l10n
