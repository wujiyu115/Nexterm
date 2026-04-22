import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';
import 'package:nexterm/features/snippets/utils/variable_parser.dart';
import 'package:nexterm/features/terminal/models/toolbar_key_definition.dart';
import 'package:nexterm/features/terminal/providers/toolbar_modifier_provider.dart';
import 'package:nexterm/features/terminal/providers/toolbar_usage_provider.dart';
import 'package:nexterm/features/terminal/ui/widgets/command_history_panel.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class FunctionPanel extends ConsumerStatefulWidget {
  final String? sessionId;
  final void Function(String command) onCommandSelected;
  final VoidCallback onSwitchToAbc;
  final void Function(Uint8List data) onKeyInput;

  const FunctionPanel({
    super.key,
    required this.sessionId,
    required this.onCommandSelected,
    required this.onSwitchToAbc,
    required this.onKeyInput,
  });

  @override
  ConsumerState<FunctionPanel> createState() => _FunctionPanelState();
}

class _FunctionPanelState extends ConsumerState<FunctionPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 3) {
        widget.onSwitchToAbc();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F5);
    final headerColor = isDark ? const Color(0xFF181825) : const Color(0xFFE0E0EA);

    return Container(
      height: 260,
      color: bgColor,
      child: Column(
        children: [
          Container(
            color: headerColor,
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? Colors.white : Colors.black87,
              unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                Tab(icon: const Text('{}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Tab(icon: const Icon(Icons.history, size: 18)),
                Tab(icon: const Icon(Icons.app_shortcut, size: 18)),
                Tab(icon: const Icon(Icons.keyboard, size: 18)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SnippetsTab(onCommandSelected: widget.onCommandSelected),
                widget.sessionId != null
                    ? CommandHistoryPanel(
                        sessionId: widget.sessionId!,
                        onCommandSelected: widget.onCommandSelected,
                      )
                    : _EmptyTab(message: l.function_noActiveSession),
                _AllShortcutsOverlayInline(onKeyInput: widget.onKeyInput),
                _EmptyTab(message: l.function_switchToKeyboard),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllShortcutsOverlayInline extends ConsumerWidget {
  final void Function(Uint8List data) onKeyInput;

  const _AllShortcutsOverlayInline({required this.onKeyInput});

  void _onKeyTap(WidgetRef ref, ToolbarKeyDef key) {
    HapticFeedback.lightImpact();
    final modifier = ref.read(toolbarModifierProvider);

    if (key.id == 'ctrl') {
      ref.read(toolbarModifierProvider.notifier).toggleCtrl();
      return;
    }
    if (key.id == 'alt') {
      ref.read(toolbarModifierProvider.notifier).toggleAlt();
      return;
    }
    if (key.id == 'paste') {
      _pasteFromClipboard(ref);
      return;
    }

    Uint8List bytes = key.bytes;
    if (modifier.ctrl) {
      if (bytes.length == 1 && bytes[0] >= 0x40 && bytes[0] <= 0x7F) {
        bytes = Uint8List.fromList([bytes[0] & 0x1F]);
      } else if (bytes.length >= 3 && bytes[0] == 0x1B) {
        bytes = _applyEscModifier(bytes, 5);
      }
      ref.read(toolbarModifierProvider.notifier).reset();
    } else if (modifier.alt) {
      if (bytes.length == 1) {
        bytes = Uint8List.fromList([0x1B, ...bytes]);
      } else if (bytes.length >= 3 && bytes[0] == 0x1B) {
        bytes = _applyEscModifier(bytes, 3);
      }
      ref.read(toolbarModifierProvider.notifier).reset();
    }

    onKeyInput(bytes);
    ref.read(toolbarUsageProvider.notifier).increment(key.id);
  }

  Future<void> _pasteFromClipboard(WidgetRef ref) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      final bytes = Uint8List.fromList(data.text!.codeUnits);
      onKeyInput(bytes);
    }
  }

  static Uint8List _applyEscModifier(Uint8List bytes, int mod) {
    if (bytes.length < 3 || bytes[0] != 0x1B) return bytes;
    if (bytes[1] == 0x4F && bytes.length == 3) {
      return Uint8List.fromList([0x1B, 0x5B, 0x31, 0x3B, 0x30 + mod, bytes[2]]);
    }
    if (bytes[1] == 0x5B) {
      final finalByte = bytes.last;
      final params = bytes.sublist(2, bytes.length - 1);
      if (params.isEmpty) {
        return Uint8List.fromList([0x1B, 0x5B, 0x31, 0x3B, 0x30 + mod, finalByte]);
      } else {
        return Uint8List.fromList([0x1B, 0x5B, ...params, 0x3B, 0x30 + mod, finalByte]);
      }
    }
    return bytes;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usage = ref.watch(toolbarUsageProvider);
    final modifier = ref.watch(toolbarModifierProvider);

    final keys = allToolbarKeys.toList();
    keys.sort((a, b) {
      final aCount = usage[a.id] ?? 0;
      final bCount = usage[b.id] ?? 0;
      if (aCount != bCount) return bCount - aCount;
      final aIdx = allToolbarKeys.indexWhere((k) => k.id == a.id);
      final bIdx = allToolbarKeys.indexWhere((k) => k.id == b.id);
      return aIdx - bIdx;
    });

    final buttonColor = isDark ? const Color(0xFF313244) : const Color(0xFFD0D0E0);
    final activeColor = isDark ? const Color(0xFF89B4FA) : const Color(0xFF1E66F5);
    final textColor = isDark ? const Color(0xFFCDD6F4) : const Color(0xFF1C1C2E);
    final activeTextColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return Column(
      children: [
        if (modifier.ctrl || modifier.alt)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
            child: Row(
              children: [
                if (modifier.ctrl)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: const Text('Ctrl'),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (modifier.alt)
                  Chip(
                    label: const Text('Alt'),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final isActive =
                  (key.id == 'ctrl' && modifier.ctrl) ||
                  (key.id == 'alt' && modifier.alt);

              return GestureDetector(
                onTap: () => _onKeyTap(ref, key),
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : buttonColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    key.label,
                    style: TextStyle(
                      color: isActive ? activeTextColor : textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SnippetsTab extends ConsumerWidget {
  final void Function(String command) onCommandSelected;

  const _SnippetsTab({required this.onCommandSelected});

  Future<void> _execute(BuildContext context, SnippetEntity snippet) async {
    if (snippet.variables.isEmpty) {
      final lines = VariableParser.splitLines(snippet.command);
      for (final line in lines) {
        onCommandSelected(line);
      }
      return;
    }

    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _VariableDialog(snippet: snippet),
    );

    if (values != null) {
      final command = VariableParser.substitute(snippet.command, values);
      final lines = VariableParser.splitLines(command);
      for (final line in lines) {
        onCommandSelected(line);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final snippetsAsync = ref.watch(snippetsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return snippetsAsync.when(
      data: (snippets) {
        if (snippets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.code, size: 40, color: isDark ? Colors.white24 : Colors.black26),
                const SizedBox(height: 8),
                Text(
                  l.function_noSnippets,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.function_noSnippetsHint,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: snippets.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          itemBuilder: (context, index) {
            final snippet = snippets[index];
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                snippet.variables.isEmpty ? Icons.terminal : Icons.edit_note,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              title: Text(
                snippet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              subtitle: Text(
                snippet.command,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
              trailing: snippet.isFavorite
                  ? const Icon(Icons.star, size: 14, color: Colors.amber)
                  : null,
              onTap: () => _execute(context, snippet),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        ),
      ),
    );
  }
}

class _VariableDialog extends StatefulWidget {
  final SnippetEntity snippet;
  const _VariableDialog({required this.snippet});

  @override
  State<_VariableDialog> createState() => _VariableDialogState();
}

class _VariableDialogState extends State<_VariableDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final v in widget.snippet.variables)
        v.name: TextEditingController(text: v.defaultValue ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.snippetExecute_fillVariables(widget.snippet.name)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.snippet.variables.map((v) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllers[v.name],
                decoration: InputDecoration(
                  labelText: v.name,
                  hintText: v.defaultValue ?? '',
                  helperText: v.description,
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.common_cancel),
        ),
        FilledButton(
          onPressed: () {
            final values = {
              for (final entry in _controllers.entries) entry.key: entry.value.text,
            };
            Navigator.of(context).pop(values);
          },
          child: Text(l.snippetExecute_execute),
        ),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String message;
  const _EmptyTab({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 14,
        ),
      ),
    );
  }
}