import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/models/toolbar_key_definition.dart';
import 'package:nexterm/features/terminal/providers/toolbar_config_provider.dart';

/// A scrollable, grouped toolbar that sits above the soft keyboard.
///
/// Each group of keys is separated by a thin divider. Ctrl and Alt act as
/// sticky modifier toggles — when active, the next key press is prefixed with
/// the modifier byte and the toggle resets.
class KeyboardToolbar extends ConsumerStatefulWidget {
  /// Called with the raw bytes to write to the SSH session.
  final void Function(Uint8List data) onKeyInput;

  const KeyboardToolbar({
    super.key,
    required this.onKeyInput,
  });

  @override
  ConsumerState<KeyboardToolbar> createState() => _KeyboardToolbarState();
}

class _KeyboardToolbarState extends ConsumerState<KeyboardToolbar> {
  bool _ctrlActive = false;
  bool _altActive = false;

  // -------------------------------------------------------------------------
  // Send helpers
  // -------------------------------------------------------------------------

  void _sendBytes(Uint8List bytes) {
    HapticFeedback.lightImpact();

    if (_ctrlActive && bytes.length == 1) {
      // Ctrl + printable char → send control code.
      final code = bytes[0];
      if (code >= 0x40 && code <= 0x7F) {
        widget.onKeyInput(Uint8List.fromList([code & 0x1F]));
      } else {
        widget.onKeyInput(bytes);
      }
      _resetModifiers();
      return;
    }

    if (_altActive) {
      // Alt prefix: ESC + original bytes.
      widget.onKeyInput(Uint8List.fromList([0x1B, ...bytes]));
      _resetModifiers();
      return;
    }

    widget.onKeyInput(bytes);
  }

  void _resetModifiers() {
    setState(() {
      _ctrlActive = false;
      _altActive = false;
    });
  }

  void _toggleCtrl() {
    HapticFeedback.lightImpact();
    setState(() {
      _ctrlActive = !_ctrlActive;
      if (_ctrlActive) _altActive = false;
    });
  }

  void _toggleAlt() {
    HapticFeedback.lightImpact();
    setState(() {
      _altActive = !_altActive;
      if (_altActive) _ctrlActive = false;
    });
  }

  void _onKeyTap(ToolbarKeyDef key) {
    // Ctrl and Alt are modifier toggles, not byte senders.
    if (key.id == 'ctrl') {
      _toggleCtrl();
      return;
    }
    if (key.id == 'alt') {
      _toggleAlt();
      return;
    }
    _sendBytes(key.bytes);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final allGroups = ref.watch(toolbarConfigProvider);
    final visibleCount = ref.watch(visibleGroupCountProvider);
    final groups = allGroups.take(visibleCount).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color background = isDark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFE8E8F0);
    final Color buttonColor = isDark
        ? const Color(0xFF313244)
        : const Color(0xFFD0D0E0);
    final Color activeColor = isDark
        ? const Color(0xFF89B4FA)
        : const Color(0xFF1E66F5);
    final Color textColor = isDark
        ? const Color(0xFFCDD6F4)
        : const Color(0xFF1C1C2E);
    final Color activeTextColor = isDark
        ? const Color(0xFF1E1E2E)
        : Colors.white;
    final Color dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Container(
      height: 44,
      color: background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: _buildGroupWidgets(
            groups,
            buttonColor: buttonColor,
            activeColor: activeColor,
            textColor: textColor,
            activeTextColor: activeTextColor,
            dividerColor: dividerColor,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupWidgets(
    List<ToolbarKeyGroup> groups, {
    required Color buttonColor,
    required Color activeColor,
    required Color textColor,
    required Color activeTextColor,
    required Color dividerColor,
  }) {
    final widgets = <Widget>[];

    for (int gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      for (final key in group.keys) {
        final isActive =
            (key.id == 'ctrl' && _ctrlActive) ||
            (key.id == 'alt' && _altActive);

        widgets.add(
          _ToolbarButton(
            label: key.label,
            color: isActive ? activeColor : buttonColor,
            textColor: isActive ? activeTextColor : textColor,
            onTap: () => _onKeyTap(key),
          ),
        );
      }
      // Add divider between groups (not after the last one).
      if (gi < groups.length - 1) {
        widgets.add(_VerticalDivider(color: dividerColor));
      }
    }

    return widgets;
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _ToolbarButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 40),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: color,
    );
  }
}
