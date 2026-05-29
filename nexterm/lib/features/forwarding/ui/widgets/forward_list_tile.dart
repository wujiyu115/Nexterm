import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';

/// A card tile for a single port forward rule.
///
/// Shows the forward name, type icon, summary string, status indicator,
/// a start/stop toggle button, and an autoStart indicator chip.
class ForwardListTile extends StatelessWidget {
  final PortForwardEntity forward;
  final ForwardStatus status;
  final VoidCallback onEdit;
  final VoidCallback onStartStop;

  const ForwardListTile({
    super.key,
    required this.forward,
    required this.status,
    required this.onEdit,
    required this.onStartStop,
  });

  IconData get _typeIcon => switch (forward.type) {
        ForwardType.local => Icons.arrow_forward,
        ForwardType.remote => Icons.arrow_back,
        ForwardType.dynamic => Icons.language,
      };

  Color _statusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (status) {
      ForwardStatus.active =>
        isDark ? OutdoorColors.darkStatusOnline : OutdoorColors.lightStatusOnline,
      ForwardStatus.error =>
        Theme.of(context).colorScheme.error,
      ForwardStatus.inactive =>
        isDark ? OutdoorColors.darkStatusOffline : OutdoorColors.lightStatusOffline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = status == ForwardStatus.active;

    return GlassCard(
      onTap: onEdit,
      child: Row(
        children: [
          // Type icon container with status dot
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OutdoorColors.accentDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _typeIcon,
                  size: 18,
                  color: OutdoorColors.accent,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(context),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? OutdoorColors.darkBgElevated
                          : OutdoorColors.lightBgElevated,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Name & summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forward.name,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  forward.summary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (forward.autoStart) ...[
                  const SizedBox(height: 4),
                  const _AutoStartChip(),
                ],
              ],
            ),
          ),
          // Start / stop button
          IconButton(
            icon: Icon(
              isActive ? Icons.stop_circle_outlined : Icons.play_circle_outlined,
              color: isActive ? colorScheme.error : OutdoorColors.accent,
            ),
            tooltip: isActive
                ? AppLocalizations.of(context)!.forwarding_stop
                : AppLocalizations.of(context)!.forwarding_start,
            onPressed: onStartStop,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _AutoStartChip extends StatelessWidget {
  const _AutoStartChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: OutdoorColors.accentDim,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppLocalizations.of(context)!.forwarding_autoStart,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: OutdoorColors.accent,
            ),
      ),
    );
  }
}
