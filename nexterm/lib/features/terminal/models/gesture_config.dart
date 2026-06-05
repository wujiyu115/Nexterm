import 'dart:convert';

enum GestureType {
  twoFingerTap,
  swipeLeft,
  swipeRight,
  swipeDown,
}

enum GestureAction {
  paste,
  copy,
  switchTabLeft,
  switchTabRight,
  toggleDpad,
  toggleKeyboard,
  none,
}

class GestureBinding {
  final GestureType gesture;
  final GestureAction action;

  const GestureBinding({required this.gesture, required this.action});

  Map<String, dynamic> toJson() => {
    'gesture': gesture.name,
    'action': action.name,
  };

  factory GestureBinding.fromJson(Map<String, dynamic> json) => GestureBinding(
    gesture: GestureType.values.firstWhere(
      (e) => e.name == json['gesture'],
      orElse: () => GestureType.twoFingerTap,
    ),
    action: GestureAction.values.firstWhere(
      (e) => e.name == json['action'],
      orElse: () => GestureAction.none,
    ),
  );

  static const defaultBindings = [
    GestureBinding(gesture: GestureType.twoFingerTap, action: GestureAction.paste),
    GestureBinding(gesture: GestureType.swipeLeft, action: GestureAction.switchTabRight),
    GestureBinding(gesture: GestureType.swipeRight, action: GestureAction.switchTabLeft),
    GestureBinding(gesture: GestureType.swipeDown, action: GestureAction.toggleKeyboard),
  ];

  static String encodeList(List<GestureBinding> bindings) =>
      jsonEncode(bindings.map((b) => b.toJson()).toList());

  static List<GestureBinding> decodeList(String json) {
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => GestureBinding.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return List.of(defaultBindings);
    }
  }
}
