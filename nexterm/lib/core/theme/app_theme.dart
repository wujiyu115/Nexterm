// nexterm/lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class AppFonts {
  AppFonts._();
  static const mono = 'JetBrains Mono';
}

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(ThemePalette p) {
    final color = p.fg;
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      bodyLarge: TextStyle(fontSize: 14, color: color),
      bodyMedium: TextStyle(fontSize: 13, color: color),
      bodySmall: TextStyle(fontSize: 12, color: color),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
    );
  }

  /// Builds a [ThemeData] from a [ThemePalette]. Used by `app.dart`.
  static ThemeData fromPalette(ThemePalette p) {
    final isDark = p.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: _buildColorScheme(p),
      scaffoldBackgroundColor: p.bg,
      textTheme: _buildTextTheme(p),
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

  static ColorScheme _buildColorScheme(ThemePalette p) {
    final base = p.brightness == Brightness.dark
        ? const ColorScheme.dark()
        : const ColorScheme.light();
    return base.copyWith(
      primary: p.accent,
      surface: p.surfaceSolid,
      surfaceContainer: p.cardBg,
      surfaceContainerHigh: p.bgElevated,
      onSurface: p.fg,
      onSurfaceVariant: p.fgSecondary,
      outline: p.border,
      primaryContainer: p.accentDim,
      onPrimaryContainer: p.accent,
      error: p.statusError,
    );
  }
}
