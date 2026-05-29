import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: OutdoorColors.accent,
        surface: OutdoorColors.lightSurfaceSolid,
        onSurface: OutdoorColors.lightFg,
        onSurfaceVariant: OutdoorColors.lightFgSecondary,
        outline: OutdoorColors.lightBorder,
        primaryContainer: OutdoorColors.accentDim,
        onPrimaryContainer: OutdoorColors.accent,
      ),
      scaffoldBackgroundColor: OutdoorColors.lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: OutdoorColors.lightFg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: OutdoorColors.lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
          side: const BorderSide(color: OutdoorColors.lightGlassBorder, width: 0.5),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: OutdoorColors.lightNavBg,
        indicatorColor: OutdoorColors.accentDim,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: OutdoorColors.accent);
          }
          return const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: OutdoorColors.lightTabInactive);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: OutdoorColors.accent, size: 24);
          }
          return const IconThemeData(color: OutdoorColors.lightTabInactive, size: 24);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: OutdoorColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OutdoorColors.lightInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: const BorderSide(color: OutdoorColors.lightBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: const BorderSide(color: OutdoorColors.lightBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: const BorderSide(color: OutdoorColors.accent, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: OutdoorColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OutdoorColors.radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: OutdoorColors.accent,
        thumbColor: Colors.white,
        inactiveTrackColor: OutdoorColors.lightBorder,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OutdoorColors.accent;
          return OutdoorColors.lightFgTertiary;
        }),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: OutdoorColors.accent,
        surface: OutdoorColors.darkSurfaceSolid,
        onSurface: OutdoorColors.darkFg,
        onSurfaceVariant: OutdoorColors.darkFgSecondary,
        outline: OutdoorColors.darkBorder,
        primaryContainer: OutdoorColors.accentDim,
        onPrimaryContainer: OutdoorColors.accent,
      ),
      scaffoldBackgroundColor: OutdoorColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: OutdoorColors.darkFg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: OutdoorColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
          side: const BorderSide(color: OutdoorColors.darkGlassBorder, width: 0.5),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: OutdoorColors.darkNavBg,
        indicatorColor: OutdoorColors.accentDim,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: OutdoorColors.accent);
          }
          return const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: OutdoorColors.darkTabInactive);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: OutdoorColors.accent, size: 24);
          }
          return const IconThemeData(color: OutdoorColors.darkTabInactive, size: 24);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: OutdoorColors.accent,
        foregroundColor: OutdoorColors.darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OutdoorColors.darkInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: const BorderSide(color: OutdoorColors.darkBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: const BorderSide(color: OutdoorColors.darkBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
          borderSide: const BorderSide(color: OutdoorColors.accent, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: OutdoorColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(OutdoorColors.radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: OutdoorColors.accent,
        thumbColor: Colors.white,
        inactiveTrackColor: OutdoorColors.darkBorder,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return OutdoorColors.accent;
          return OutdoorColors.darkFgTertiary;
        }),
      ),
    );
  }

  // Status colors (compatible with existing references)
  static const Color onlineGreen = OutdoorColors.darkStatusOnline;
  static const Color onlineGreenLight = OutdoorColors.lightStatusOnline;
  static const Color errorRed = Color(0xFFF38BA8);
  static const Color errorRedLight = Color(0xFFE17055);
  static const Color warningYellow = Color(0xFFF9E2AF);
}
