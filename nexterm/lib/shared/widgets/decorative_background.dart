import 'dart:math';
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

  static const _seed = 42;

  // 3 columns x 3 rows = 9 cells, pick 7 to place glows
  static const _cols = 3;
  static const _rows = 3;
  static const _glowCount = 7;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screen = MediaQuery.of(context).size;
    final rng = Random(_seed);

    final cellW = screen.width / _cols;
    final cellH = screen.height / _rows;

    // Generate all cell indices and shuffle, then take _glowCount
    final cells = List.generate(_cols * _rows, (i) => i);
    cells.shuffle(rng);
    final selected = cells.take(_glowCount).toList();

    final glows = selected.map((cellIndex) {
      final col = cellIndex % _cols;
      final row = cellIndex ~/ _cols;
      final size = 160.0 + rng.nextDouble() * 120;
      final x = col * cellW + rng.nextDouble() * (cellW - size * 0.4);
      final y = row * cellH + rng.nextDouble() * (cellH - size * 0.4);
      final alpha = 0.04 + rng.nextDouble() * 0.06;
      return _GlowSpec(x: x, y: y, size: size, alpha: alpha);
    }).toList();

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg,
          ),
        ),

        for (final g in glows)
          Positioned(
            left: g.x,
            top: g.y,
            width: g.size,
            height: g.size,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    OutdoorColors.accent.withValues(alpha: g.alpha),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        Positioned.fill(
          child: CustomPaint(painter: TopoPainter(isDark: isDark)),
        ),

        Positioned.fill(
          child: CustomPaint(painter: NoisePainter(isDark: isDark)),
        ),

        if (showRidge)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: CustomPaint(painter: RidgePainter(isDark: isDark)),
          ),

        Positioned.fill(child: child),
      ],
    );
  }
}

class _GlowSpec {
  final double x, y, size, alpha;
  const _GlowSpec({required this.x, required this.y, required this.size, required this.alpha});
}
