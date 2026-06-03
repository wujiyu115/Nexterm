import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/domain/entities/host_entity.dart';

enum HostContextAction {
  connect,
  sftpConnect,
  duplicate,
  moveToGroup,
  edit,
  select,
  delete,
}

Future<HostContextAction?> showHostContextMenu({
  required BuildContext context,
  required HostEntity host,
}) {
  final l = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final p = theme.extension<ThemePalette>()!;

  return showModalBottomSheet<HostContextAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.bgElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(ctx).size.height * 0.7,
      ),
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: p.fgTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                children: [
                  Text(
                    host.name,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${host.username}@${host.hostname}:${host.port}',
                    style: theme.textTheme.bodyMedium!.copyWith(color: p.fgSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: p.border),
            _ActionTile(
              icon: Icons.bolt,
              label: l.hosts_contextConnect,
              color: p.accent,
              onTap: () => Navigator.pop(ctx, HostContextAction.connect),
            ),
            _ActionTile(
              icon: Icons.folder_outlined,
              label: l.hosts_contextSftp,
              color: p.accent,
              onTap: () => Navigator.pop(ctx, HostContextAction.sftpConnect),
            ),
            _ActionTile(
              icon: Icons.copy_outlined,
              label: l.hosts_contextCopy,
              color: p.fg,
              onTap: () => Navigator.pop(ctx, HostContextAction.duplicate),
            ),
            _ActionTile(
              icon: Icons.drive_file_move_outline,
              label: l.hosts_contextMoveToGroup,
              color: p.fg,
              onTap: () => Navigator.pop(ctx, HostContextAction.moveToGroup),
            ),
            _ActionTile(
              icon: Icons.edit_outlined,
              label: l.hosts_contextEdit,
              color: p.fg,
              onTap: () => Navigator.pop(ctx, HostContextAction.edit),
            ),
            _ActionTile(
              icon: Icons.check_circle_outline,
              label: l.hosts_contextSelect,
              color: p.fg,
              onTap: () => Navigator.pop(ctx, HostContextAction.select),
            ),
            Divider(height: 1, color: p.border),
            _ActionTile(
              icon: Icons.delete_outline,
              label: l.hosts_contextDelete,
              color: p.statusError,
              onTap: () => Navigator.pop(ctx, HostContextAction.delete),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: theme.textTheme.titleMedium!.copyWith(color: color)),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}
