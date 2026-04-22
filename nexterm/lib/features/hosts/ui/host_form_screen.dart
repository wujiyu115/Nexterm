import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/features/snippets/providers/snippets_provider.dart';

enum _StartupMode { command, snippet }

class HostFormScreen extends ConsumerStatefulWidget {
  final String? hostId;
  const HostFormScreen({super.key, this.hostId});

  @override
  ConsumerState<HostFormScreen> createState() => _HostFormScreenState();
}

class _HostFormScreenState extends ConsumerState<HostFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _hostnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _passwordController = TextEditingController();
  final _groupController = TextEditingController();
  final _tagsController = TextEditingController();

  AuthMethod _authMethod = AuthMethod.password;
  String? _selectedKeyId;
  List<String> _jumpHosts = [];
  _StartupMode _startupMode = _StartupMode.command;
  final _startupCommandController = TextEditingController();
  String? _startupSnippetId;

  bool _isLoading = false;
  bool _isInitialized = false;
  HostEntity? _existingHost;

  bool get _isEditMode => widget.hostId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _hostnameController.dispose();
    _usernameController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    _groupController.dispose();
    _tagsController.dispose();
    _startupCommandController.dispose();
    super.dispose();
  }

  Future<void> _loadHost() async {
    if (_isInitialized || !_isEditMode) {
      _isInitialized = true;
      return;
    }
    _isInitialized = true;
    final host = await ref.read(hostRepositoryProvider).getById(widget.hostId!);
    if (host != null && mounted) {
      setState(() {
        _existingHost = host;
        _nameController.text = host.name;
        _hostnameController.text = host.hostname;
        _usernameController.text = host.username;
        _portController.text = host.port.toString();
        _passwordController.text = host.password ?? '';
        _groupController.text = host.group ?? '';
        _tagsController.text = host.tags.join(', ');
        _authMethod = host.authMethod;
        _selectedKeyId = host.keyId;
        _jumpHosts = List<String>.from(host.jumpHosts);
        if (host.startupSnippetId != null) {
          _startupMode = _StartupMode.snippet;
          _startupSnippetId = host.startupSnippetId;
        } else if (host.startupCommand != null) {
          _startupMode = _StartupMode.command;
          _startupCommandController.text = host.startupCommand!;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(hostsNotifierProvider.notifier);
    final tags = _tagsController.text.isEmpty
        ? <String>[]
        : _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final group = _groupController.text.trim().isEmpty ? null : _groupController.text.trim();
    final password = _authMethod == AuthMethod.password ? _passwordController.text : null;
    final keyId = _authMethod == AuthMethod.key ? _selectedKeyId : null;
    final startupSnippetId = _startupMode == _StartupMode.snippet ? _startupSnippetId : null;
    final startupCommand = _startupMode == _StartupMode.command && _startupCommandController.text.trim().isNotEmpty
        ? _startupCommandController.text.trim() : null;

    if (_isEditMode && _existingHost != null) {
      final updated = _existingHost!.copyWith(
        name: _nameController.text.trim(),
        hostname: _hostnameController.text.trim(),
        username: _usernameController.text.trim(),
        port: int.tryParse(_portController.text) ?? 22,
        authMethod: _authMethod,
        password: () => password,
        keyId: () => keyId,
        group: () => group,
        tags: tags,
        jumpHosts: _jumpHosts,
        startupSnippetId: () => startupSnippetId,
        startupCommand: () => startupCommand,
      );
      await notifier.updateHost(updated);
    } else {
      final newHost = HostEntity(
        id: '',
        name: _nameController.text.trim(),
        hostname: _hostnameController.text.trim(),
        username: _usernameController.text.trim(),
        port: int.tryParse(_portController.text) ?? 22,
        authMethod: _authMethod,
        password: password,
        keyId: keyId,
        group: group,
        tags: tags,
        jumpHosts: _jumpHosts,
        startupSnippetId: startupSnippetId,
        startupCommand: startupCommand,
      );
      await notifier.addHost(newHost);
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
        title: Text(l.hostForm_deleteTitle),
        content: Text(l.hostForm_deleteConfirm(_nameController.text)),
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
      await ref.read(hostsNotifierProvider.notifier).deleteHost(widget.hostId!);
      if (mounted) context.pop();
    }
  }

  Future<void> _addJumpHost(List<HostEntity> availableHosts) async {
    final l = AppLocalizations.of(context)!;
    final selectable = availableHosts.where((h) {
      if (h.id == widget.hostId) return false;
      if (_jumpHosts.contains(h.id)) return false;
      return true;
    }).toList();

    if (selectable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.hostForm_noJumpHosts)),
      );
      return;
    }

    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.hostForm_selectJumpHost),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: selectable.length,
            itemBuilder: (ctx, i) {
              final h = selectable[i];
              return ListTile(
                title: Text(h.name),
                subtitle: Text('${h.username}@${h.hostname}:${h.port}'),
                onTap: () => Navigator.of(ctx).pop(h.id),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
        ],
      ),
    );

    if (chosen != null && mounted) {
      setState(() => _jumpHosts.add(chosen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.watch(hostsStreamProvider);
    final allHosts = hostsAsync.valueOrNull ?? [];

    return FutureBuilder(
      future: _loadHost(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? l.hostForm_editTitle : l.hostForm_addTitle),
            actions: [
              if (_isEditMode)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  tooltip: l.hostForm_deleteTooltip,
                  onPressed: _delete,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FormSection(title: l.hostForm_sectionBasic, children: [
                  _buildField(
                    controller: _nameController,
                    label: l.hostForm_name,
                    hint: l.hostForm_nameHint,
                    validator: (v) => v == null || v.trim().isEmpty ? l.hostForm_nameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _hostnameController,
                    label: l.hostForm_host,
                    hint: l.hostForm_hostHint,
                    validator: (v) => v == null || v.trim().isEmpty ? l.hostForm_hostRequired : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      flex: 3,
                      child: _buildField(
                        controller: _usernameController,
                        label: l.hostForm_username,
                        hint: 'root',
                        validator: (v) => v == null || v.trim().isEmpty ? l.hostForm_usernameRequired : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _portController,
                        label: l.hostForm_port,
                        hint: '22',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final port = int.tryParse(v ?? '');
                          if (port == null || port < 1 || port > 65535) return l.hostForm_portInvalid;
                          return null;
                        },
                      ),
                    ),
                  ]),
                ]),
                const SizedBox(height: 20),
                _FormSection(title: l.hostForm_sectionAuth, children: [
                  SegmentedButton<AuthMethod>(
                    segments: AuthMethod.values
                        .map((m) => ButtonSegment<AuthMethod>(value: m, label: Text(m.localizedName(l))))
                        .toList(),
                    selected: {_authMethod},
                    onSelectionChanged: (s) => setState(() => _authMethod = s.first),
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  ),
                  if (_authMethod == AuthMethod.password) ...[
                    const SizedBox(height: 12),
                    _buildPasswordField(),
                  ],
                  if (_authMethod == AuthMethod.key) ...[
                    const SizedBox(height: 12),
                    _buildKeySelector(),
                  ],
                ]),
                const SizedBox(height: 20),
                _buildJumpHostsSection(allHosts),
                const SizedBox(height: 20),
                _buildStartupCommandSection(),
                const SizedBox(height: 20),
                _FormSection(title: l.hostForm_sectionGroup, children: [
                  _buildField(
                    controller: _groupController,
                    label: l.hostForm_group,
                    hint: l.hostForm_groupHint,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _tagsController,
                    label: l.hostForm_tags,
                    hint: l.hostForm_tagsHint,
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

  Widget _buildKeySelector() {
    final l = AppLocalizations.of(context)!;
    final keysAsync = ref.watch(keysStreamProvider);
    return keysAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(l.hostForm_keyLoadError(e.toString()), style: TextStyle(color: Theme.of(context).colorScheme.error)),
      data: (keys) {
        if (keys.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l.hostForm_noKeys,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final effectiveKeyId =
            (_selectedKeyId != null && keys.any((k) => k.id == _selectedKeyId))
                ? _selectedKeyId
                : null;
        if (effectiveKeyId != _selectedKeyId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedKeyId = null);
          });
        }
        return DropdownButtonFormField<String>(
          value: effectiveKeyId,
          decoration: InputDecoration(labelText: l.hostForm_selectKey),
          hint: Text(l.hostForm_selectKeyHint),
          items: keys.map((SSHKeyEntity key) {
            return DropdownMenuItem<String>(
              value: key.id,
              child: Text('${key.name} (${key.type.displayName})'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedKeyId = value),
          validator: (v) => (_authMethod == AuthMethod.key && (v == null || v.isEmpty))
              ? l.hostForm_selectKeyRequired
              : null,
        );
      },
    );
  }

  Widget _buildJumpHostsSection(List<HostEntity> allHosts) {
    final l = AppLocalizations.of(context)!;
    return _FormSection(title: l.hostForm_sectionJumpHost, children: [
      if (_jumpHosts.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            l.hostForm_noJumpHostConfigured,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _jumpHosts.map((hostId) {
            final host = allHosts.where((h) => h.id == hostId).firstOrNull;
            final label = host != null
                ? '${host.name} (${host.hostname})'
                : hostId;
            return Chip(
              label: Text(label, overflow: TextOverflow.ellipsis),
              onDeleted: () => setState(() => _jumpHosts.remove(hostId)),
              deleteIcon: const Icon(Icons.close, size: 16),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => _addJumpHost(allHosts),
        icon: const Icon(Icons.add, size: 18),
        label: Text(l.hostForm_addJumpHost),
      ),
    ]);
  }

  Widget _buildStartupCommandSection() {
    final l = AppLocalizations.of(context)!;
    final snippetsAsync = ref.watch(snippetsStreamProvider);

    return _FormSection(title: l.hostForm_sectionStartup, children: [
      SegmentedButton<_StartupMode>(
        segments: [
          ButtonSegment<_StartupMode>(
            value: _StartupMode.command,
            label: Text(l.hostForm_startupModeCommand),
            icon: const Icon(Icons.terminal, size: 18),
          ),
          ButtonSegment<_StartupMode>(
            value: _StartupMode.snippet,
            label: Text(l.hostForm_startupModeSnippet),
            icon: const Icon(Icons.code, size: 18),
          ),
        ],
        selected: {_startupMode},
        onSelectionChanged: (selection) {
          setState(() {
            final newMode = selection.first;
            if (newMode != _startupMode) {
              if (newMode == _StartupMode.command) {
                _startupSnippetId = null;
              } else {
                _startupCommandController.clear();
              }
              _startupMode = newMode;
            }
          });
        },
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
      if (_startupMode == _StartupMode.command) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: _startupCommandController,
          decoration: InputDecoration(
            labelText: l.hostForm_startupCommand,
            hintText: l.hostForm_startupCommandHint,
          ),
          maxLines: 3,
          minLines: 1,
        ),
      ],
      if (_startupMode == _StartupMode.snippet) ...[
        const SizedBox(height: 12),
        snippetsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text(e.toString(), style: TextStyle(color: Theme.of(context).colorScheme.error)),
          data: (snippets) {
            if (snippets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l.hostForm_noSnippets,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final effectiveSnippetId =
                (_startupSnippetId != null && snippets.any((s) => s.id == _startupSnippetId))
                    ? _startupSnippetId : null;
            if (effectiveSnippetId != _startupSnippetId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _startupSnippetId = null);
              });
            }
            return DropdownButtonFormField<String>(
              value: effectiveSnippetId,
              decoration: InputDecoration(
                labelText: l.hostForm_startupSnippet,
                hintText: l.hostForm_startupSnippetHint,
              ),
              items: snippets.map((SnippetEntity s) {
                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(
                    '${s.name}  (${s.command})',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _startupSnippetId = value),
            );
          },
        ),
      ],
    ]);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    final l = AppLocalizations.of(context)!;
    return StatefulBuilder(
      builder: (context, localSetState) {
        var obscure = true;
        return StatefulBuilder(
          builder: (context, innerSetState) => TextFormField(
            controller: _passwordController,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: l.hostForm_password,
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => innerSetState(() => obscure = !obscure),
              ),
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
