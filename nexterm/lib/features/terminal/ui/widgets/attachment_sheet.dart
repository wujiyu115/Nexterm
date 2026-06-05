import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class AttachmentSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onPhotos;
  final VoidCallback onFiles;

  const AttachmentSheet({
    super.key,
    required this.onCamera,
    required this.onPhotos,
    required this.onFiles,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            Text(
              l.composer_attachTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: p.fg,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _AttachOption(
              icon: Icons.camera_alt_outlined,
              title: l.composer_attachCamera,
              subtitle: l.composer_attachCameraHint,
              onTap: () {
                Navigator.pop(context);
                onCamera();
              },
            ),
            const SizedBox(height: 8),
            _AttachOption(
              icon: Icons.photo_library_outlined,
              title: l.composer_attachPhotos,
              subtitle: l.composer_attachPhotosHint,
              onTap: () {
                Navigator.pop(context);
                onPhotos();
              },
            ),
            const SizedBox(height: 8),
            _AttachOption(
              icon: Icons.description_outlined,
              title: l.composer_attachFiles,
              subtitle: l.composer_attachFilesHint,
              onTap: () {
                Navigator.pop(context);
                onFiles();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.bgElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: p.fgSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: p.fg,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: p.fgSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
