import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_graph.dart';
import 'package:nexterm/features/git/providers/git_provider.dart';
import 'package:nexterm/features/git/ui/widgets/commit_detail_sheet.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class BranchGraphScreen extends StatefulWidget {
  final List<GraphRow> rows;
  final GitNotifier gitNotifier;
  const BranchGraphScreen({super.key, required this.rows, required this.gitNotifier});
  @override
  State<BranchGraphScreen> createState() => _BranchGraphScreenState();
}

class _BranchGraphScreenState extends State<BranchGraphScreen> {
  static const _rowHeight = 56.0;
  static const _laneWidth = 20.0;

  late List<GraphRow> _rows;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _rows = widget.rows;
    _hasMore = widget.rows.length >= 200;
  }

  int get _maxLanes {
    var max = 1;
    for (final row in _rows) {
      if (row.activeLaneCount > max) max = row.activeLaneCount;
    }
    return max;
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final newRows = await widget.gitNotifier.loadMoreGraph(
        skip: _rows.length,
        existingRows: _rows,
      );
      if (mounted) {
        setState(() {
          _hasMore = newRows.length > _rows.length;
          _rows = newRows;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final graphWidth = (_maxLanes + 1) * _laneWidth;
    final itemCount = _rows.length + (_hasMore ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: Text(l.git_branchGraph)),
      body: ListView.builder(
        itemCount: itemCount,
        itemExtent: _rowHeight,
        itemBuilder: (context, index) {
          if (index >= _rows.length) {
            _loadMore();
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            );
          }

          final row = _rows[index];
          final commit = row.commit;
          final refs = commit.refs.where((r) => r.isNotEmpty).toList();

          return GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CommitDetailSheet(commit: commit, gitNotifier: widget.gitNotifier),
            ),
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: _RowGraphPainter(
                row: row,
                prevRow: index > 0 ? _rows[index - 1] : null,
                nextRow: index < _rows.length - 1 ? _rows[index + 1] : null,
                rowHeight: _rowHeight,
                laneWidth: _laneWidth,
                graphWidth: graphWidth,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: graphWidth + 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      commit.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          commit.shortSha,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'JetBrains Mono',
                            color: OutdoorColors.accent,
                          ),
                        ),
                        if (refs.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          ...refs.take(2).map(
                            (ref) => Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: graphLaneColors[row.colorIndex % graphLaneColors.length],
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  ref.replaceFirst('HEAD -> ', ''),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: graphLaneColors[row.colorIndex % graphLaneColors.length],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          commit.authorName,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RowGraphPainter extends CustomPainter {
  final GraphRow row;
  final GraphRow? prevRow;
  final GraphRow? nextRow;
  final double rowHeight;
  final double laneWidth;
  final double graphWidth;
  static const _dotRadius = 4.0;

  _RowGraphPainter({
    required this.row,
    this.prevRow,
    this.nextRow,
    required this.rowHeight,
    required this.laneWidth,
    required this.graphWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cy = rowHeight / 2;

    for (final line in row.lines) {
      final paint = Paint()
        ..color = graphLaneColors[line.colorIndex % graphLaneColors.length]
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      final fromX = line.fromLane * laneWidth + laneWidth / 2;
      final toX = line.toLane * laneWidth + laneWidth / 2;
      switch (line.type) {
        case GraphLineType.straight:
          canvas.drawLine(Offset(toX, cy + rowHeight / 2), Offset(toX, cy - rowHeight / 2), paint);
        case GraphLineType.mergeLeft:
        case GraphLineType.mergeRight:
          final path = Path()
            ..moveTo(fromX, cy)
            ..cubicTo(fromX, cy + rowHeight * 0.4, toX, cy + rowHeight * 0.1, toX, cy + rowHeight / 2);
          canvas.drawPath(path, paint);
        case GraphLineType.fork:
          final path = Path()
            ..moveTo(fromX, cy)
            ..cubicTo(fromX, cy + rowHeight * 0.4, toX, cy + rowHeight * 0.1, toX, cy + rowHeight / 2);
          canvas.drawPath(path, paint);
      }
    }

    final cx = row.laneIndex * laneWidth + laneWidth / 2;
    final dotColor = graphLaneColors[row.colorIndex % graphLaneColors.length];
    canvas.drawCircle(Offset(cx, cy), _dotRadius + 1, Paint()..color = Colors.black.withValues(alpha: 0.5));
    canvas.drawCircle(Offset(cx, cy), _dotRadius, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(_RowGraphPainter oldDelegate) => row != oldDelegate.row;
}
