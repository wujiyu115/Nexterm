import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';
import 'package:nexterm/shared/widgets/status_indicator.dart';

class HostListTile extends StatelessWidget {
  final HostEntity host;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleFavorite;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onSelectionToggle;
  final int activeConnectionCount;

  const HostListTile({
    super.key,
    required this.host,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleFavorite,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onSelectionToggle,
    this.activeConnectionCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitle = '${host.username}@${host.hostname}:${host.port}';

    return GlassCard(
      onTap: isSelectionMode ? onSelectionToggle : onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 22,
                color: isSelected ? OutdoorColors.accent : (isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
              ),
            )
          else
            StatusIndicator(status: ConnectionStatus.disconnected, size: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        host.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (activeConnectionCount > 0) ...[
                      const SizedBox(width: 6),
                      _ActiveConnectionBadge(count: activeConnectionCount),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (host.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: host.tags.map((tag) => _TagChip(tag: tag)).toList(),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggleFavorite,
            child: Icon(
              host.isFavorite ? Icons.star : Icons.star_border,
              size: 20,
              color: host.isFavorite ? OutdoorColors.accent : (isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveConnectionBadge extends StatelessWidget {
  final int count;
  const _ActiveConnectionBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: OutdoorColors.accentDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OutdoorColors.accent.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: OutdoorColors.accent, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OutdoorColors.accent, height: 1)),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: OutdoorColors.accentDim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(tag, style: const TextStyle(fontSize: 11, color: OutdoorColors.accent)),
    );
  }
}
