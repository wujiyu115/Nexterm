import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
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
  return showCupertinoModalPopup<HostContextAction>(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: Text(host.name),
      message: Text('${host.username}@${host.hostname}:${host.port}'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.connect),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.bolt, size: 20),
              const SizedBox(width: 8),
              Text(l.hosts_contextConnect),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.sftpConnect),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.folder, size: 20),
              const SizedBox(width: 8),
              Text(l.hosts_contextSftp),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.duplicate),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.doc_on_doc, size: 20),
              const SizedBox(width: 8),
              Text(l.hosts_contextCopy),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.moveToGroup),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.folder_badge_plus, size: 20),
              const SizedBox(width: 8),
              Text(l.hosts_contextMoveToGroup),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.edit),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.pencil, size: 20),
              const SizedBox(width: 8),
              Text(l.hosts_contextEdit),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.select),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.checkmark_circle, size: 20),
              const SizedBox(width: 8),
              Text(l.hosts_contextSelect),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(ctx, HostContextAction.delete),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.trash, size: 20, color: CupertinoColors.destructiveRed),
              const SizedBox(width: 8),
              Text(l.hosts_contextDelete),
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(ctx),
        child: Text(l.common_cancel),
      ),
    ),
  );
}
