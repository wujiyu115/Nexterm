import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/terminal_themes.dart' as app_themes;
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:xterm/xterm.dart';

/// Wrapper around xterm's [TerminalView] widget.
///
/// It looks up the correct [Terminal] instance for the given [tab] from the
/// provider, applies the app's current terminal theme, and wires autofocus.
class TerminalViewWidget extends ConsumerWidget {
  final TerminalTab tab;

  const TerminalViewWidget({super.key, required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllers = ref.watch(terminalControllersProvider);
    final terminal = controllers[tab.id];

    if (terminal == null) {
      // Terminal not yet initialised (e.g., still connecting).
      return const Center(child: CircularProgressIndicator());
    }

    final isMobile = Platform.isIOS || Platform.isAndroid;

    return TerminalView(
      terminal,
      theme: app_themes.TerminalThemes.catppuccin,
      textStyle: const TerminalStyle(
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      textScaler: TextScaler.noScaling,
      autofocus: true,
      deleteDetection: true,
      hardwareKeyboardOnly: isMobile ? false : true,
    );
  }
}
