import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';
import 'package:nexterm/features/snippets/utils/variable_parser.dart';
import 'package:uuid/uuid.dart';

class SnippetFormScreen extends ConsumerStatefulWidget {
  final String? snippetId;
  const SnippetFormScreen({super.key, this.snippetId});

  @override
  ConsumerState<SnippetFormScreen> createState() => _SnippetFormScreenState();
}

class _SnippetFormScreenState extends ConsumerState<SnippetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _commandController = TextEditingController();
  final _groupController = TextEditingController();
  final _tagsController = TextEditingController();

  List<String> _detectedVariables = [];
  final Map<String, TextEditingController> _variableControllers = {};
  final Map<String, TextEditingController> _variableDescControllers = {};

  bool _isLoading = false;
  bool _isInitialized = false;
  SnippetEntity? _existingSnippet;

  bool get _isEditMode => widget.snippetId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _commandController.dispose();
    _groupController.dispose();
    _tagsController.dispose();
    for (final c in _variableControllers.values) {
      c.dispose();
    }
    for (final c in _variableDescControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSnippet() async {
    if (_isInitialized || !_isEditMode) {
      _isInitialized = true;
      return;
    }
    _isInitialized = true;
    final snippet = await ref.read(snippetRepositoryProvider).getById(widget.snippetId!);
    if (snippet != null && mounted) {
      setState(() {
        _existingSnippet = snippet;
        _nameController.text = snippet.name;
        _commandController.text = snippet.command;
        _groupController.text = snippet.group ?? '';
        _tagsController.text = snippet.tags.join(', ');
        _updateVariables(snippet.command, existingVariables: snippet.variables);
      });
    }
  }

  void _updateVariables(String command, {List<SnippetVariable>? existingVariables}) {
    final names = VariableParser.extractVariables(command);
    final newControllers = <String, TextEditingController>{};
    final newDescControllers = <String, TextEditingController>{};
    for (final name in names) {
      if (_variableControllers.containsKey(name)) {
        newControllers[name] = _variableControllers[name]!;
      } else {
        final match = existingVariables?.firstWhere(
          (v) => v.name == name,
          orElse: () => SnippetVariable(name: name),
        );
        final defaultVal = match?.defaultValue ?? '';
        newControllers[name] = TextEditingController(text: defaultVal);
      }
      if (_variableDescControllers.containsKey(name)) {
        newDescControllers[name] = _variableDescControllers[name]!;
      } else {
        final match = existingVariables?.firstWhere(
          (v) => v.name == name,
          orElse: () => SnippetVariable(name: name),
        );
        final desc = match?.description ?? '';
        newDescControllers[name] = TextEditingController(text: desc);
      }
    }
    // Dispose controllers for removed variables
    for (final entry in _variableControllers.entries) {
      if (!newControllers.containsKey(entry.key)) {
        entry.value.dispose();
      }
    }
    for (final entry in _variableDescControllers.entries) {
      if (!newDescControllers.containsKey(entry.key)) {
        entry.value.dispose();
      }
    }
    _variableControllers
      ..clear()
      ..addAll(newControllers);
    _variableDescControllers
      ..clear()
      ..addAll(newDescControllers);
    _detectedVariables = names;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(snippetsNotifierProvider.notifier);
    final tags = _tagsController.text.isEmpty
        ? <String>[]
        : _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final group = _groupController.text.trim().isEmpty ? null : _groupController.text.trim();
    final variables = _detectedVariables.map((name) {
      final def = _variableControllers[name]?.text.trim();
      final desc = _variableDescControllers[name]?.text.trim();
      return SnippetVariable(
        name: name,
        defaultValue: def?.isEmpty == true ? null : def,
        description: desc?.isEmpty == true ? null : desc,
      );
    }).toList();

    if (_isEditMode && _existingSnippet != null) {
      final updated = _existingSnippet!.copyWith(
        name: _nameController.text.trim(),
        command: _commandController.text.trim(),
        variables: variables,
        group: () => group,
        tags: tags,
      );
      await notifier.updateSnippet(updated);
    } else {
      final newSnippet = SnippetEntity(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        command: _commandController.text.trim(),
        variables: variables,
        group: group,
        tags: tags,
      );
      await notifier.addSnippet(newSnippet);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.snippetForm_deleteTitle),
        content: Text(l.snippetForm_deleteConfirm(_nameController.text)),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: Text(l.common_cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => ctx.pop(true),
            child: Text(l.common_delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(snippetsNotifierProvider.notifier).deleteSnippet(widget.snippetId!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadSnippet(),
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? l.snippetForm_editTitle : l.snippetForm_addTitle),
            actions: [
              if (_isEditMode)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  tooltip: l.snippetForm_deleteTooltip,
                  onPressed: _delete,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FormSection(title: l.snippetForm_sectionBasic, children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: l.snippetForm_nameLabel, hintText: l.snippetForm_nameHint),
                    validator: (v) => v == null || v.trim().isEmpty ? l.snippetForm_nameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commandController,
                    decoration: InputDecoration(
                      labelText: l.snippetForm_commandLabel,
                      hintText: 'kubectl apply -f \${FILE}',
                      alignLabelWithHint: true,
                    ),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    maxLines: 5,
                    minLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty ? l.snippetForm_commandRequired : null,
                    onChanged: (value) {
                      setState(() => _updateVariables(value));
                    },
                  ),
                ]),
                if (_detectedVariables.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _FormSection(title: l.snippetForm_sectionVariables, children: [
                    Text(
                      l.snippetForm_variablesHint,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ..._detectedVariables.map((name) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _variableControllers[name],
                            decoration: InputDecoration(
                              labelText: name,
                              hintText: l.snippetForm_defaultValueHint,
                              prefixText: '\${$name} = ',
                              prefixStyle: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _variableDescControllers[name],
                            decoration: InputDecoration(
                              labelText: l.snippetForm_variableDescLabel(name),
                              hintText: l.snippetForm_variableDescHint,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                  ]),
                ],
                const SizedBox(height: 20),
                _FormSection(title: l.snippetForm_sectionGroup, children: [
                  TextFormField(
                    controller: _groupController,
                    decoration: InputDecoration(labelText: l.snippetForm_groupLabel, hintText: l.snippetForm_groupHint),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(labelText: l.snippetForm_tagsLabel, hintText: l.snippetForm_tagsHint),
                  ),
                ]),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.common_save),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}
