import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class OutdoorSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const OutdoorSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.titleLarge!.copyWith(
          color: p.fg,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.titleLarge!.copyWith(
            color: p.fgTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: p.fgTertiary,
          ),
          filled: true,
          fillColor: p.inputBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
