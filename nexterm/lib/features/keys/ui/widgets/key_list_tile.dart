import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';

class KeyListTile extends ConsumerWidget {
  final SSHKeyEntity sshKey;
  final VoidCallback onDelete;

  const KeyListTile({
    super.key,
    required this.sshKey,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OutdoorColors.accentDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.key,
              color: OutdoorColors.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sshKey.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  sshKey.type.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: OutdoorColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sshKey.fingerprint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<_KeyAction>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            onSelected: (action) => _handleAction(context, ref, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _KeyAction.copyPublicKey,
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 18),
                    const SizedBox(width: 10),
                    Text(l.keyTile_copyPublicKey),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _KeyAction.exportPrivateKey,
                child: Row(
                  children: [
                    const Icon(Icons.file_download_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(l.keyTile_exportPrivateKey),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _KeyAction.exportPublicKey,
                child: Row(
                  children: [
                    const Icon(Icons.file_upload_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(l.keyTile_exportPublicKey),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _KeyAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 10),
                    Text(l.keyTile_delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, _KeyAction action) async {
    final l = AppLocalizations.of(context)!;
    switch (action) {
      case _KeyAction.copyPublicKey:
        await Clipboard.setData(ClipboardData(text: sshKey.publicKey));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.keyTile_publicKeyCopied), duration: const Duration(seconds: 2)),
          );
        }
      case _KeyAction.exportPrivateKey:
        try {
          final notifier = ref.read(keysNotifierProvider.notifier);
          await notifier.exportKey(sshKey, publicOnly: false);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.keyTile_exportFailed(e.toString()))),
            );
          }
        }
      case _KeyAction.exportPublicKey:
        try {
          final notifier = ref.read(keysNotifierProvider.notifier);
          await notifier.exportKey(sshKey, publicOnly: true);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l.keyTile_exportFailed(e.toString()))),
            );
          }
        }
      case _KeyAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.keyTile_deleteTitle),
            content: Text(l.keyTile_deleteConfirm(sshKey.name)),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.common_cancel)),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.common_delete),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          onDelete();
        }
    }
  }
}

enum _KeyAction { copyPublicKey, exportPrivateKey, exportPublicKey, delete }
