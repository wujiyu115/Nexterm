import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/utils/file_icon.dart';
import 'package:nexterm/features/sftp/ui/utils/file_size_format.dart';

/// A scrollable list of [RemoteFileInfo] items with icon, name, size/date, and
/// optional multi-select checkboxes.
class FileListView extends StatelessWidget {
  final List<RemoteFileInfo> files;

  /// Paths currently selected (non-empty → multi-select mode).
  final Set<String> selectedPaths;

  /// Called when the user taps a file/directory.
  final void Function(RemoteFileInfo file) onTap;

  /// Called when the user long-presses a file/directory (start selection).
  final void Function(RemoteFileInfo file) onLongPress;

  /// Called when the user toggles a checkbox in multi-select mode.
  final void Function(RemoteFileInfo file) onToggleSelect;

  const FileListView({
    super.key,
    required this.files,
    required this.selectedPaths,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
  });

  bool get _isMultiSelect => selectedPaths.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.sftp_noFiles,
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
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
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isMultiSelectMode
          ? null
          : (file.isDirectory
              ? Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                  size: 20,
                )
              : null),
      selected: isSelected,
      onTap: isMultiSelectMode ? onToggleSelect : onTap,
      onLongPress: onLongPress,
    );
  }
}
