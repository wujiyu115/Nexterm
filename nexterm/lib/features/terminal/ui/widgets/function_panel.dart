import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_catalog.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
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
  final void Function(Uint8List data) onKeyInput;

  const FunctionPanel({
    super.key,
    required this.sessionId,
    required this.onCommandSelected,
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showTerminalThemePicker(BuildContext context) async {
    HapticFeedback.lightImpact();
    await showDialog<void>(
      context: context,
      builder: (ctx) => const _TerminalThemeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final bgColor = p.bgElevated;
    final headerColor = p.bg;

    return Container(
      height: 260,
      color: bgColor,
      child: Column(
        children: [
          Container(
            color: headerColor,
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: p.fg,
                    unselectedLabelColor: p.fgTertiary,
                    indicatorColor: p.accent,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600),
                    tabs: [
                      Tab(
                        icon: Text(
                          '{}',
                          style: theme.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Tab(icon: Icon(Icons.history, size: 18)),
                      const Tab(icon: Icon(Icons.app_shortcut, size: 18)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.settings_theme,
                  icon: Icon(
                    Icons.palette_outlined,
                    size: 18,
                    color: p.fgSecondary,
                  ),
                  onPressed: () => _showTerminalThemePicker(context),
                ),
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
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
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

    final buttonColor = p.surfaceSolid;
    final activeColor = p.accent;
    final textColor = p.fg;
    final activeTextColor = p.brightness == Brightness.dark ? p.bg : Colors.white;

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
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: isActive ? activeTextColor : textColor,
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
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;

    return snippetsAsync.when(
      data: (snippets) {
        if (snippets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.code, size: 40, color: p.fgTertiary),
                const SizedBox(height: 8),
                Text(
                  l.function_noSnippets,
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: p.fgSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.function_noSnippetsHint,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: p.fgTertiary,
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
            color: p.border,
          ),
          itemBuilder: (context, index) {
            final snippet = snippets[index];
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: Icon(
                snippet.variables.isEmpty ? Icons.terminal : Icons.edit_note,
                color: p.accent,
                size: 20,
              ),
              title: Text(
                snippet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                snippet.command,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall!.copyWith(
                  fontFamily: AppFonts.mono,
                  color: p.fgSecondary,
                ),
              ),
              trailing: snippet.isFavorite
                  ? Icon(Icons.star, size: 14, color: p.accent)
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
          style: TextStyle(color: p.fgSecondary),
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
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    return Center(
      child: Text(
        message,
        style: theme.textTheme.bodyLarge!.copyWith(
          color: p.fgSecondary,
        ),
      ),
    );
  }
}

// ---------- Inline terminal theme picker (shares state with Settings) ----------

class _TerminalThemeSheet extends ConsumerWidget {
  const _TerminalThemeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final current = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.settings_selectTheme,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildGroup(context, l.settings_themeGroupDark, ThemeCatalog.darkKeys, current, p.accent, notifier),
                  _buildGroup(context, l.settings_themeGroupLight, ThemeCatalog.lightKeys, current, p.accent, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, String label, List<String> keys, String current, Color accent, ThemeNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final key in keys)
          _buildRow(context, key, key == current, accent, () {
            notifier.setTheme(key);
            Navigator.of(context).pop();
          }),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String themeKey, bool isSelected, Color accent, VoidCallback onTap) {
    final palette = ThemeCatalog.byKey(themeKey);
    final swatches = [
      palette.terminal.black,
      palette.terminal.red,
      palette.terminal.green,
      palette.terminal.yellow,
      palette.terminal.blue,
    ];
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ThemeCatalog.displayName(themeKey),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            for (final swatch in swatches)
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.check,
              size: 18,
              color: isSelected ? accent : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}