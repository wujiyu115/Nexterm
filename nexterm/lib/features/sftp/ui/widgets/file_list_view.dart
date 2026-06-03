import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/utils/file_icon.dart';
import 'package:nexterm/features/sftp/ui/utils/file_size_format.dart';

/// A scrollable list of [RemoteFileInfo] items with icon, name, size/date, and
/// optional multi-select checkboxes.
class FileListView extends StatelessWidget {
  final List<RemoteFileInfo> files;
  final Set<String> selectedPaths;
  final void Function(RemoteFileInfo file) onTap;
  final void Function(RemoteFileInfo file) onLongPress;
  final void Function(RemoteFileInfo file) onToggleSelect;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const FileListView({
    super.key,
    required this.files,
    required this.selectedPaths,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
    this.hasMore = false,
    this.onLoadMore,
  });

  bool get _isMultiSelect => selectedPaths.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    if (files.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.sftp_noFiles,
          style: TextStyle(color: p.fgSecondary),
        ),
      );
    }

    final itemCount = files.length + (hasMore ? 1 : 0);

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= files.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onLoadMore?.call());
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        final file = files[index];
        return _FileListItem(
          file: file,
          isSelected: selectedPaths.contains(file.path),
          isMultiSelectMode: _isMultiSelect,
          onTap: () => onTap(file),
          onLongPress: () => onLongPress(file),
          onToggleSelect: () => onToggleSelect(file),
        );
      },
    );
  }
}

class _FileListItem extends StatelessWidget {
  final RemoteFileInfo file;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;

  const _FileListItem({
    required this.file,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  String _subtitle() {
    final parts = <String>[];
    if (!file.isDirectory) {
      parts.add(formatFileSize(file.size));
    }
    if (file.modified != null) {
      final local = file.modified!.toLocal();
      final month = local.month.toString().padLeft(2, '0');
      final day = local.day.toString().padLeft(2, '0');
      final hour = local.hour.toString().padLeft(2, '0');
      final min = local.minute.toString().padLeft(2, '0');
      parts.add('${local.year}-$month-$day  $hour:$min');
    }
    return parts.join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final brightness = Theme.of(context).brightness;
    final iconData = getFileIcon(file.name, isDirectory: file.isDirectory);
    final iconColor =
        getFileIconColor(file.name, isDirectory: file.isDirectory, brightness: brightness);

    return ListTile(
      leading: isMultiSelectMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onToggleSelect(),
            )
          : Icon(iconData, color: iconColor),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: file.isDirectory ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      subtitle: _subtitle().isNotEmpty
          ? Text(
              _subtitle(),
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isMultiSelectMode
          ? null
          : (file.isDirectory
              ? Icon(
                  Icons.chevron_right,
                  color: p.fgTertiary,
                  size: 20,
                )
              : null),
      selected: isSelected,
      onTap: isMultiSelectMode ? onToggleSelect : onTap,
      onLongPress: onLongPress,
    );
  }
}
