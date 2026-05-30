import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
          ),
          filled: true,
          fillColor: isDark ? OutdoorColors.darkInputBg : OutdoorColors.lightInputBg,
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
