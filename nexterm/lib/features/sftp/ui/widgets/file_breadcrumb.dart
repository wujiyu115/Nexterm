import 'package:flutter/material.dart';

/// A horizontally scrollable breadcrumb bar showing the current SFTP path.
///
/// Displays a home icon for the root segment and a text chip for each subsequent
/// path segment.  All segments except the last are tappable.
class FileBreadcrumb extends StatelessWidget {
  /// The current remote path, e.g. "/home/user/documents".
  final String path;

  /// Called when the user taps a breadcrumb segment with the full path up to
  /// and including that segment.
  final void Function(String path) onNavigate;

  const FileBreadcrumb({
    super.key,
    required this.path,
    required this.onNavigate,
  });

  /// Splits [path] into (label, fullPath) pairs for each segment.
  List<(String label, String fullPath)> _segments() {
    final result = <(String, String)>[];

    // Always include root.
    result.add(('/', '/'));

    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    var accumulated = '';
    for (final part in parts) {
      accumulated = '$accumulated/$part';
      result.add((part, accumulated));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final segments = _segments();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (int i = 0; i < segments.length; i++) ...[
            _BreadcrumbSegment(
              label: segments[i].$1,
              isRoot: i == 0,
              isLast: i == segments.length - 1,
              colorScheme: colorScheme,
              onTap: i == segments.length - 1
                  ? null
                  : () => onNavigate(segments[i].$2),
            ),
            if (i < segments.length - 1)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.onSurface.withAlpha(100),
              ),
          ],
        ],
      ),
    );
  }
}

class _BreadcrumbSegment extends StatelessWidget {
  final String label;
  final bool isRoot;
  final bool isLast;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _BreadcrumbSegment({
    required this.label,
    required this.isRoot,
    required this.isLast,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isLast
        ? colorScheme.onSurface
        : colorScheme.primary;

    Widget child = isRoot
        ? Icon(Icons.home, size: 18, color: foreground)
        : Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              color: foreground,
            ),
          );

    if (onTap != null) {
      child = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: child,
        ),
      );
    } else {
      child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: child,
      );
    }

    return child;
  }
}
