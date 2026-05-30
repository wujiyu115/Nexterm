import 'dart:ui';
import 'package:nexterm/features/git/models/git_commit.dart';

const graphLaneColors = [
  Color(0xFF4A9EEA),
  Color(0xFFE5A84B),
  Color(0xFF6BCB77),
  Color(0xFFE06C75),
  Color(0xFFC678DD),
  Color(0xFF56B6C2),
  Color(0xFFD19A66),
  Color(0xFF98C379),
];

enum GraphLineType { straight, mergeLeft, mergeRight, fork }

class GraphLine {
  final int fromLane;
  final int toLane;
  final GraphLineType type;
  final int colorIndex;
  const GraphLine({
    required this.fromLane,
    required this.toLane,
    required this.type,
    required this.colorIndex,
  });
}

class GraphRow {
  final GitCommit commit;
  final int laneIndex;
  final int colorIndex;
  final List<GraphLine> lines;
  final int activeLaneCount;
  const GraphRow({
    required this.commit,
    required this.laneIndex,
    required this.colorIndex,
    required this.lines,
    required this.activeLaneCount,
  });
}
