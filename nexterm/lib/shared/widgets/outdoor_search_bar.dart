import 'dart:ui';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? OutdoorColors.darkInputBg : OutdoorColors.lightInputBg,
              borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
              border: Border.all(
                color: isDark ? OutdoorColors.darkBorder : OutdoorColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 16,
                  color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
