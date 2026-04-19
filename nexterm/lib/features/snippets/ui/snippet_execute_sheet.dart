import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';
import 'package:nexterm/features/snippets/utils/variable_parser.dart';

/// Modal bottom sheet that lets the user pick a snippet and send it to
/// the terminal. If the snippet contains variables, a dialog is shown first
/// so the user can fill in values.
///
/// [onExecute] receives the final command string (with substituted variables
/// and a trailing newline) to write to the SSH session.
class SnippetExecuteSheet extends ConsumerStatefulWidget {
  final void Function(String command) onExecute;

  const SnippetExecuteSheet({super.key, required this.onExecute});

  @override
  ConsumerState<SnippetExecuteSheet> createState() => _SnippetExecuteSheetState();
}

class _SnippetExecuteSheetState extends ConsumerState<SnippetExecuteSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _execute(BuildContext context, SnippetEntity snippet) async {
    if (snippet.variables.isEmpty) {
      widget.onExecute('${snippet.command}\n');
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    // Show variable substitution dialog
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _VariableDialog(snippet: snippet),
    );

    if (values != null) {
      final command = VariableParser.substitute(snippet.command, values);
      widget.onExecute('$command\n');
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final snippetsAsync = _searchQuery.isEmpty
        ? ref.watch(snippetsStreamProvider)
        : ref.watch(snippetSearchProvider(_searchQuery)).whenData((list) => list);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Text(
                    '选择片段',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索片段...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: snippetsAsync.when(
                data: (snippets) {
                  if (snippets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty ? '暂无代码片段' : '未找到匹配片段',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: snippets.length,
                    itemBuilder: (ctx, i) {
                      final snippet = snippets[i];
                      return _SnippetSheetTile(
                        snippet: snippet,
                        onTap: () => _execute(context, snippet),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('错误: $e')),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SnippetSheetTile extends StatelessWidget {
  final SnippetEntity snippet;
  final VoidCallback onTap;

  const _SnippetSheetTile({required this.snippet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        snippet.variables.isEmpty ? Icons.terminal : Icons.edit_note,
        color: colorScheme.primary,
        size: 22,
      ),
      title: Text(snippet.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        snippet.command,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: snippet.isFavorite
          ? const Icon(Icons.star, size: 16, color: Colors.amber)
          : null,
      onTap: onTap,
    );
  }
}

/// Dialog that collects values for snippet variables before execution.
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
    return AlertDialog(
      title: Text('填写变量 — ${widget.snippet.name}'),
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
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final values = {
              for (final entry in _controllers.entries) entry.key: entry.value.text,
            };
            Navigator.of(context).pop(values);
          },
          child: const Text('执行'),
        ),
      ],
    );
  }
}
