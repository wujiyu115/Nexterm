import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';

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
        isDark ? AppTheme.onlineGreen : AppTheme.onlineGreenLight,
      ForwardStatus.error =>
        isDark ? AppTheme.errorRed : AppTheme.errorRedLight,
      ForwardStatus.inactive =>
        Theme.of(context).colorScheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = status == ForwardStatus.active;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor(context),
                ),
              ),
              const SizedBox(width: 12),
              // Type icon
              Icon(
                _typeIcon,
                size: 20,
                color: colorScheme.primary,
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
                      _AutoStartChip(),
                    ],
                  ],
                ),
              ),
              // Start / stop button
              IconButton(
                icon: Icon(
                  isActive ? Icons.stop_circle_outlined : Icons.play_circle_outlined,
                  color: isActive ? colorScheme.error : colorScheme.primary,
                ),
                tooltip: isActive ? '停止' : '启动',
                onPressed: onStartStop,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoStartChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '自动启动',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
