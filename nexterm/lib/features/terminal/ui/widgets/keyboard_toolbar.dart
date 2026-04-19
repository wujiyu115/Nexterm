import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A toolbar that sits above the soft keyboard in the terminal screen.
///
/// Provides one-tap access to Tab, Ctrl (toggle), Alt (toggle), Esc, arrow
/// keys, and a placeholder ⚡ button for Snippets (Phase 2).
class KeyboardToolbar extends StatefulWidget {
  /// Called with the raw bytes to write to the SSH session.
  final void Function(Uint8List data) onKeyInput;

  /// Called when the ⚡ (snippets) button is tapped — placeholder for Phase 2.
  final VoidCallback? onSnippetsTap;

  const KeyboardToolbar({
    super.key,
    required this.onKeyInput,
    this.onSnippetsTap,
  });

  @override
  State<KeyboardToolbar> createState() => _KeyboardToolbarState();
}

class _KeyboardToolbarState extends State<KeyboardToolbar> {
  bool _ctrlActive = false;
  bool _altActive = false;

  // -------------------------------------------------------------------------
  // Byte helpers
  // -------------------------------------------------------------------------

  /// ANSI escape sequences for arrow keys.
  static final Uint8List _arrowUp = Uint8List.fromList([0x1B, 0x5B, 0x41]);    // ESC[A
  static final Uint8List _arrowDown = Uint8List.fromList([0x1B, 0x5B, 0x42]);  // ESC[B
  static final Uint8List _arrowRight = Uint8List.fromList([0x1B, 0x5B, 0x43]); // ESC[C
  static final Uint8List _arrowLeft = Uint8List.fromList([0x1B, 0x5B, 0x44]);  // ESC[D

  static final Uint8List _tab = Uint8List.fromList([0x09]);   // \t
  static final Uint8List _esc = Uint8List.fromList([0x1B]);   // ESC

  // -------------------------------------------------------------------------
  // Send helpers
  // -------------------------------------------------------------------------

  void _sendBytes(Uint8List bytes) {
    HapticFeedback.lightImpact();
    widget.onKeyInput(bytes);
  }

  void _onTab() {
    if (_ctrlActive) {
      // Ctrl+Tab — char code of '\t' is 9, which is already the control code.
      // Send 0x09 regardless (same byte), then reset modifiers.
      _sendBytes(Uint8List.fromList([0x09]));
      _resetModifiers();
    } else if (_altActive) {
      // Alt prefix + Tab
      _sendBytes(Uint8List.fromList([0x1B, 0x09]));
      _resetModifiers();
    } else {
      _sendBytes(_tab);
    }
  }

  void _onEsc() {
    _sendBytes(_esc);
    _resetModifiers();
  }

  void _onArrow(Uint8List sequence) {
    if (_altActive) {
      // Alt + arrow: ESC ESC [ X
      final bytes = Uint8List.fromList([0x1B, ...sequence]);
      _sendBytes(bytes);
    } else {
      _sendBytes(sequence);
    }
    if (_ctrlActive || _altActive) _resetModifiers();
  }

  void _onSnippets() {
    HapticFeedback.lightImpact();
    widget.onSnippetsTap?.call();
  }

  void _resetModifiers() {
    setState(() {
      _ctrlActive = false;
      _altActive = false;
    });
  }

  // -------------------------------------------------------------------------
  // Toggle helpers
  // -------------------------------------------------------------------------

  void _toggleCtrl() {
    HapticFeedback.lightImpact();
    setState(() {
      _ctrlActive = !_ctrlActive;
      if (_ctrlActive) _altActive = false; // Only one modifier at a time.
    });
  }

  void _toggleAlt() {
    HapticFeedback.lightImpact();
    setState(() {
      _altActive = !_altActive;
      if (_altActive) _ctrlActive = false;
    });
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
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
    final Color accentColor = theme.colorScheme.primary;

    return Container(
      height: 44,
      color: background,
      child: Row(
        children: [
          // Tab
          _ToolbarButton(
            label: 'Tab',
            color: buttonColor,
            textColor: textColor,
            onTap: _onTab,
          ),

          // Ctrl (toggle)
          _ToolbarButton(
            label: 'Ctrl',
            color: _ctrlActive ? activeColor : buttonColor,
            textColor: _ctrlActive ? activeTextColor : textColor,
            onTap: _toggleCtrl,
          ),

          // Alt (toggle)
          _ToolbarButton(
            label: 'Alt',
            color: _altActive ? activeColor : buttonColor,
            textColor: _altActive ? activeTextColor : textColor,
            onTap: _toggleAlt,
          ),

          // Esc
          _ToolbarButton(
            label: 'Esc',
            color: buttonColor,
            textColor: textColor,
            onTap: _onEsc,
          ),

          // Divider
          _Divider(color: isDark ? Colors.white12 : Colors.black12),

          // Arrow keys
          _ToolbarButton(
            label: '↑',
            color: buttonColor,
            textColor: textColor,
            onTap: () => _onArrow(_arrowUp),
          ),
          _ToolbarButton(
            label: '↓',
            color: buttonColor,
            textColor: textColor,
            onTap: () => _onArrow(_arrowDown),
          ),
          _ToolbarButton(
            label: '←',
            color: buttonColor,
            textColor: textColor,
            onTap: () => _onArrow(_arrowLeft),
          ),
          _ToolbarButton(
            label: '→',
            color: buttonColor,
            textColor: textColor,
            onTap: () => _onArrow(_arrowRight),
          ),

          // Divider
          _Divider(color: isDark ? Colors.white12 : Colors.black12),

          // Snippets placeholder (⚡)
          _ToolbarButton(
            label: '⚡',
            color: accentColor.withValues(alpha: 0.2),
            textColor: accentColor,
            onTap: _onSnippets,
          ),
        ],
      ),
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
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

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

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
