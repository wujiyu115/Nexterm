# Outdoor Tech Fusion UI Restyle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle all Nexterm app screens from Catppuccin purple Material3 to Outdoor Tech Fusion (green accent, glassmorphism, topographic textures) while keeping all functionality unchanged.

**Architecture:** Bottom-up approach — theme tokens first, then shared decorative/component widgets, then apply per-screen. Each screen retains its current navigation structure and logic; only widget appearance and layout density changes.

**Tech Stack:** Flutter 3.29+, Dart 3.7, Material 3 ThemeData, CustomPainter for decorative layers, BackdropFilter for glassmorphism.

---

## File Structure

### New files to create:
- `lib/core/theme/outdoor_colors.dart` — Token constants for both light/dark palettes
- `lib/shared/widgets/decorative_background.dart` — Full-screen background with glows, topographic lines, noise, mountain ridge
- `lib/shared/widgets/glass_card.dart` — Reusable glassmorphism card widget
- `lib/shared/widgets/section_label.dart` — Green section label with glowing vertical bar
- `lib/shared/widgets/outdoor_search_bar.dart` — Styled search bar widget
- `lib/shared/painters/topo_painter.dart` — CustomPainter for topographic contour lines
- `lib/shared/painters/noise_painter.dart` — CustomPainter for film grain noise
- `lib/shared/painters/ridge_painter.dart` — CustomPainter for mountain ridge silhouette

### Files to modify:
- `lib/core/theme/app_theme.dart` — Complete rewrite with new color scheme
- `lib/shared/widgets/app_scaffold.dart` — Add decorative background, restyle NavigationBar
- `lib/shared/widgets/status_indicator.dart` — Add glow and pulse animation
- `lib/features/vaults/ui/vaults_screen.dart` — Apply glass cards, section labels, large title
- `lib/features/hosts/ui/hosts_screen.dart` — Apply new section labels, large title nav
- `lib/features/hosts/ui/widgets/host_list_tile.dart` — Glass card style, green status glow
- `lib/features/hosts/ui/widgets/host_search_bar.dart` — Replace with OutdoorSearchBar
- `lib/features/keys/ui/keys_screen.dart` — Apply glass cards, icon containers with sheen
- `lib/features/keys/ui/widgets/key_list_tile.dart` — Glass card, icon with reflection
- `lib/features/snippets/ui/snippets_screen.dart` — Apply glass cards, section labels
- `lib/features/snippets/ui/widgets/snippet_list_tile.dart` — Glass card with code block styling
- `lib/features/forwarding/ui/forwarding_screen.dart` — Apply glass cards, toggle styling
- `lib/features/forwarding/ui/widgets/forward_list_tile.dart` — Glass card, icon container, toggle
- `lib/features/settings/ui/settings_screen.dart` — Apply glass cards, section labels, slider
- `lib/features/terminal/ui/terminal_screen.dart` — Grid background, green-tinted toolbar
- `lib/features/hosts/ui/host_form_screen.dart` — Restyle form inputs, buttons

---

### Task 1: Create Color Token Constants

**Files:**
- Create: `nexterm/lib/core/theme/outdoor_colors.dart`

- [ ] **Step 1: Create the OutdoorColors class**

```dart
import 'dart:ui';

class OutdoorColors {
  OutdoorColors._();

  // Accent
  static const Color accent = Color(0xFF5CB85C);
  static const Color accentDim = Color(0x265CB85C); // 15% opacity
  static const Color accentGlow = Color(0x4D5CB85C); // 30% opacity

  // Dark mode
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkBgElevated = Color(0xFF161B22);
  static const Color darkSurface = Color(0xC7161B22); // 78% opacity
  static const Color darkSurfaceSolid = Color(0xFF1C2128);
  static const Color darkFg = Color(0xFFE6EDF3);
  static const Color darkFgSecondary = Color(0xFF8B949E);
  static const Color darkFgTertiary = Color(0xFF484F58);
  static const Color darkBorder = Color(0x9930363D); // 60% opacity
  static const Color darkNavBg = Color(0xB80D1117); // 72% opacity
  static const Color darkCardBg = Color(0xA6161B22); // 65% opacity
  static const Color darkInputBg = Color(0xCC1E242C); // 80% opacity
  static const Color darkTabInactive = Color(0xFF484F58);
  static const Color darkStatusOnline = Color(0xFF3FB950);
  static const Color darkStatusOffline = Color(0xFF484F58);
  static const Color darkTerminalBg = Color(0xFF0D1117);
  static const Color darkGlassBorder = Color(0x145CB85C); // 8% opacity

  // Light mode
  static const Color lightBg = Color(0xFFF5F0E6);
  static const Color lightBgElevated = Color(0xFFFAF8F3);
  static const Color lightSurface = Color(0xC7FFFFFF); // 78% opacity
  static const Color lightSurfaceSolid = Color(0xFFFFFFFF);
  static const Color lightFg = Color(0xFF1A1A1A);
  static const Color lightFgSecondary = Color(0xFF6B7280);
  static const Color lightFgTertiary = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0x14000000); // 8% opacity
  static const Color lightNavBg = Color(0xB8F5F0E6); // 72% opacity
  static const Color lightCardBg = Color(0xA6FFFFFF); // 65% opacity
  static const Color lightInputBg = Color(0x0A000000); // 4% opacity
  static const Color lightTabInactive = Color(0xFF9CA3AF);
  static const Color lightStatusOnline = Color(0xFF5CB85C);
  static const Color lightStatusOffline = Color(0xFFD1D5DB);
  static const Color lightTerminalBg = Color(0xFF1E1E2E);
  static const Color lightGlassBorder = Color(0x1F5CB85C); // 12% opacity

  // Terminal colors (shared)
  static const Color termPrompt = Color(0xFF5CB85C);
  static const Color termPath = Color(0xFF89B4FA);
  static const Color termCommand = Color(0xFFCDD6F4);
  static const Color termOutput = Color(0xFF8B949E);

  // Radius
  static const double radiusLg = 14.0;
  static const double radiusMd = 10.0;
  static const double radiusSm = 8.0;
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/core/theme/outdoor_colors.dart
git commit -m "feat(theme): add OutdoorColors token constants for Outdoor Tech Fusion palette"
```

---

### Task 2: Rewrite AppTheme with New Color Scheme

**Files:**
- Modify: `nexterm/lib/core/theme/app_theme.dart`

- [ ] **Step 1: Replace app_theme.dart with new theme definition**

```dart
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
```

- [ ] **Step 2: Verify the app still compiles**

Run: `cd nexterm && flutter analyze --no-pub 2>&1 | head -20`
Expected: No errors (warnings are OK)

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/core/theme/app_theme.dart
git commit -m "feat(theme): rewrite AppTheme with Outdoor Tech Fusion green palette"
```

---

### Task 3: Create CustomPainters for Decorative Layers

**Files:**
- Create: `nexterm/lib/shared/painters/topo_painter.dart`
- Create: `nexterm/lib/shared/painters/noise_painter.dart`
- Create: `nexterm/lib/shared/painters/ridge_painter.dart`

- [ ] **Step 1: Create the topographic contour painter**

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class TopoPainter extends CustomPainter {
  final bool isDark;
  TopoPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = OutdoorColors.accent.withValues(alpha: isDark ? 0.035 : 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final sx = size.width / 393;
    final sy = size.height / 852;

    // Top-right ellipse group
    _drawEllipseGroup(canvas, paint, Offset(280 * sx, 160 * sy), sx, sy, -12 * pi / 180, [
      (140, 60), (110, 45), (75, 28), (40, 14),
    ]);

    // Left-center ellipse group
    _drawEllipseGroup(canvas, paint, Offset(80 * sx, 380 * sy), sx, sy, 8 * pi / 180, [
      (130, 55), (100, 40), (65, 24), (30, 10),
    ]);

    // Bottom-right ellipse group
    _drawEllipseGroup(canvas, paint, Offset(320 * sx, 580 * sy), sx, sy, -18 * pi / 180, [
      (120, 50), (85, 35), (50, 18),
    ]);

    // Horizontal contour lines
    _drawContourLine(canvas, paint, size, 250 * sy, sx);
    _drawContourLine(canvas, paint, size, 650 * sy, sx);

    // Bottom ellipse group
    _drawEllipseGroup(canvas, paint, Offset(200 * sx, 780 * sy), sx, sy, 5 * pi / 180, [
      (100, 40), (60, 22),
    ]);
  }

  void _drawEllipseGroup(Canvas canvas, Paint paint, Offset center, double sx, double sy, double rotation, List<(double, double)> radii) {
    for (final (rx, ry) in radii) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      final rect = Rect.fromCenter(center: Offset.zero, width: rx * 2 * sx, height: ry * 2 * sy);
      canvas.drawOval(rect, paint);
      canvas.restore();
    }
  }

  void _drawContourLine(Canvas canvas, Paint paint, Size size, double y, double sx) {
    final path = Path();
    path.moveTo(-20 * sx, y);
    path.quadraticBezierTo(80 * sx, y - 20, 180 * sx, y + 10);
    path.quadraticBezierTo(280 * sx, y + 30, 350 * sx, y - 10);
    path.quadraticBezierTo(400 * sx, y - 20, size.width + 20, y);
    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(-20 * sx, y + 15);
    path2.quadraticBezierTo(90 * sx, y, 190 * sx, y + 25);
    path2.quadraticBezierTo(290 * sx, y + 45, 360 * sx, y + 5);
    path2.quadraticBezierTo(410 * sx, y - 10, size.width + 20, y + 15);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(TopoPainter oldDelegate) => oldDelegate.isDark != isDark;
}
```

- [ ] **Step 2: Create the noise texture painter**

```dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class NoisePainter extends CustomPainter {
  final bool isDark;
  NoisePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint();
    final opacity = isDark ? 0.012 : 0.008;

    for (int i = 0; i < 800; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final gray = random.nextInt(256);
      paint.color = Color.fromRGBO(gray, gray, gray, opacity);
      canvas.drawCircle(Offset(x, y), 0.5 + random.nextDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(NoisePainter oldDelegate) => oldDelegate.isDark != isDark;
}
```

- [ ] **Step 3: Create the mountain ridge painter**

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class RidgePainter extends CustomPainter {
  final bool isDark;
  RidgePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isDark ? 0.04 : 0.06;

    // Front ridge
    final frontPaint = Paint()
      ..color = OutdoorColors.accent.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.fill;

    final frontPath = Path();
    frontPath.moveTo(0, size.height);
    frontPath.lineTo(0, size.height * 0.7);
    frontPath.quadraticBezierTo(size.width * 0.05, size.height * 0.5, size.width * 0.12, size.height * 0.6);
    frontPath.quadraticBezierTo(size.width * 0.18, size.height * 0.7, size.width * 0.24, size.height * 0.46);
    frontPath.quadraticBezierTo(size.width * 0.3, size.height * 0.3, size.width * 0.38, size.height * 0.42);
    frontPath.quadraticBezierTo(size.width * 0.45, size.height * 0.54, size.width * 0.53, size.height * 0.35);
    frontPath.quadraticBezierTo(size.width * 0.6, size.height * 0.2, size.width * 0.66, size.height * 0.33);
    frontPath.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width * 0.83, size.height * 0.4);
    frontPath.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width * 0.97, size.height * 0.43);
    frontPath.lineTo(size.width, size.height * 0.46);
    frontPath.lineTo(size.width, size.height);
    frontPath.close();
    canvas.drawPath(frontPath, frontPaint);

    // Back ridge
    final backPaint = Paint()
      ..color = OutdoorColors.accent.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.fill;

    final backPath = Path();
    backPath.moveTo(0, size.height);
    backPath.lineTo(0, size.height * 0.8);
    backPath.quadraticBezierTo(size.width * 0.08, size.height * 0.63, size.width * 0.15, size.height * 0.73);
    backPath.quadraticBezierTo(size.width * 0.23, size.height * 0.83, size.width * 0.29, size.height * 0.58);
    backPath.quadraticBezierTo(size.width * 0.35, size.height * 0.42, size.width * 0.41, size.height * 0.54);
    backPath.quadraticBezierTo(size.width * 0.47, size.height * 0.67, size.width * 0.52, size.height * 0.46);
    backPath.quadraticBezierTo(size.width * 0.57, size.height * 0.29, size.width * 0.64, size.height * 0.42);
    backPath.quadraticBezierTo(size.width * 0.7, size.height * 0.54, size.width * 0.75, size.height * 0.4);
    backPath.quadraticBezierTo(size.width * 0.82, size.height * 0.27, size.width * 0.87, size.height * 0.46);
    backPath.quadraticBezierTo(size.width * 0.92, size.height * 0.6, size.width, size.height * 0.52);
    backPath.lineTo(size.width, size.height);
    backPath.close();
    canvas.drawPath(backPath, backPaint);
  }

  @override
  bool shouldRepaint(RidgePainter oldDelegate) => oldDelegate.isDark != isDark;
}
```

- [ ] **Step 4: Commit**

```bash
git add nexterm/lib/shared/painters/
git commit -m "feat(ui): add CustomPainters for topographic contours, noise, and mountain ridge"
```

---

### Task 4: Create Decorative Background Widget

**Files:**
- Create: `nexterm/lib/shared/widgets/decorative_background.dart`

- [ ] **Step 1: Create the DecorativeBackground widget**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/shared/painters/topo_painter.dart';
import 'package:nexterm/shared/painters/noise_painter.dart';
import 'package:nexterm/shared/painters/ridge_painter.dart';

class DecorativeBackground extends StatelessWidget {
  final Widget child;
  final bool showRidge;

  const DecorativeBackground({
    super.key,
    required this.child,
    this.showRidge = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base background color
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg,
          ),
        ),

        // Green glow - top right
        Positioned(
          top: -100,
          right: -100,
          width: 300,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  OutdoorColors.accentGlow,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Green glow - bottom left
        Positioned(
          bottom: 120,
          left: -80,
          width: 240,
          height: 240,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  OutdoorColors.accent.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Blue glow - right middle
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -60,
          width: 180,
          height: 180,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF89B4FA).withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Topographic contour lines
        Positioned.fill(
          child: CustomPaint(
            painter: TopoPainter(isDark: isDark),
          ),
        ),

        // Film grain noise
        Positioned.fill(
          child: CustomPaint(
            painter: NoisePainter(isDark: isDark),
          ),
        ),

        // Mountain ridge above bottom nav
        if (showRidge)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: CustomPaint(
              painter: RidgePainter(isDark: isDark),
            ),
          ),

        // Main content
        Positioned.fill(child: child),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/shared/widgets/decorative_background.dart
git commit -m "feat(ui): add DecorativeBackground widget with glows, contours, noise, ridge"
```

---

### Task 5: Create Shared UI Components (GlassCard, SectionLabel, OutdoorSearchBar)

**Files:**
- Create: `nexterm/lib/shared/widgets/glass_card.dart`
- Create: `nexterm/lib/shared/widgets/section_label.dart`
- Create: `nexterm/lib/shared/widgets/outdoor_search_bar.dart`

- [ ] **Step 1: Create GlassCard widget**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
              splashColor: OutdoorColors.accentDim,
              child: Container(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? OutdoorColors.darkCardBg : OutdoorColors.lightCardBg,
                  borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
                  border: Border.all(
                    color: isDark ? OutdoorColors.darkGlassBorder : OutdoorColors.lightGlassBorder,
                    width: 0.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      OutdoorColors.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.transparent,
                      OutdoorColors.accent.withValues(alpha: 0.04),
                    ],
                    stops: const [0.0, 0.4, 0.6, 1.0],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create SectionLabel widget**

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const SectionLabel({super.key, required this.title, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          // Glowing vertical bar
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: OutdoorColors.accent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: OutdoorColors.accentGlow,
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: OutdoorColors.accent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create OutdoorSearchBar widget**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class OutdoorSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const OutdoorSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? OutdoorColors.darkInputBg : OutdoorColors.lightInputBg,
              borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
              border: Border.all(
                color: isDark ? OutdoorColors.darkBorder : OutdoorColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 16,
                  color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add nexterm/lib/shared/widgets/glass_card.dart nexterm/lib/shared/widgets/section_label.dart nexterm/lib/shared/widgets/outdoor_search_bar.dart
git commit -m "feat(ui): add GlassCard, SectionLabel, and OutdoorSearchBar shared widgets"
```

---

### Task 6: Update AppScaffold with Decorative Background

**Files:**
- Modify: `nexterm/lib/shared/widgets/app_scaffold.dart`

- [ ] **Step 1: Update app_scaffold.dart to wrap with DecorativeBackground and restyle NavigationBar**

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final tabManager = ref.watch(tabManagerProvider);
    final hasActiveTerminal = navigationShell.currentIndex == 1 && tabManager.tabs.isNotEmpty;

    return DecorativeBackground(
      showRidge: !hasActiveTerminal,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        bottomNavigationBar: hasActiveTerminal
            ? null
            : NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
                },
                destinations: [
                  NavigationDestination(icon: const Icon(Icons.lock_outlined), selectedIcon: const Icon(Icons.lock), label: l.nav_vaults),
                  NavigationDestination(icon: const Icon(Icons.terminal_outlined), selectedIcon: const Icon(Icons.terminal), label: l.nav_terminal),
                  NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l.nav_settings),
                ],
              ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/shared/widgets/app_scaffold.dart
git commit -m "feat(ui): wrap AppScaffold with DecorativeBackground and transparent Scaffold"
```

---

### Task 7: Update StatusIndicator with Glow and Pulse Animation

**Files:**
- Modify: `nexterm/lib/shared/widgets/status_indicator.dart`

- [ ] **Step 1: Rewrite status_indicator.dart with glow and pulse ring**

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class StatusIndicator extends StatefulWidget {
  final ConnectionStatus status;
  final double size;
  const StatusIndicator({super.key, required this.status, this.size = 10});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut)),
    );
    if (_isOnline) _controller.repeat();
  }

  @override
  void didUpdateWidget(StatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOnline && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_isOnline && _controller.isAnimating) {
      _controller.stop();
    }
  }

  bool get _isOnline => widget.status == ConnectionStatus.connected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (widget.status) {
      ConnectionStatus.connected => isDark ? OutdoorColors.darkStatusOnline : OutdoorColors.lightStatusOnline,
      ConnectionStatus.connecting => const Color(0xFFF9E2AF),
      ConnectionStatus.error => const Color(0xFFF38BA8),
      ConnectionStatus.disconnected => isDark ? OutdoorColors.darkStatusOffline : OutdoorColors.lightStatusOffline,
    };

    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isOnline)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: OutdoorColors.accent, width: 1),
                        ),
                      ),
                    ),
                  );
                },
              ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: _isOnline
                    ? [BoxShadow(color: OutdoorColors.accentGlow, blurRadius: 8, spreadRadius: 0)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/shared/widgets/status_indicator.dart
git commit -m "feat(ui): add glow and pulse ring animation to StatusIndicator"
```

---

### Task 8: Restyle VaultsScreen

**Files:**
- Modify: `nexterm/lib/features/vaults/ui/vaults_screen.dart`

- [ ] **Step 1: Replace vaults_screen.dart with glass card style and large nav title**

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';
import 'package:nexterm/shared/widgets/section_label.dart';

class VaultsScreen extends StatelessWidget {
  const VaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          children: [
            // Large title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _NavTitle(title: l.vaults_title),
            ),

            SectionLabel(title: l.vaults_hosts),
            GlassCard(
              onTap: () => context.push('/vaults/hosts'),
              child: _VaultItem(
                icon: Icons.dns_outlined,
                title: l.vaults_hosts,
              ),
            ),
            GlassCard(
              onTap: () => context.push('/vaults/forwarding'),
              child: _VaultItem(
                icon: Icons.swap_horiz_outlined,
                title: l.vaults_portForwarding,
              ),
            ),
            GlassCard(
              onTap: () => context.push('/vaults/snippets'),
              child: _VaultItem(
                icon: Icons.bolt_outlined,
                title: l.vaults_snippets,
              ),
            ),

            SectionLabel(title: l.vaults_keychain),
            GlassCard(
              onTap: () => context.push('/vaults/keys'),
              child: _VaultItem(
                icon: Icons.vpn_key_outlined,
                title: l.vaults_keychain,
              ),
            ),
            GlassCard(
              onTap: () => context.push('/vaults/known-hosts'),
              child: _VaultItem(
                icon: Icons.wifi_tethering_outlined,
                title: l.vaults_knownHosts,
              ),
            ),

            SectionLabel(title: l.vaults_logs),
            GlassCard(
              onTap: () => context.push('/vaults/logs'),
              child: _VaultItem(
                icon: Icons.receipt_long_outlined,
                title: l.vaults_logs,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NavTitle extends StatelessWidget {
  final String title;
  const _NavTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: const LinearGradient(
              colors: [OutdoorColors.accent, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

class _VaultItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _VaultItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: OutdoorColors.accentDim,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: OutdoorColors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
            ),
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 18,
          color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/vaults/ui/vaults_screen.dart
git commit -m "feat(ui): restyle VaultsScreen with glass cards, large title, section labels"
```

---

### Task 9: Restyle HostsScreen and HostListTile

**Files:**
- Modify: `nexterm/lib/features/hosts/ui/hosts_screen.dart`
- Modify: `nexterm/lib/features/hosts/ui/widgets/host_list_tile.dart`
- Modify: `nexterm/lib/features/hosts/ui/widgets/host_search_bar.dart`

- [ ] **Step 1: Update HostsScreen to use transparent scaffold, large title, and section labels**

In `hosts_screen.dart`, change the `build` method's `Scaffold` and `AppBar` to match the outdoor style. Key changes:
- `Scaffold(backgroundColor: Colors.transparent, ...)`
- Replace standard `AppBar` with a custom header containing `_NavTitle` and action buttons
- Replace `_SectionHeader` with `SectionLabel` widget
- Replace `HostSearchBar` usage with `OutdoorSearchBar`

Replace the `_SectionHeader` class at the bottom of the file with:
```dart
// Remove _SectionHeader class - now using shared SectionLabel widget
```

Update the build method `Scaffold`:
```dart
return Scaffold(
  backgroundColor: Colors.transparent,
  appBar: _isSelectionMode
      ? AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _exitSelectionMode),
          title: Text(l.hosts_selectedCount(_selectedIds.length)),
          actions: [...same actions...],
        )
      : AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.of(context).pop()),
          title: Text(l.hosts_title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          actions: [
            IconButton(
              icon: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: OutdoorColors.accentDim),
                child: const Icon(Icons.add, size: 16, color: OutdoorColors.accent),
              ),
              onPressed: () => context.push('/vaults/hosts/add'),
            ),
          ],
        ),
  body: Column(...same structure...),
);
```

Replace `_SectionHeader` references with `SectionLabel(title: ...)`.

- [ ] **Step 2: Rewrite host_list_tile.dart to use GlassCard**

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';
import 'package:nexterm/shared/widgets/status_indicator.dart';

class HostListTile extends StatelessWidget {
  final HostEntity host;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onSelectionToggle;
  final int activeConnectionCount;

  const HostListTile({
    super.key,
    required this.host,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onSelectionToggle,
    this.activeConnectionCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authLabel = host.authMethod.localizedName(AppLocalizations.of(context)!);
    final subtitle = '${host.username}@${host.hostname}:${host.port}';

    return GlassCard(
      onTap: isSelectionMode ? onSelectionToggle : onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: isSelected ? OutdoorColors.accent : (isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
              ),
            )
          else
            StatusIndicator(status: ConnectionStatus.disconnected, size: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        host.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (activeConnectionCount > 0) ...[
                      const SizedBox(width: 6),
                      _ActiveConnectionBadge(count: activeConnectionCount),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (host.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: host.tags.map((tag) => _TagChip(tag: tag)).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (host.authMethod == AuthMethod.key)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: OutdoorColors.accentDim,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                authLabel,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: OutdoorColors.accent),
              ),
            ),
          GestureDetector(
            onTap: onToggleFavorite,
            child: Icon(
              host.isFavorite ? Icons.star : Icons.star_border,
              size: 20,
              color: host.isFavorite ? OutdoorColors.accent : (isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveConnectionBadge extends StatelessWidget {
  final int count;
  const _ActiveConnectionBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: OutdoorColors.accentDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OutdoorColors.accent.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: OutdoorColors.accent, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OutdoorColors.accent, height: 1)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: OutdoorColors.accentDim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(tag, style: const TextStyle(fontSize: 11, color: OutdoorColors.accent)),
    );
  }
}
```

- [ ] **Step 3: Update host_search_bar.dart to use OutdoorSearchBar**

Check the current file and either replace it with a thin wrapper around `OutdoorSearchBar` or update imports in `hosts_screen.dart` to use `OutdoorSearchBar` directly.

- [ ] **Step 4: Commit**

```bash
git add nexterm/lib/features/hosts/
git commit -m "feat(ui): restyle HostsScreen and HostListTile with glass cards and green accent"
```

---

### Task 10: Restyle KeysScreen

**Files:**
- Modify: `nexterm/lib/features/keys/ui/keys_screen.dart`
- Modify: `nexterm/lib/features/keys/ui/widgets/key_list_tile.dart`

- [ ] **Step 1: Update keys_screen.dart**

Key changes:
- `Scaffold(backgroundColor: Colors.transparent)`
- `AppBar(backgroundColor: Colors.transparent)`
- Add action button with green circular container style

- [ ] **Step 2: Rewrite key_list_tile.dart with GlassCard and icon with sheen**

The key icon container should have `OutdoorColors.accentDim` background with a subtle diagonal gradient overlay (the "sheen" effect from the design spec).

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/keys/
git commit -m "feat(ui): restyle KeysScreen with glass cards and icon sheen"
```

---

### Task 11: Restyle SnippetsScreen and SnippetListTile

**Files:**
- Modify: `nexterm/lib/features/snippets/ui/snippets_screen.dart`
- Modify: `nexterm/lib/features/snippets/ui/widgets/snippet_list_tile.dart`

- [ ] **Step 1: Update snippets_screen.dart**

- `Scaffold(backgroundColor: Colors.transparent)`
- `AppBar(backgroundColor: Colors.transparent)`
- Replace `_SectionHeader` with `SectionLabel`
- Add `OutdoorSearchBar` for search

- [ ] **Step 2: Restyle snippet_list_tile.dart**

Replace `Card` with `GlassCard`. Style the code block with `OutdoorColors.darkInputBg`/`lightInputBg` background and monospace font. Add language tag badge with `accentDim` background.

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/snippets/
git commit -m "feat(ui): restyle SnippetsScreen with glass cards and code block styling"
```

---

### Task 12: Restyle ForwardingScreen and ForwardListTile

**Files:**
- Modify: `nexterm/lib/features/forwarding/ui/forwarding_screen.dart`
- Modify: `nexterm/lib/features/forwarding/ui/widgets/forward_list_tile.dart`

- [ ] **Step 1: Update forwarding_screen.dart**

- `Scaffold(backgroundColor: Colors.transparent)`
- `AppBar(backgroundColor: Colors.transparent)`
- Replace `_SectionHeader` with `SectionLabel`

- [ ] **Step 2: Restyle forward_list_tile.dart**

Replace `Card` with `GlassCard`. Replace the toggle button with a custom toggle matching the design spec (44x26px, `OutdoorColors.accent` when on, `darkFgTertiary` when off, white 22x22 thumb with shadow). Add icon container with `accentDim` bg.

- [ ] **Step 3: Commit**

```bash
git add nexterm/lib/features/forwarding/
git commit -m "feat(ui): restyle ForwardingScreen with glass cards and custom toggle"
```

---

### Task 13: Restyle SettingsScreen

**Files:**
- Modify: `nexterm/lib/features/settings/ui/settings_screen.dart`

- [ ] **Step 1: Update settings_screen.dart**

Key changes:
- `Scaffold(backgroundColor: Colors.transparent)`
- `AppBar(backgroundColor: Colors.transparent)`
- Replace `_SectionHeader` with `SectionLabel`
- Wrap each settings group in a single `GlassCard` containing multiple settings items (matching the design where a glass card contains the group)
- Each settings item has: icon in green container (32x32, accentDim bg) + label + value/chevron
- The slider track uses `OutdoorColors.accent`
- Version number at bottom in `darkFgTertiary`/`lightFgTertiary`

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/settings/ui/settings_screen.dart
git commit -m "feat(ui): restyle SettingsScreen with glass cards and green accents"
```

---

### Task 14: Restyle TerminalScreen

**Files:**
- Modify: `nexterm/lib/features/terminal/ui/terminal_screen.dart`

- [ ] **Step 1: Update terminal_screen.dart**

Key changes:
- Background stays dark (`OutdoorColors.darkTerminalBg` always, regardless of theme)
- The `_EmptyState` uses green accent for icons/text hints
- No structural changes needed since terminal already uses black bg

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/terminal/ui/terminal_screen.dart
git commit -m "feat(ui): adjust TerminalScreen colors to Outdoor Tech Fusion palette"
```

---

### Task 15: Restyle HostFormScreen

**Files:**
- Modify: `nexterm/lib/features/hosts/ui/host_form_screen.dart`

- [ ] **Step 1: Update host_form_screen.dart**

Key changes:
- `Scaffold(backgroundColor: Colors.transparent)`
- `AppBar(backgroundColor: Colors.transparent)` with "取消" and "保存" styled in accent green
- Wrap form groups in `GlassCard` with `padding: EdgeInsets.all(16)`
- Form labels use `OutdoorColors.darkFgSecondary`/`lightFgSecondary`
- Input fields use the `InputDecorationTheme` from the updated theme
- Auth method buttons: `btn-secondary` style with `accentDim` + accent border when active
- "Test Connection" button: full-width, `OutdoorColors.accent` background, white text
- Section labels use `SectionLabel` widget

- [ ] **Step 2: Commit**

```bash
git add nexterm/lib/features/hosts/ui/host_form_screen.dart
git commit -m "feat(ui): restyle HostFormScreen with glass cards and outdoor form styling"
```

---

### Task 16: Final Verification and Cleanup

- [ ] **Step 1: Run flutter analyze**

Run: `cd nexterm && flutter analyze --no-pub 2>&1 | tail -20`
Expected: No errors

- [ ] **Step 2: Run the app on simulator**

Run: `cd nexterm && flutter run` (or use existing running instance)
Verify: Navigate through all tabs and screens. Check both dark and light themes.

- [ ] **Step 3: Fix any visual issues found during testing**

Common issues to check:
- Text readability on glass cards (contrast ratio)
- BackdropFilter performance (if laggy, reduce blur sigma)
- Edge cases with empty states
- Keyboard toolbar visibility in terminal

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "fix(ui): address visual issues from Outdoor Tech Fusion restyle review"
```

---

## Notes for Implementer

- **Performance**: `BackdropFilter` with `blur(12)` can be expensive. If scrolling is janky, consider using `RepaintBoundary` around the background layers or reducing blur values.
- **Import cleanup**: After converting from `Card` to `GlassCard`, remove unused `Card`-related imports.
- **The terminal screen** is special — it always uses a dark background regardless of theme mode. Don't make it transparent.
- **Existing functionality must not change**. If any screen's logic depends on `Card` widget's InkWell behavior, ensure `GlassCard` provides the same tap/long-press callbacks.
- **Test on both iOS and Android** if possible — BackdropFilter rendering may differ.
