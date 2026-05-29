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

    _drawEllipseGroup(canvas, paint, Offset(280 * sx, 160 * sy), sx, sy, -12 * pi / 180, [
      (140, 60), (110, 45), (75, 28), (40, 14),
    ]);

    _drawEllipseGroup(canvas, paint, Offset(80 * sx, 380 * sy), sx, sy, 8 * pi / 180, [
      (130, 55), (100, 40), (65, 24), (30, 10),
    ]);

    _drawEllipseGroup(canvas, paint, Offset(320 * sx, 580 * sy), sx, sy, -18 * pi / 180, [
      (120, 50), (85, 35), (50, 18),
    ]);

    _drawContourLine(canvas, paint, size, 250 * sy, sx);
    _drawContourLine(canvas, paint, size, 650 * sy, sx);

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
