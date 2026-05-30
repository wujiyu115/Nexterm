import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_graph.dart';
import 'package:nexterm/features/git/providers/git_provider.dart';
import 'package:nexterm/features/git/ui/widgets/branch_graph_painter.dart';
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
  final _scrollController = ScrollController();
  static const _rowHeight = 56.0;
  static const _laneWidth = 20.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _maxLanes {
    var max = 1;
    for (final row in widget.rows) {
      if (row.activeLaneCount > max) max = row.activeLaneCount;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final graphWidth = (_maxLanes + 1) * _laneWidth;
    final totalHeight = widget.rows.length * _rowHeight;

    return Scaffold(
      appBar: AppBar(title: Text(l.git_branchGraph)),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: graphWidth,
                height: totalHeight,
                child: CustomPaint(
                  size: Size(graphWidth, totalHeight),
                  painter: BranchGraphPainter(
                    rows: widget.rows,
                    rowHeight: _rowHeight,
                    laneWidth: _laneWidth,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: widget.rows.map((row) {
                    final commit = row.commit;
                    final refs = commit.refs
                        .where((r) => r.isNotEmpty)
                        .toList();
                    return GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CommitDetailSheet(commit: commit, gitNotifier: widget.gitNotifier),
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                      height: _rowHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                color: isDark
                                    ? OutdoorColors.darkFg
                                    : OutdoorColors.lightFg,
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: graphLaneColors[
                                                row.colorIndex %
                                                    graphLaneColors.length],
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          ref.replaceFirst('HEAD -> ', ''),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: graphLaneColors[
                                                row.colorIndex %
                                                    graphLaneColors.length],
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
                                    color: isDark
                                        ? OutdoorColors.darkFgTertiary
                                        : OutdoorColors.lightFgTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
