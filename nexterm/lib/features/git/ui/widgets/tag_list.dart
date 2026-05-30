import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_tag.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class TagList extends StatelessWidget {
  final List<GitTag> tags;
  final Future<void> Function(GitTag tag) onDeleteTag;
  final Future<void> Function(GitTag tag) onCheckoutTag;
  const TagList({super.key, required this.tags, required this.onDeleteTag, required this.onCheckoutTag});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (tags.isEmpty) return Center(child: Text(l.git_noTags));
    return ListView.separated(
      itemCount: tags.length, separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tag = tags[index];
        return Dismissible(
          key: Key(tag.name), direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showCupertinoDialog<bool>(context: context, builder: (ctx) => CupertinoAlertDialog(
              title: Text(l.git_deleteTag), content: Text(l.git_deleteTagConfirm(tag.name)),
              actions: [
                CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.common_cancel)),
                CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Navigator.of(ctx).pop(true), child: Text(l.common_delete)),
              ],
            )) ?? false;
          },
          onDismissed: (_) => onDeleteTag(tag),
          background: Container(color: const Color(0xFFE06C75), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
          child: ListTile(
            dense: true, visualDensity: VisualDensity.compact,
            leading: Icon(Icons.local_offer_outlined, size: 18,
                color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary),
            title: Text(tag.name, style: TextStyle(fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFg : OutdoorColors.lightFg)),
            subtitle: tag.timestamp != null ? Text(
              '${tag.timestamp!.year}-${tag.timestamp!.month.toString().padLeft(2, '0')}-${tag.timestamp!.day.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary)) : null,
            trailing: TextButton(onPressed: () => onCheckoutTag(tag), child: Text(l.git_checkoutTag, style: const TextStyle(fontSize: 12))),
          ),
        );
      },
    );
  }
}
