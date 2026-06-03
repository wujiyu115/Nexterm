import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_font_family_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_font_size_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:xterm/xterm.dart';

class TerminalViewWidget extends ConsumerStatefulWidget {
  final TerminalTab tab;
  final bool hardwareKeyboardOnly;

  const TerminalViewWidget({
    super.key,
    required this.tab,
    this.hardwareKeyboardOnly = false,
  });

  @override
  ConsumerState<TerminalViewWidget> createState() =>
      _TerminalViewWidgetState();
}

class _TerminalViewWidgetState extends ConsumerState<TerminalViewWidget> {
  final _scrollController = ScrollController();
  final _terminalController = TerminalController();
  double _pinchBaseSize = 0;
  bool _hasSelection = false;

  @override
  void initState() {
    super.initState();
    _terminalController.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    _terminalController.removeListener(_onSelectionChanged);
    _terminalController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    final hasSelection = _terminalController.selection != null;
    if (hasSelection != _hasSelection) {
      setState(() => _hasSelection = hasSelection);
    }
  }

  void _copySelection() {
    final controllers = ref.read(terminalControllersProvider);
    final terminal = controllers[widget.tab.id];
    final selection = _terminalController.selection;
    if (terminal == null || selection == null) return;

    final text = terminal.buffer.getText(selection);
    Clipboard.setData(ClipboardData(text: text));
    _terminalController.clearSelection();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = ref.watch(terminalControllersProvider);
    final terminal = controllers[widget.tab.id];

    if (terminal == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final fontSize = ref.watch(terminalFontSizeProvider);
    final fontFamily = ref.watch(terminalFontFamilyProvider);
    final terminalTheme = ref.watch(paletteProvider).terminal;
    final isMobile = Platform.isIOS || Platform.isAndroid;

    Widget child = TerminalView(
      terminal,
      controller: _terminalController,
      theme: terminalTheme,
      textStyle: TerminalStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
      ),
      textScaler: TextScaler.noScaling,
      scrollController: _scrollController,
      autofocus: true,
      deleteDetection: true,
      hardwareKeyboardOnly: isMobile ? widget.hardwareKeyboardOnly : true,
    );

    if (isMobile) {
      child = GestureDetector(
        onScaleStart: (_) {
          _pinchBaseSize = ref.read(terminalFontSizeProvider);
        },
        onScaleUpdate: (details) {
          if (details.pointerCount >= 2) {
            final newSize = (_pinchBaseSize * details.scale).clamp(8.0, 24.0);
            ref.read(terminalFontSizeProvider.notifier).setSize(newSize);
          }
        },
        child: child,
      );

      if (_hasSelection) {
        child = Stack(
          children: [
            child,
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _copySelection,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }

    return child;
  }
}
