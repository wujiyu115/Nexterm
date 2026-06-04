import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/core/theme/theme_palette.dart';

class DPadPanel extends StatelessWidget {
  final void Function(Uint8List data) onKeyInput;

  const DPadPanel({super.key, required this.onKeyInput});

  static final _backspace = Uint8List.fromList([0x7F]);
  static final _ctrlC = Uint8List.fromList([0x03]);
  static final _enter = Uint8List.fromList([0x0D]);
  static final _arrowUp = Uint8List.fromList([0x1B, 0x5B, 0x41]);
  static final _arrowDown = Uint8List.fromList([0x1B, 0x5B, 0x42]);
  static final _arrowRight = Uint8List.fromList([0x1B, 0x5B, 0x43]);
  static final _arrowLeft = Uint8List.fromList([0x1B, 0x5B, 0x44]);

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: p.bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DPadKey(label: '⌫', bytes: _backspace, onKeyInput: onKeyInput, isDestructive: true),
              const SizedBox(width: 12),
              _DPadKey(label: '↑', bytes: _arrowUp, onKeyInput: onKeyInput),
              const SizedBox(width: 12),
              _DPadKey(label: '^C', bytes: _ctrlC, onKeyInput: onKeyInput, isDestructive: true),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DPadKey(label: '←', bytes: _arrowLeft, onKeyInput: onKeyInput),
              const SizedBox(width: 12),
              _DPadKey(label: '↵', bytes: _enter, onKeyInput: onKeyInput),
              const SizedBox(width: 12),
              _DPadKey(label: '→', bytes: _arrowRight, onKeyInput: onKeyInput),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 56),
              _DPadKey(label: '↓', bytes: _arrowDown, onKeyInput: onKeyInput),
              const SizedBox(width: 56),
            ],
          ),
        ],
      ),
    );
  }
}

class _DPadKey extends StatefulWidget {
  final String label;
  final Uint8List bytes;
  final void Function(Uint8List data) onKeyInput;
  final bool isDestructive;

  const _DPadKey({
    required this.label,
    required this.bytes,
    required this.onKeyInput,
    this.isDestructive = false,
  });

  @override
  State<_DPadKey> createState() => _DPadKeyState();
}

class _DPadKeyState extends State<_DPadKey> {
  Timer? _repeatTimer;

  void _send() {
    HapticFeedback.lightImpact();
    widget.onKeyInput(widget.bytes);
  }

  void _startRepeat() {
    _send();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      widget.onKeyInput(widget.bytes);
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final bgColor = widget.isDestructive ? p.statusError.withValues(alpha: 0.85) : p.surfaceSolid;
    final fgColor = widget.isDestructive ? Colors.white : p.fg;

    return GestureDetector(
      onTap: _send,
      onLongPressStart: (_) => _startRepeat(),
      onLongPressEnd: (_) => _stopRepeat(),
      onLongPressCancel: _stopRepeat,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}
