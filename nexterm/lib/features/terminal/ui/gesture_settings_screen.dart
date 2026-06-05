import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/terminal/models/gesture_config.dart';
import 'package:nexterm/features/terminal/providers/gesture_config_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GestureSettingsScreen extends ConsumerWidget {
  const GestureSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final l = AppLocalizations.of(context)!;
    final bindings = ref.watch(gestureConfigProvider);

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        title: Text(l.settings_gestures),
        backgroundColor: p.bg,
        foregroundColor: p.fg,
        elevation: 0,
      ),
      body: ListView(
        children: GestureType.values.map((gesture) {
          final binding = bindings.firstWhere(
            (b) => b.gesture == gesture,
            orElse: () => GestureBinding(gesture: gesture, action: GestureAction.none),
          );
          return ListTile(
            leading: Icon(_gestureIcon(gesture), color: p.fgSecondary),
            title: Text(_gestureLabel(gesture, l)),
            subtitle: Text(_actionLabel(binding.action, l)),
            onTap: () => _showActionPicker(context, ref, gesture, binding.action, l, p),
          );
        }).toList(),
      ),
    );
  }

  IconData _gestureIcon(GestureType type) => switch (type) {
    GestureType.twoFingerTap => Icons.touch_app,
    GestureType.swipeLeft => Icons.swipe_left,
    GestureType.swipeRight => Icons.swipe_right,
    GestureType.swipeDown => Icons.swipe_down,
  };

  String _gestureLabel(GestureType type, AppLocalizations l) => switch (type) {
    GestureType.twoFingerTap => l.gesture_twoFingerTap,
    GestureType.swipeLeft => l.gesture_swipeLeft,
    GestureType.swipeRight => l.gesture_swipeRight,
    GestureType.swipeDown => l.gesture_swipeDown,
  };

  String _actionLabel(GestureAction action, AppLocalizations l) => switch (action) {
    GestureAction.paste => l.gesture_actionPaste,
    GestureAction.copy => l.gesture_actionCopy,
    GestureAction.switchTabLeft => l.gesture_actionSwitchTabLeft,
    GestureAction.switchTabRight => l.gesture_actionSwitchTabRight,
    GestureAction.toggleDpad => l.gesture_actionToggleDpad,
    GestureAction.toggleKeyboard => l.gesture_actionToggleKeyboard,
    GestureAction.none => l.gesture_actionNone,
  };

  void _showActionPicker(
    BuildContext context,
    WidgetRef ref,
    GestureType gesture,
    GestureAction current,
    AppLocalizations l,
    ThemePalette p,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: p.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: GestureAction.values.map((action) {
            final isSelected = action == current;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? p.accent : p.fgTertiary,
              ),
              title: Text(
                _actionLabel(action, l),
                style: TextStyle(
                  color: isSelected ? p.accent : p.fg,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              onTap: () {
                ref.read(gestureConfigProvider.notifier).updateBinding(gesture, action);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
