import 'package:flutter/material.dart';
import 'package:nexterm/features/monitor/models/system_metrics.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class DiskUsageCard extends StatelessWidget {
  final List<DiskPartition> disks;

  const DiskUsageCard({super.key, required this.disks});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.monitor_disk, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            ...disks.map((disk) => _buildDiskRow(context, disk)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiskRow(BuildContext context, DiskPartition disk) {
    final theme = Theme.of(context);
    final usage = disk.usagePercent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  disk.mountPoint,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${_formatBytes(disk.usedBytes)} / ${_formatBytes(disk.totalBytes)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usage / 100,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(_colorForUsage(usage)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForUsage(double usage) {
    if (usage > 90) return Colors.red;
    if (usage > 75) return Colors.orange;
    return Colors.green;
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TB';
    }
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}
