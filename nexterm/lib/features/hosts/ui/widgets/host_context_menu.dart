import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/domain/entities/host_entity.dart';

/// Actions available in the host context menu.
enum HostContextAction {
  connect,
  sftpConnect,
  duplicate,
  moveToGroup,
  edit,
  select,
  delete,
}

/// Shows an iOS-style bottom sheet context menu for a host.
Future<HostContextAction?> showHostContextMenu({
  required BuildContext context,
  required HostEntity host,
}) {
  return showCupertinoModalPopup<HostContextAction>(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: Text(host.name),
      message: Text('${host.username}@${host.hostname}:${host.port}'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.connect),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.bolt, size: 20),
              SizedBox(width: 8),
              Text('连接'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.sftpConnect),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.folder, size: 20),
              SizedBox(width: 8),
              Text('SFTP 连接'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.duplicate),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.doc_on_doc, size: 20),
              SizedBox(width: 8),
              Text('复制'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.moveToGroup),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.folder_badge_plus, size: 20),
              SizedBox(width: 8),
              Text('移动到组'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.edit),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.pencil, size: 20),
              SizedBox(width: 8),
              Text('编辑'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx, HostContextAction.select),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.checkmark_circle, size: 20),
              SizedBox(width: 8),
              Text('选中'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(ctx, HostContextAction.delete),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.trash, size: 20, color: CupertinoColors.destructiveRed),
              SizedBox(width: 8),
              Text('删除'),
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('取消'),
      ),
    ),
  );
}
