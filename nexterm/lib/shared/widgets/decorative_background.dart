import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
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
    final p = Theme.of(context).extension<ThemePalette>()!;
    final isDark = p.brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  p.bg,
                  Color.alphaBlend(p.accent.withValues(alpha: 0.08), p.bg),
                ],
              ),
            ),
          ),
        ),

        Positioned.fill(
          child: CustomPaint(painter: TopoPainter(p)),
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
            child: CustomPaint(painter: RidgePainter(p)),
          ),

        Positioned.fill(child: child),
      ],
    );
  }
}
