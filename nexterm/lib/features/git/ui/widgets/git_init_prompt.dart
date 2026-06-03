import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GitInitPrompt extends StatelessWidget {
  final VoidCallback onInit;
  final String? errorDetail;
  final String? remotePath;
  final ValueChanged<String>? onChangePath;

  const GitInitPrompt({
    super.key,
    required this.onInit,
    this.errorDetail,
    this.remotePath,
    this.onChangePath,
  });

  void _showChangePathDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: remotePath ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.git_changePath),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 14),
          decoration: InputDecoration(
            hintText: '/home/user/project',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onSubmitted: (v) {
            final path = v.trim();
            if (path.isNotEmpty) {
              Navigator.of(ctx).pop();
              onChangePath?.call(path);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                Navigator.of(ctx).pop();
                onChangePath?.call(path);
              }
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

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
            if (onChangePath != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showChangePathDialog(context),
                icon: const Icon(Icons.folder_open, size: 18),
                label: Text(l.git_changePath),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
