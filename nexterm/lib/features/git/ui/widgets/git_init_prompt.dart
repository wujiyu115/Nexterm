import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GitInitPrompt extends StatelessWidget {
  final VoidCallback onInit;
  const GitInitPrompt({super.key, required this.onInit});

  void _confirmInit(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.git_initTitle),
        content: Text(l.git_initConfirm),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          CupertinoDialogAction(onPressed: () { Navigator.of(ctx).pop(); onInit(); }, child: Text(l.git_initButton)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.source_outlined, size: 64,
              color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary),
          const SizedBox(height: 16),
          Text(l.git_initTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
              color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg)),
          const SizedBox(height: 8),
          Text(l.git_initMessage, style: TextStyle(fontSize: 14,
              color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary)),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: () => _confirmInit(context), icon: const Icon(Icons.play_arrow), label: Text(l.git_initButton)),
        ],
      ),
    );
  }
}
