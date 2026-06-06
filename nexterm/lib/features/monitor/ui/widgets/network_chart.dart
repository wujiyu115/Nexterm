import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/features/monitor/models/system_metrics.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class NetworkChart extends StatelessWidget {
  final List<SystemSnapshot> history;

  const NetworkChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final latest = history.last.network;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.monitor_network, style: theme.textTheme.titleSmall),
                Row(
                  children: [
                    _SpeedBadge(
                      label: l.monitor_rxSpeed,
                      speed: latest.rxBytesPerSec,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _SpeedBadge(
                      label: l.monitor_txSpeed,
                      speed: latest.txBytesPerSec,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: _calcInterval(),
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
                      spots: _buildRxSpots(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: _buildTxSpots(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
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

  List<FlSpot> _buildRxSpots() {
    return List.generate(history.length, (i) {
      return FlSpot(i.toDouble(), history[i].network.rxBytesPerSec.toDouble());
    });
  }

  List<FlSpot> _buildTxSpots() {
    return List.generate(history.length, (i) {
      return FlSpot(i.toDouble(), history[i].network.txBytesPerSec.toDouble());
    });
  }

  double _calcInterval() {
    double maxVal = 0;
    for (final s in history) {
      final rx = s.network.rxBytesPerSec.toDouble();
      final tx = s.network.txBytesPerSec.toDouble();
      if (rx > maxVal) maxVal = rx;
      if (tx > maxVal) maxVal = tx;
    }
    if (maxVal <= 0) return 1024;
    return (maxVal / 4).ceilToDouble();
  }
}

class _SpeedBadge extends StatelessWidget {
  final String label;
  final int speed;
  final Color color;

  const _SpeedBadge({
    required this.label,
    required this.speed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${_formatSpeed(speed)}',
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }

  String _formatSpeed(int bytesPerSec) {
    if (bytesPerSec >= 1024 * 1024) {
      return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    if (bytesPerSec >= 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '$bytesPerSec B/s';
  }
}
