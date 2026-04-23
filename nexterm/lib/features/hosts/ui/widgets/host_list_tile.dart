import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authLabel = host.authMethod.localizedName(AppLocalizations.of(context)!);
    final subtitle = '${host.username}@${host.hostname}:${host.port}  ·  $authLabel';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSelectionMode ? onSelectionToggle : onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 22,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (host.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: host.tags
                            .map((tag) => _TagChip(tag: tag))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  host.isFavorite ? Icons.star : Icons.star_border,
                  size: 20,
                  color: host.isFavorite ? Colors.amber : colorScheme.onSurfaceVariant,
                ),
                onPressed: onToggleFavorite,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveConnectionBadge extends StatelessWidget {
  final int count;

  const _ActiveConnectionBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: AppLocalizations.of(context)!.hosts_activeConnections(count),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
