import 'dart:math';
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
