import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/features/git/models/git_graph.dart';

class GraphLayoutService {
  static List<GraphRow> computeLayout(List<GitCommit> commits) {
    final rows = <GraphRow>[];
    final lanes = <String?>[];
    final shaToLane = <String, int>{};
    final shaToColor = <String, int>{};
    var nextColor = 0;

    for (final commit in commits) {
      int laneIndex;
      if (shaToLane.containsKey(commit.sha)) {
        laneIndex = shaToLane[commit.sha]!;
      } else {
        laneIndex = lanes.indexOf(null);
        if (laneIndex == -1) {
          laneIndex = lanes.length;
          lanes.add(null);
        }
        shaToColor[commit.sha] = nextColor % graphLaneColors.length;
        nextColor++;
      }

      final colorIndex = shaToColor[commit.sha] ?? 0;
      lanes[laneIndex] = commit.sha;
      final lineSegments = <GraphLine>[];

      // Draw straight lines for all other active lanes
      for (var i = 0; i < lanes.length; i++) {
        if (i == laneIndex) continue;
        if (lanes[i] != null) {
          lineSegments.add(GraphLine(
            fromLane: i,
            toLane: i,
            type: GraphLineType.straight,
            colorIndex: shaToColor[lanes[i]] ?? 0,
          ));
        }
      }

      // Free the current lane before assigning parents
      lanes[laneIndex] = null;

      if (commit.parentShas.isNotEmpty) {
        // First parent: continues in the same lane if possible
        final firstParent = commit.parentShas[0];
        if (!shaToLane.containsKey(firstParent)) {
          lanes[laneIndex] = firstParent;
          shaToLane[firstParent] = laneIndex;
          shaToColor[firstParent] = colorIndex;
          lineSegments.add(GraphLine(
            fromLane: laneIndex,
            toLane: laneIndex,
            type: GraphLineType.straight,
            colorIndex: colorIndex,
          ));
        } else {
          final parentLane = shaToLane[firstParent]!;
          final type = parentLane < laneIndex
              ? GraphLineType.mergeLeft
              : GraphLineType.mergeRight;
          lineSegments.add(GraphLine(
            fromLane: laneIndex,
            toLane: parentLane,
            type: type,
            colorIndex: colorIndex,
          ));
        }

        // Additional parents: fork into new lanes or merge into existing ones
        for (var p = 1; p < commit.parentShas.length; p++) {
          final parent = commit.parentShas[p];
          if (!shaToLane.containsKey(parent)) {
            var newLane = lanes.indexOf(null);
            if (newLane == -1) {
              newLane = lanes.length;
              lanes.add(null);
            }
            lanes[newLane] = parent;
            shaToLane[parent] = newLane;
            final pColor = nextColor % graphLaneColors.length;
            shaToColor[parent] = pColor;
            nextColor++;
            lineSegments.add(GraphLine(
              fromLane: laneIndex,
              toLane: newLane,
              type: GraphLineType.fork,
              colorIndex: pColor,
            ));
          } else {
            final parentLane = shaToLane[parent]!;
            final type = parentLane < laneIndex
                ? GraphLineType.mergeLeft
                : GraphLineType.mergeRight;
            lineSegments.add(GraphLine(
              fromLane: laneIndex,
              toLane: parentLane,
              type: type,
              colorIndex: shaToColor[parent] ?? 0,
            ));
          }
        }
      }

      // Trim trailing empty lanes
      while (lanes.isNotEmpty && lanes.last == null) {
        lanes.removeLast();
      }

      rows.add(GraphRow(
        commit: commit,
        laneIndex: laneIndex,
        colorIndex: colorIndex,
        lines: lineSegments,
        activeLaneCount: lanes.length,
      ));
    }
    return rows;
  }
}
