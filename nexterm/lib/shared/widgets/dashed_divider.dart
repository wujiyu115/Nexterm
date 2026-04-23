import 'package:flutter/material.dart';

/// A horizontal dashed line used as a soft separator.
///
/// Renders a 1px-tall row of short dash segments. The default dash/gap pattern
/// is tuned for compact UI surfaces like menus and dialog list separators.
class DashedDivider extends StatelessWidget {
  final Color color;
  final double dashWidth;
  final double gapWidth;
  final double thickness;
  final EdgeInsetsGeometry padding;

  const DashedDivider({
    super.key,
    required this.color,
    this.dashWidth = 4,
    this.gapWidth = 3,
    this.thickness = 1,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: thickness,
        width: double.infinity,
        child: CustomPaint(
          painter: _DashedLinePainter(
            color: color,
            dashWidth: dashWidth,
            gapWidth: gapWidth,
            thickness: thickness,
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double gapWidth;
  final double thickness;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.gapWidth,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.gapWidth != gapWidth ||
      old.thickness != thickness;
}
