import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final p = Theme.of(context).extension<ThemePalette>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.source_outlined, size: 64,
                color: p.fgTertiary),
            const SizedBox(height: 16),
            Text(l.git_initTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                color: p.fg)),
            const SizedBox(height: 8),
            if (remotePath != null)
              Text(remotePath!, style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono',
                  color: p.fgTertiary)),
            if (remotePath != null) const SizedBox(height: 8),
            Text(l.git_initMessage, style: TextStyle(fontSize: 14,
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
                child: Text(errorDetail!, style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono',
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
