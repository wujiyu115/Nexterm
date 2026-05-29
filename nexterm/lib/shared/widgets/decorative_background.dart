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
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? OutdoorColors.darkBg : OutdoorColors.lightBg,
          ),
        ),

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

        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: -60,
          width: 180,
          height: 180,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x0F89B4FA),
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
