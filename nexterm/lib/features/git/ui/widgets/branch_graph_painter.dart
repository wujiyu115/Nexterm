import 'package:flutter/material.dart';
import 'package:nexterm/features/git/models/git_graph.dart';

class BranchGraphPainter extends CustomPainter {
  final List<GraphRow> rows;
  final double rowHeight;
  final double laneWidth;
  final double dotRadius;

  BranchGraphPainter({
    required this.rows,
    this.rowHeight = 56.0,
    this.laneWidth = 20.0,
    this.dotRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final cy = i * rowHeight + rowHeight / 2;
      for (final line in row.lines) {
        final paint = Paint()
          ..color = graphLaneColors[line.colorIndex % graphLaneColors.length]
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        final fromX = line.fromLane * laneWidth + laneWidth / 2;
        final toX = line.toLane * laneWidth + laneWidth / 2;
        switch (line.type) {
          case GraphLineType.straight:
            canvas.drawLine(
              Offset(toX, cy + rowHeight / 2),
              Offset(toX, cy - rowHeight / 2),
              paint,
            );
          case GraphLineType.mergeLeft:
          case GraphLineType.mergeRight:
            final path = Path()
              ..moveTo(fromX, cy)
              ..cubicTo(fromX, cy + rowHeight * 0.4, toX,
                  cy + rowHeight * 0.1, toX, cy + rowHeight / 2);
            canvas.drawPath(path, paint);
          case GraphLineType.fork:
            final path = Path()
              ..moveTo(fromX, cy)
              ..cubicTo(fromX, cy + rowHeight * 0.4, toX,
                  cy + rowHeight * 0.1, toX, cy + rowHeight / 2);
            canvas.drawPath(path, paint);
        }
      }
      final cx = row.laneIndex * laneWidth + laneWidth / 2;
      final dotColor =
          graphLaneColors[row.colorIndex % graphLaneColors.length];
      canvas.drawCircle(
        Offset(cx, cy),
        dotRadius + 1,
        Paint()..color = Colors.black.withValues(alpha: 0.5),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        dotRadius,
        Paint()..color = dotColor,
      );
    }
  }

  @override
  bool shouldRepaint(BranchGraphPainter oldDelegate) =>
      rows != oldDelegate.rows;
}
