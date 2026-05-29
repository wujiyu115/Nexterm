import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
              splashColor: OutdoorColors.accentDim,
              child: Container(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? OutdoorColors.darkCardBg : OutdoorColors.lightCardBg,
                  borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
                  border: Border.all(
                    color: isDark ? OutdoorColors.darkGlassBorder : OutdoorColors.lightGlassBorder,
                    width: 0.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      OutdoorColors.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.transparent,
                      OutdoorColors.accent.withValues(alpha: 0.04),
                    ],
                    stops: const [0.0, 0.4, 0.6, 1.0],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
