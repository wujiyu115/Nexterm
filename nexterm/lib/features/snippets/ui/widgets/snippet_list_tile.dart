import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';

class SnippetListTile extends StatelessWidget {
  final SnippetEntity snippet;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleFavorite;

  const SnippetListTile({
    super.key,
    required this.snippet,
    required this.onTap,
    required this.onEdit,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      onLongPress: onEdit,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snippet.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? OutdoorColors.darkInputBg : OutdoorColors.lightInputBg,
                    borderRadius: BorderRadius.circular(OutdoorColors.radiusSm),
                  ),
                  child: Text(
                    snippet.command,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (snippet.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: snippet.tags
                        .map((tag) => _TagChip(tag: tag))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              snippet.isFavorite ? Icons.star : Icons.star_border,
              size: 20,
              color: snippet.isFavorite ? OutdoorColors.accent : (isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
            ),
            onPressed: onToggleFavorite,
            visualDensity: VisualDensity.compact,
          ),
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
      child: Text(
        tag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: OutdoorColors.accent,
        ),
      ),
    );
  }
}
