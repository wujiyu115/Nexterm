import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

class KeyListTile extends StatelessWidget {
  final SSHKeyEntity sshKey;
  final VoidCallback onDelete;

  const KeyListTile({
    super.key,
    required this.sshKey,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.key,
                color: colorScheme.onPrimaryContainer,
                size: 20,
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
                      color: colorScheme.primary,
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
              onSelected: (action) => _handleAction(context, action),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: _KeyAction.copyPublicKey,
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 18),
                      SizedBox(width: 10),
                      Text('复制公钥'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _KeyAction.delete,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 10),
                      Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, _KeyAction action) async {
    switch (action) {
      case _KeyAction.copyPublicKey:
        await Clipboard.setData(ClipboardData(text: sshKey.publicKey));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('公钥已复制到剪贴板'), duration: Duration(seconds: 2)),
          );
        }
      case _KeyAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除密钥'),
            content: Text('确定要删除「${sshKey.name}」吗？'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('删除'),
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

enum _KeyAction { copyPublicKey, delete }
