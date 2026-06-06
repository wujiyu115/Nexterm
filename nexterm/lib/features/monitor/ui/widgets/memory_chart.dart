import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/features/monitor/models/system_metrics.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class MemoryChart extends StatelessWidget {
  final List<SystemSnapshot> history;

  const MemoryChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final latest = history.last.memory;
    final usagePercent = latest.usagePercent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.monitor_memoryUsage, style: theme.textTheme.titleSmall),
                Text(
                  '${usagePercent.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _colorForUsage(usagePercent),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${l.monitor_used}: ${_formatBytes(latest.usedBytes)} / '
              '${l.monitor_total}: ${_formatBytes(latest.totalBytes)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      strokeWidth: 0.5,
                    ),
                    drawVerticalLine: false,
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildSpots(),
                      isCurved: true,
                      color: _colorForUsage(usagePercent),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _colorForUsage(usagePercent).withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                  lineTouchData: const LineTouchData(enabled: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return List.generate(history.length, (i) {
      return FlSpot(i.toDouble(), history[i].memory.usagePercent);
    });
  }

  Color _colorForUsage(double usage) {
    if (usage > 85) return Colors.red;
    if (usage > 70) return Colors.orange;
    return Colors.blue;
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}
