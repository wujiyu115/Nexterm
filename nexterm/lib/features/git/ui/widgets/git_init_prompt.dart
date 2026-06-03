import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GitInitPrompt extends StatelessWidget {
  final VoidCallback onInit;
  final String? errorDetail;
  final String? remotePath;

  const GitInitPrompt({
    super.key,
    required this.onInit,
    this.errorDetail,
    this.remotePath,
  });

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
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_outlined, size: 64,
                color: p.fgTertiary),
            const SizedBox(height: 16),
            Text(l.git_initTitle, style: theme.textTheme.headlineSmall!.copyWith(
                color: p.fg)),
            const SizedBox(height: 8),
            if (remotePath != null)
              Text(remotePath!, style: theme.textTheme.bodySmall!.copyWith(fontFamily: AppFonts.mono,
                  color: p.fgTertiary)),
            if (remotePath != null) const SizedBox(height: 8),
            Text(l.git_initMessage, style: theme.textTheme.bodyLarge!.copyWith(
                color: p.fgSecondary),
                textAlign: TextAlign.center),
            if (errorDetail != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: p.statusError.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(errorDetail!, style: theme.textTheme.bodySmall!.copyWith(fontFamily: AppFonts.mono,
                    color: p.statusError),
                    textAlign: TextAlign.center),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: () => _confirmInit(context), icon: const Icon(Icons.play_arrow), label: Text(l.git_initButton)),
          ],
        ),
      ),
    );
  }
}
