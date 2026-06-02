import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/providers/transfer_provider.dart';

/// A bar shown at the bottom of the SFTP screen that lists active/queued
/// transfers with individual progress bars.  Hidden when there are no active
/// transfers.
class TransferQueueBar extends ConsumerWidget {
  const TransferQueueBar({super.key});

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(transferQueueProvider);
    final active = allItems
        .where((t) =>
            t.status == TransferStatus.active ||
            t.status == TransferStatus.queued)
        .toList();

    if (active.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visible = active.take(_maxVisible).toList();
    final overflow = active.length - visible.length;

    return Material(
      elevation: 4,
      color: colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                const Icon(Icons.swap_vert, size: 16),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.transfer_title(active.length),
                  style: theme.textTheme.labelMedium,
                ),
                const Spacer(),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () =>
                      ref.read(transferQueueProvider.notifier).removeCompleted(),
                  child: Text(AppLocalizations.of(context)!.transfer_clearDone),
                ),
              ],
            ),
          ),
          // Transfer rows
          for (final item in visible)
            _TransferRow(item: item),
          // Overflow indicator
          if (overflow > 0)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Text(
                AppLocalizations.of(context)!.transfer_more(overflow),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TransferRow extends StatelessWidget {
  final TransferItem item;

  const _TransferRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final isUpload = item.direction == TransferDirection.upload;
    final icon = isUpload ? Icons.upload : Icons.download;
    final progress = item.progress;
    final isQueued = item.status == TransferStatus.queued;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: isQueued ? null : progress,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isQueued
                ? AppLocalizations.of(context)!.transfer_queued
                : '${(progress * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
