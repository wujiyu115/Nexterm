import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/terminal/models/toolbar_key_definition.dart';
import 'package:nexterm/features/terminal/providers/stt_provider.dart';
import 'package:nexterm/features/terminal/providers/toolbar_config_provider.dart';
import 'package:nexterm/features/terminal/providers/toolbar_modifier_provider.dart';
import 'package:nexterm/features/terminal/providers/toolbar_usage_provider.dart';
import 'package:nexterm/features/terminal/providers/voice_locale_provider.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';

/// A scrollable, grouped toolbar that sits above the soft keyboard.
///
/// Each group of keys is separated by a thin divider. Ctrl and Alt act as
/// sticky modifier toggles — when active, the next key press is prefixed with
/// the modifier byte and the toggle resets.
class KeyboardToolbar extends ConsumerStatefulWidget {
  /// Called with the raw bytes to write to the SSH session.
  final void Function(Uint8List data) onKeyInput;

  /// Called to dismiss the soft keyboard without toggling.
  final VoidCallback? onHideKeyboard;

  const KeyboardToolbar({
    super.key,
    required this.onKeyInput,
    this.onHideKeyboard,
  });

  @override
  ConsumerState<KeyboardToolbar> createState() => _KeyboardToolbarState();
}

class _KeyboardToolbarState extends ConsumerState<KeyboardToolbar> {
  bool _isListening = false;
  StreamSubscription<SttResult>? _sttSub;
  SttProvider? _activeSttProvider;

  @override
  void dispose() {
    _sttSub?.cancel();
    _activeSttProvider?.stop();
    super.dispose();
  }

  void _toggleSpeech() {
    HapticFeedback.lightImpact();
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    _activeSttProvider = ref.read(sttProviderInstanceProvider);
    final provider = _activeSttProvider!;
    final localeId = ref.read(voiceLocaleIdProvider);
    setState(() => _isListening = true);
    final stream = provider.start(localeId: localeId.isEmpty ? null : localeId);
    _sttSub = stream.listen(
      (result) {
        if (result.isFinal && result.text.isNotEmpty) {
          widget.onKeyInput(Uint8List.fromList(utf8.encode(result.text)));
        }
      },
      onDone: () {
        if (mounted) setState(() => _isListening = false);
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
  }

  void _stopListening() {
    _sttSub?.cancel();
    _sttSub = null;
    _activeSttProvider?.stop();
    _activeSttProvider = null;
    setState(() => _isListening = false);
  }

  void _onLongPressStart() {
    HapticFeedback.lightImpact();
    _startListening();
  }

  void _onLongPressEnd() {
    _stopListening();
  }

  // -------------------------------------------------------------------------
  // Send helpers
  // -------------------------------------------------------------------------

  void _sendBytes(Uint8List bytes) {
    HapticFeedback.lightImpact();
    final modifier = ref.read(toolbarModifierProvider);

    if (modifier.ctrl) {
      if (bytes.length == 1) {
        final code = bytes[0];
        if (code >= 0x40 && code <= 0x7F) {
          widget.onKeyInput(Uint8List.fromList([code & 0x1F]));
        } else {
          widget.onKeyInput(bytes);
        }
      } else {
        widget.onKeyInput(_applyEscModifier(bytes, 5));
      }
      ref.read(toolbarModifierProvider.notifier).reset();
      return;
    }

    if (modifier.alt) {
      if (bytes.length == 1) {
        widget.onKeyInput(Uint8List.fromList([0x1B, ...bytes]));
      } else {
        widget.onKeyInput(_applyEscModifier(bytes, 3));
      }
      ref.read(toolbarModifierProvider.notifier).reset();
      return;
    }

    widget.onKeyInput(bytes);
  }

  /// Inserts an xterm modifier parameter into a CSI or SS3 escape sequence.
  ///
  /// [mod]: 3 = Alt, 5 = Ctrl (xterm modifier encoding).
  static Uint8List _applyEscModifier(Uint8List bytes, int mod) {
    if (bytes.length < 3 || bytes[0] != 0x1B) return bytes;

    // SS3: ESC O <final> → ESC [ 1;<mod> <final>
    if (bytes[1] == 0x4F && bytes.length == 3) {
      return Uint8List.fromList(
          [0x1B, 0x5B, 0x31, 0x3B, 0x30 + mod, bytes[2]]);
    }

    // CSI: ESC [ <params> <final>
    if (bytes[1] == 0x5B) {
      final finalByte = bytes.last;
      final params = bytes.sublist(2, bytes.length - 1);
      if (params.isEmpty) {
        // ESC [ A → ESC [ 1;<mod> A
        return Uint8List.fromList(
            [0x1B, 0x5B, 0x31, 0x3B, 0x30 + mod, finalByte]);
      } else {
        // ESC [ 5 ~ → ESC [ 5;<mod> ~
        return Uint8List.fromList(
            [0x1B, 0x5B, ...params, 0x3B, 0x30 + mod, finalByte]);
      }
    }

    return bytes;
  }

  void _toggleCtrl() {
    HapticFeedback.lightImpact();
    ref.read(toolbarModifierProvider.notifier).toggleCtrl();
  }

  void _toggleAlt() {
    HapticFeedback.lightImpact();
    ref.read(toolbarModifierProvider.notifier).toggleAlt();
  }

  void _onKeyTap(ToolbarKeyDef key) {
    if (key.id == 'ctrl') {
      _toggleCtrl();
      return;
    }
    if (key.id == 'alt') {
      _toggleAlt();
      return;
    }
    if (key.id == 'paste') {
      _pasteFromClipboard();
      return;
    }
    _sendBytes(key.bytes);
    ref.read(toolbarUsageProvider.notifier).increment(key.id);
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.lightImpact();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      widget.onKeyInput(Uint8List.fromList(utf8.encode(data.text!)));
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final allGroups = ref.watch(toolbarConfigProvider);
    final visibleCount = ref.watch(visibleGroupCountProvider);
    final modifier = ref.watch(toolbarModifierProvider);
    final groups = allGroups.take(visibleCount).toList();
    final p = Theme.of(context).extension<ThemePalette>()!;
    final isDark = p.brightness == Brightness.dark;

    final Color background = p.bgElevated;
    final Color buttonColor = p.surfaceSolid;
    final Color activeColor = p.accent;
    final Color textColor = p.fg;
    final Color activeTextColor = isDark ? p.bg : Colors.white;
    final Color dividerColor = p.border;

    return Container(
      height: 44,
      color: background,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: _buildGroupWidgets(
                  groups,
                  modifier: modifier,
                  buttonColor: buttonColor,
                  activeColor: activeColor,
                  textColor: textColor,
                  activeTextColor: activeTextColor,
                  dividerColor: dividerColor,
                ),
              ),
            ),
          ),
          _MicButton(
            isListening: _isListening,
            providerType: ref.watch(sttProviderTypeProvider),
            accentColor: activeColor,
            textColor: textColor,
            onTap: _toggleSpeech,
            onLongPressStart: _onLongPressStart,
            onLongPressEnd: _onLongPressEnd,
          ),
          if (widget.onHideKeyboard != null)
            GestureDetector(
              onTap: widget.onHideKeyboard,
              child: Container(
                width: 44,
                height: double.infinity,
                alignment: Alignment.center,
                child: Icon(
                  Icons.keyboard_hide,
                  size: 20,
                  color: textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupWidgets(
    List<ToolbarKeyGroup> groups, {
    required ToolbarModifierState modifier,
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
            (key.id == 'ctrl' && modifier.ctrl) ||
            (key.id == 'alt' && modifier.alt);

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
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: textColor,
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

class _MicButton extends ConsumerWidget {
  final bool isListening;
  final SttProviderType providerType;
  final Color accentColor;
  final Color textColor;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const _MicButton({
    required this.isListening,
    required this.providerType,
    required this.accentColor,
    required this.textColor,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(sttAvailableProvider);
    final isAvailable = available.valueOrNull ?? false;
    if (!isAvailable) return const SizedBox.shrink();

    final child = Container(
      width: 44,
      height: double.infinity,
      alignment: Alignment.center,
      child: Icon(
        isListening ? Icons.mic : Icons.mic_none,
        size: 20,
        color: isListening ? accentColor : textColor,
      ),
    );

    if (providerType == SttProviderType.volcengine) {
      return GestureDetector(
        onLongPressStart: (_) => onLongPressStart(),
        onLongPressEnd: (_) => onLongPressEnd(),
        child: child,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}
