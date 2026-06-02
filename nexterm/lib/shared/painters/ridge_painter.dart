import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class RidgePainter extends CustomPainter {
  final ThemePalette palette;
  const RidgePainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = palette.brightness == Brightness.dark;
    final opacity = isDark ? 0.04 : 0.06;

    final frontPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.5)
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

    final backPaint = Paint()
      ..color = palette.accent.withValues(alpha: opacity * 0.3)
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
  bool shouldRepaint(covariant RidgePainter oldDelegate) => oldDelegate.palette != palette;
}
