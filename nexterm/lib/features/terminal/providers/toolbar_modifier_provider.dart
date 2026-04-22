import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToolbarModifierState {
  final bool ctrl;
  final bool alt;
  const ToolbarModifierState({this.ctrl = false, this.alt = false});

  bool get isActive => ctrl || alt;
}

class ToolbarModifierNotifier extends StateNotifier<ToolbarModifierState> {
  ToolbarModifierNotifier() : super(const ToolbarModifierState());

  void toggleCtrl() {
    state = ToolbarModifierState(ctrl: !state.ctrl);
  }

  void toggleAlt() {
    state = ToolbarModifierState(alt: !state.alt);
  }

  void reset() {
    state = const ToolbarModifierState();
  }
}

final toolbarModifierProvider =
    StateNotifierProvider<ToolbarModifierNotifier, ToolbarModifierState>(
  (ref) => ToolbarModifierNotifier(),
);
