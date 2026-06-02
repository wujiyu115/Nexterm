import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

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
    final p = Theme.of(context).extension<ThemePalette>()!;

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
              splashColor: p.accentDim,
              child: Container(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: p.cardBg,
                  borderRadius: BorderRadius.circular(OutdoorColors.radiusLg),
                  border: Border.all(
                    color: p.glassBorder,
                    width: 0.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      p.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.transparent,
                      p.accent.withValues(alpha: 0.04),
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
