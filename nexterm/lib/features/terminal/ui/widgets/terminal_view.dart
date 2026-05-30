import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/terminal_themes.dart' as app_themes;
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
  double _pinchBaseSize = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
final terminalThemeName =
        ref.watch(themeProvider.select((s) => s.terminalThemeName));
    final terminalTheme =
        app_themes.TerminalThemes.byName(terminalThemeName);
    final isMobile = Platform.isIOS || Platform.isAndroid;

    Widget child = TerminalView(
      terminal,
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
    }

    return child;
  }
}
