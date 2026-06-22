import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/terminal/providers/stt_provider.dart';
import 'package:nexterm/features/terminal/providers/voice_locale_provider.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class ComposerPanel extends ConsumerStatefulWidget {
  final void Function(Uint8List data) onKeyInput;
  final VoidCallback onClose;
  final VoidCallback onAttach;

  const ComposerPanel({
    super.key,
    required this.onKeyInput,
    required this.onClose,
    required this.onAttach,
  });

  @override
  ConsumerState<ComposerPanel> createState() => ComposerPanelState();
}

class ComposerPanelState extends ConsumerState<ComposerPanel>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isListening = false;
  bool _chatMode = true;
  StreamSubscription<SttResult>? _sttSub;
  SttProvider? _activeSttProvider;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sttSub?.cancel();
    _activeSttProvider?.stop();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    final payload = _chatMode ? '$text\r' : text;
    widget.onKeyInput(Uint8List.fromList(utf8.encode(payload)));
    _controller.clear();
    _focusNode.requestFocus();
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
    _sttSub?.cancel();
    _activeSttProvider = ref.read(sttProviderInstanceProvider);
    final provider = _activeSttProvider!;
    final localeId = ref.read(voiceLocaleIdProvider);
    setState(() {
      _isListening = true;
      _pulseController.repeat();
    });
    final stream = provider.start(localeId: localeId.isEmpty ? null : localeId);
    String lastText = '';
    bool sentFinal = false;
    _sttSub = stream.listen(
      (result) {
        if (result.text.isNotEmpty) {
          lastText = result.text;
        }
        if (result.isFinal && result.text.isNotEmpty) {
          sentFinal = true;
          _insertText(result.text);
        }
      },
      onDone: () {
        if (!sentFinal && lastText.isNotEmpty && mounted) {
          _insertText(lastText);
        }
        _sttSub = null;
        if (mounted) {
          setState(() {
            _isListening = false;
            _pulseController.stop();
            _pulseController.reset();
          });
        }
      },
      onError: (_) {
        _sttSub = null;
        if (mounted) {
          setState(() {
            _isListening = false;
            _pulseController.stop();
            _pulseController.reset();
          });
        }
      },
    );
  }

  void _stopListening() {
    _activeSttProvider?.stop();
    _activeSttProvider = null;
    setState(() {
      _isListening = false;
      _pulseController.stop();
      _pulseController.reset();
    });
  }

  void _onLongPressStart() {
    HapticFeedback.lightImpact();
    _startListening();
  }

  void _onLongPressEnd() {
    _stopListening();
  }

  void _insertText(String text) {
    final selection = _controller.selection;
    final currentText = _controller.text;
    final newText = currentText.replaceRange(
      selection.start.clamp(0, currentText.length),
      selection.end.clamp(0, currentText.length),
      text,
    );
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start.clamp(0, currentText.length) + text.length,
      ),
    );
  }

  void insertFilePath(String path) {
    _insertText(path);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final providerType = ref.watch(sttProviderTypeProvider);
    final inputMode = ref.watch(voiceInputModeProvider);
    final sttAvailable = ref.watch(sttAvailableProvider).valueOrNull ?? false;

    return Container(
      decoration: BoxDecoration(
        color: p.bgElevated,
        border: Border(top: BorderSide(color: p.border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
        12, 10, 12,
        10 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: Scrollbar(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(color: p.fg, fontSize: 15),
                decoration: InputDecoration(
                  hintText: l.composer_placeholder,
                  hintStyle: TextStyle(color: p.fgTertiary),
                  filled: true,
                  fillColor: p.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
                minLines: 3,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _CircleButton(
                icon: Icons.add,
                color: p.fgSecondary,
                bgColor: p.surface,
                onTap: widget.onAttach,
              ),
              const SizedBox(width: 8),
              _CircleButton(
                icon: Icons.close,
                color: p.fgSecondary,
                bgColor: p.surface,
                onTap: widget.onClose,
              ),
              const SizedBox(width: 8),
              _CircleButton(
                icon: Icons.keyboard_hide,
                color: p.fgSecondary,
                bgColor: p.surface,
                onTap: () => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(width: 8),
              _CircleButton(
                icon: _chatMode ? Icons.keyboard_return : Icons.text_fields,
                color: _chatMode ? Colors.white : p.fgSecondary,
                bgColor: _chatMode ? p.accent : p.surface,
                onTap: () => setState(() => _chatMode = !_chatMode),
              ),
              const Spacer(),
              if (sttAvailable)
                _buildMicButton(p, providerType, inputMode),
              const SizedBox(width: 8),
              _CircleButton(
                icon: Icons.arrow_upward,
                color: Colors.white,
                bgColor: p.accent,
                onTap: _send,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _providerLabel(SttProviderType type) => switch (type) {
    SttProviderType.system => 'SYS',
    SttProviderType.volcengine => '豆包',
    SttProviderType.alibaba => 'ALI',
  };

  Widget _buildMicButton(ThemePalette p, SttProviderType providerType, VoiceInputMode inputMode) {
    final label = _providerLabel(providerType);
    final isLongPress = inputMode == VoiceInputMode.longPress;

    final button = _CircleButton(
      icon: _isListening ? Icons.mic : Icons.mic_none,
      color: _isListening ? Colors.white : p.fgSecondary,
      bgColor: _isListening ? p.accent : p.surface,
      glowColor: _isListening ? p.accentGlow : null,
      onTap: isLongPress ? null : _toggleSpeech,
    );

    final micWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        if (_isListening)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseScale.value,
                  child: Opacity(
                    opacity: _pulseOpacity.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: p.accent, width: 1.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        button,
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: p.accent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 7, color: Colors.white, height: 1.1, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );

    if (isLongPress) {
      return GestureDetector(
        onLongPressStart: (_) => _onLongPressStart(),
        onLongPressEnd: (_) => _onLongPressEnd(),
        child: micWidget,
      );
    }

    return micWidget;
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color? glowColor;
  final VoidCallback? onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: glowColor != null
              ? [BoxShadow(color: glowColor!, blurRadius: 10, spreadRadius: 1)]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
