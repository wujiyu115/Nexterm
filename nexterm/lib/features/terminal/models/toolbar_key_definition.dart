import 'dart:typed_data';

import 'package:nexterm/l10n/app_localizations.dart';

/// Represents a single key button on the toolbar.
class ToolbarKeyDef {
  final String id;
  final String label;
  final String groupId;
  final Uint8List bytes;

  const ToolbarKeyDef({
    required this.id,
    required this.label,
    required this.groupId,
    required this.bytes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'groupId': groupId,
        'bytes': bytes.toList(),
      };

  factory ToolbarKeyDef.fromJson(Map<String, dynamic> json) => ToolbarKeyDef(
        id: json['id'] as String,
        label: json['label'] as String,
        groupId: json['groupId'] as String,
        bytes: Uint8List.fromList((json['bytes'] as List).cast<int>()),
      );
}

/// Represents a group of keys displayed together on the toolbar.
class ToolbarKeyGroup {
  final String id;
  final String name;
  final List<ToolbarKeyDef> keys;

  const ToolbarKeyGroup({
    required this.id,
    required this.name,
    required this.keys,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'keys': keys.map((k) => k.toJson()).toList(),
      };

  factory ToolbarKeyGroup.fromJson(Map<String, dynamic> json) =>
      ToolbarKeyGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        keys: (json['keys'] as List)
            .map((k) => ToolbarKeyDef.fromJson(k as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// ANSI / byte constants
// ---------------------------------------------------------------------------

final _esc = Uint8List.fromList([0x1B]);
final _tab = Uint8List.fromList([0x09]);
final _del = Uint8List.fromList([0x1B, 0x5B, 0x33, 0x7E]); // ESC[3~
final _ins = Uint8List.fromList([0x1B, 0x5B, 0x32, 0x7E]); // ESC[2~
final _home = Uint8List.fromList([0x1B, 0x5B, 0x48]); // ESC[H
final _end = Uint8List.fromList([0x1B, 0x5B, 0x46]); // ESC[F
final _pgUp = Uint8List.fromList([0x1B, 0x5B, 0x35, 0x7E]); // ESC[5~
final _pgDn = Uint8List.fromList([0x1B, 0x5B, 0x36, 0x7E]); // ESC[6~
final _arrowUp = Uint8List.fromList([0x1B, 0x5B, 0x41]);
final _arrowDown = Uint8List.fromList([0x1B, 0x5B, 0x42]);
final _arrowRight = Uint8List.fromList([0x1B, 0x5B, 0x43]);
final _arrowLeft = Uint8List.fromList([0x1B, 0x5B, 0x44]);

Uint8List _char(String c) => Uint8List.fromList(c.codeUnits);
Uint8List _ctrl(String c) =>
    Uint8List.fromList([c.toUpperCase().codeUnitAt(0) - 64]);
Uint8List _fKey(int n) {
  // F1–F4: ESC O P/Q/R/S
  if (n >= 1 && n <= 4) {
    return Uint8List.fromList([0x1B, 0x4F, 0x50 + n - 1]);
  }
  // F5–F12: ESC [ <code> ~
  const codes = {
    5: '15',
    6: '17',
    7: '18',
    8: '19',
    9: '20',
    10: '21',
    11: '23',
    12: '24',
  };
  final code = codes[n]!;
  return Uint8List.fromList([0x1B, 0x5B, ...code.codeUnits, 0x7E]);
}

Uint8List _altR() => Uint8List.fromList([0x1B, 0x72]); // Alt-r
Uint8List _ctrlXX() =>
    Uint8List.fromList([0x18, 0x18]); // ^X^X (Ctrl-X twice)

// ---------------------------------------------------------------------------
// Default groups
// ---------------------------------------------------------------------------

List<ToolbarKeyGroup> get defaultToolbarGroups => [
      ToolbarKeyGroup(id: 'arrows', name: '方向键', keys: [
        ToolbarKeyDef(id: 'arrow_left', label: '←', groupId: 'arrows', bytes: _arrowLeft),
        ToolbarKeyDef(id: 'arrow_up', label: '↑', groupId: 'arrows', bytes: _arrowUp),
        ToolbarKeyDef(id: 'arrow_down', label: '↓', groupId: 'arrows', bytes: _arrowDown),
        ToolbarKeyDef(id: 'arrow_right', label: '→', groupId: 'arrows', bytes: _arrowRight),
      ]),
      ToolbarKeyGroup(id: 'clipboard', name: '剪贴板', keys: [
        ToolbarKeyDef(id: 'paste', label: 'Paste', groupId: 'clipboard', bytes: Uint8List(0)),
        ToolbarKeyDef(id: 'ctrl_u', label: '^U', groupId: 'clipboard', bytes: _ctrl('U')),
        ToolbarKeyDef(id: 'ctrl_k', label: '^K', groupId: 'clipboard', bytes: _ctrl('K')),
        ToolbarKeyDef(id: 'ctrl_y', label: '^Y', groupId: 'clipboard', bytes: _ctrl('Y')),
      ]),
      ToolbarKeyGroup(id: 'terminal_ctrl', name: '终端控制', keys: [
        ToolbarKeyDef(id: 'esc', label: 'Esc', groupId: 'terminal_ctrl', bytes: _esc),
        ToolbarKeyDef(id: 'tab', label: 'Tab', groupId: 'terminal_ctrl', bytes: _tab),
        ToolbarKeyDef(id: 'ctrl', label: 'Ctrl', groupId: 'terminal_ctrl', bytes: Uint8List(0)),
        ToolbarKeyDef(id: 'alt', label: 'Alt', groupId: 'terminal_ctrl', bytes: Uint8List(0)),
      ]),
      ToolbarKeyGroup(id: 'signals', name: '信号', keys: [
        ToolbarKeyDef(id: 'ctrl_c', label: '^C', groupId: 'signals', bytes: _ctrl('C')),
        ToolbarKeyDef(id: 'ctrl_d', label: '^D', groupId: 'signals', bytes: _ctrl('D')),
        ToolbarKeyDef(id: 'ctrl_z', label: '^Z', groupId: 'signals', bytes: _ctrl('Z')),
        ToolbarKeyDef(id: 'ctrl_s', label: '^S', groupId: 'signals', bytes: _ctrl('S')),
      ]),
      ToolbarKeyGroup(id: 'symbols1', name: '符号 1', keys: [
        ToolbarKeyDef(id: 'slash', label: '/', groupId: 'symbols1', bytes: _char('/')),
        ToolbarKeyDef(id: 'pipe', label: '|', groupId: 'symbols1', bytes: _char('|')),
        ToolbarKeyDef(id: 'tilde', label: '~', groupId: 'symbols1', bytes: _char('~')),
        ToolbarKeyDef(id: 'dash', label: '-', groupId: 'symbols1', bytes: _char('-')),
      ]),
      ToolbarKeyGroup(id: 'navigation', name: '导航', keys: [
        ToolbarKeyDef(id: 'home', label: 'Home', groupId: 'navigation', bytes: _home),
        ToolbarKeyDef(id: 'pgup', label: 'PgUp', groupId: 'navigation', bytes: _pgUp),
        ToolbarKeyDef(id: 'pgdn', label: 'PgDn', groupId: 'navigation', bytes: _pgDn),
        ToolbarKeyDef(id: 'end', label: 'End', groupId: 'navigation', bytes: _end),
      ]),
      ToolbarKeyGroup(id: 'editing', name: '编辑', keys: [
        ToolbarKeyDef(id: 'del', label: 'Del', groupId: 'editing', bytes: _del),
        ToolbarKeyDef(id: 'ins', label: 'Ins', groupId: 'editing', bytes: _ins),
        ToolbarKeyDef(id: 'at', label: '@', groupId: 'editing', bytes: _char('@')),
        ToolbarKeyDef(id: 'question', label: '?', groupId: 'editing', bytes: _char('?')),
      ]),
      ToolbarKeyGroup(id: 'search', name: '搜索', keys: [
        ToolbarKeyDef(id: 'ctrl_r', label: '^R', groupId: 'search', bytes: _ctrl('R')),
        ToolbarKeyDef(id: 'ctrl_g', label: '^G', groupId: 'search', bytes: _ctrl('G')),
        ToolbarKeyDef(id: 'ctrl_n', label: '^N', groupId: 'search', bytes: _ctrl('N')),
        ToolbarKeyDef(id: 'ctrl_p', label: '^P', groupId: 'search', bytes: _ctrl('P')),
      ]),
      ToolbarKeyGroup(id: 'punctuation', name: '标点', keys: [
        ToolbarKeyDef(id: 'equals', label: '=', groupId: 'punctuation', bytes: _char('=')),
        ToolbarKeyDef(id: 'colon', label: ':', groupId: 'punctuation', bytes: _char(':')),
        ToolbarKeyDef(id: 'semicolon', label: ';', groupId: 'punctuation', bytes: _char(';')),
        ToolbarKeyDef(id: 'excl', label: '!', groupId: 'punctuation', bytes: _char('!')),
      ]),
      ToolbarKeyGroup(id: 'symbols2', name: '符号 2', keys: [
        ToolbarKeyDef(id: 'star', label: '*', groupId: 'symbols2', bytes: _char('*')),
        ToolbarKeyDef(id: 'dollar', label: r'$', groupId: 'symbols2', bytes: _char(r'$')),
        ToolbarKeyDef(id: 'percent', label: '%', groupId: 'symbols2', bytes: _char('%')),
        ToolbarKeyDef(id: 'caret', label: '^', groupId: 'symbols2', bytes: _char('^')),
      ]),
      ToolbarKeyGroup(id: 'brackets1', name: '括号 1', keys: [
        ToolbarKeyDef(id: 'lt', label: '<', groupId: 'brackets1', bytes: _char('<')),
        ToolbarKeyDef(id: 'gt', label: '>', groupId: 'brackets1', bytes: _char('>')),
        ToolbarKeyDef(id: 'lparen', label: '(', groupId: 'brackets1', bytes: _char('(')),
        ToolbarKeyDef(id: 'rparen', label: ')', groupId: 'brackets1', bytes: _char(')')),
      ]),
      ToolbarKeyGroup(id: 'brackets2', name: '括号 2', keys: [
        ToolbarKeyDef(id: 'lbrace', label: '{', groupId: 'brackets2', bytes: _char('{')),
        ToolbarKeyDef(id: 'rbrace', label: '}', groupId: 'brackets2', bytes: _char('}')),
        ToolbarKeyDef(id: 'lbracket', label: '[', groupId: 'brackets2', bytes: _char('[')),
        ToolbarKeyDef(id: 'rbracket', label: ']', groupId: 'brackets2', bytes: _char(']')),
      ]),
      ToolbarKeyGroup(id: 'fkeys1', name: 'F1–F4', keys: [
        ToolbarKeyDef(id: 'f1', label: 'F1', groupId: 'fkeys1', bytes: _fKey(1)),
        ToolbarKeyDef(id: 'f2', label: 'F2', groupId: 'fkeys1', bytes: _fKey(2)),
        ToolbarKeyDef(id: 'f3', label: 'F3', groupId: 'fkeys1', bytes: _fKey(3)),
        ToolbarKeyDef(id: 'f4', label: 'F4', groupId: 'fkeys1', bytes: _fKey(4)),
      ]),
      ToolbarKeyGroup(id: 'fkeys2', name: 'F5–F8', keys: [
        ToolbarKeyDef(id: 'f5', label: 'F5', groupId: 'fkeys2', bytes: _fKey(5)),
        ToolbarKeyDef(id: 'f6', label: 'F6', groupId: 'fkeys2', bytes: _fKey(6)),
        ToolbarKeyDef(id: 'f7', label: 'F7', groupId: 'fkeys2', bytes: _fKey(7)),
        ToolbarKeyDef(id: 'f8', label: 'F8', groupId: 'fkeys2', bytes: _fKey(8)),
      ]),
      ToolbarKeyGroup(id: 'fkeys3', name: 'F9–F12', keys: [
        ToolbarKeyDef(id: 'f9', label: 'F9', groupId: 'fkeys3', bytes: _fKey(9)),
        ToolbarKeyDef(id: 'f10', label: 'F10', groupId: 'fkeys3', bytes: _fKey(10)),
        ToolbarKeyDef(id: 'f11', label: 'F11', groupId: 'fkeys3', bytes: _fKey(11)),
        ToolbarKeyDef(id: 'f12', label: 'F12', groupId: 'fkeys3', bytes: _fKey(12)),
      ]),
      ToolbarKeyGroup(id: 'advanced', name: '高级控制', keys: [
        ToolbarKeyDef(id: 'ctrl_underscore', label: '^_', groupId: 'advanced', bytes: _ctrl('_')),
        ToolbarKeyDef(id: 'ctrl_l', label: '^L', groupId: 'advanced', bytes: _ctrl('L')),
        ToolbarKeyDef(id: 'alt_r', label: 'Alt-r', groupId: 'advanced', bytes: _altR()),
        ToolbarKeyDef(id: 'ctrl_x_x', label: '^X^X', groupId: 'advanced', bytes: _ctrlXX()),
      ]),
    ];

/// Flattens all default groups into a single list of key definitions.
List<ToolbarKeyDef> get allToolbarKeys =>
    defaultToolbarGroups.expand((g) => g.keys).toList();

String toolbarGroupName(String groupId, AppLocalizations l) {
  return switch (groupId) {
    'arrows' => l.toolbar_groupArrows,
    'clipboard' => l.toolbar_groupClipboard,
    'terminal_ctrl' => l.toolbar_groupTerminalCtrl,
    'signals' => l.toolbar_groupSignals,
    'symbols1' => l.toolbar_groupSymbols1,
    'navigation' => l.toolbar_groupNavigation,
    'editing' => l.toolbar_groupEditing,
    'search' => l.toolbar_groupSearch,
    'punctuation' => l.toolbar_groupPunctuation,
    'symbols2' => l.toolbar_groupSymbols2,
    'brackets1' => l.toolbar_groupBrackets1,
    'brackets2' => l.toolbar_groupBrackets2,
    'advanced' => l.toolbar_groupAdvanced,
    _ => groupId,
  };
}
