import 'package:flutter/material.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/core/theme/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final ConnectionStatus status;
  final double size;
  const StatusIndicator({super.key, required this.status, this.size = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (status) {
      ConnectionStatus.connected => isDark ? AppTheme.onlineGreen : AppTheme.onlineGreenLight,
      ConnectionStatus.connecting => AppTheme.warningYellow,
      ConnectionStatus.error => isDark ? AppTheme.errorRed : AppTheme.errorRedLight,
      ConnectionStatus.disconnected => Theme.of(context).colorScheme.onSurfaceVariant,
    };
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}
