import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const SectionLabel({super.key, required this.title, this.padding});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: p.accentGlow,
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: p.accent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
