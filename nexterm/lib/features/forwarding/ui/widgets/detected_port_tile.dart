import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/forwarding/models/detected_port.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';

class DetectedPortTile extends StatelessWidget {
  final DetectedPort port;
  final bool isForwarded;
  final VoidCallback? onTap;

  const DetectedPortTile({
    super.key,
    required this.port,
    required this.isForwarded,
    this.onTap,
  });

  Color _protocolColor(String protocol, Color fallback) {
    return switch (protocol) {
      'HTTP' || 'HTTPS' => const Color(0xFF4CAF50),
      'MySQL' || 'PostgreSQL' || 'MongoDB' => const Color(0xFF2196F3),
      'Redis' || 'Memcached' => const Color(0xFFFF5722),
      'SSH' => const Color(0xFF9C27B0),
      'Docker' || 'Container' => const Color(0xFF00BCD4),
      _ => fallback,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final p = theme.extension<ThemePalette>()!;
    final secondaryColor = p.fgSecondary;

    return GlassCard(
      onTap: isForwarded ? null : onTap,
      child: Row(
        children: [
          // Port number
          SizedBox(
            width: 60,
            child: Text(
              '${port.port}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Protocol badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _protocolColor(port.protocolGuess, p.accent).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              port.protocolGuess,
              style: theme.textTheme.labelSmall?.copyWith(
                color: _protocolColor(port.protocolGuess, p.accent),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Process name + bind address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  port.processName ?? l.portDetect_unknownProcess,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (port.bindAddress != '0.0.0.0' &&
                    port.bindAddress != '::') ...[
                  const SizedBox(height: 1),
                  Text(
                    port.bindAddress,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing: forwarded chip or add button
          if (isForwarded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: p.accentDim,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l.portDetect_alreadyForwarded,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: p.accent,
                ),
              ),
            )
          else
            Icon(
              Icons.add_circle_outline,
              size: 22,
              color: p.accent,
            ),
        ],
      ),
    );
  }
}
