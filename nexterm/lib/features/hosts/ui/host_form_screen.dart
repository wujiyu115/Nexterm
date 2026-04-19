import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';

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
      );
      await notifier.addHost(newHost);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除主机'),
        content: Text('确定要删除「${_nameController.text}」吗？'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => ctx.pop(true),
            child: const Text('删除'),
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
    // Exclude the current host (if editing) and already selected jump hosts
    final selectable = availableHosts.where((h) {
      if (h.id == widget.hostId) return false;
      if (_jumpHosts.contains(h.id)) return false;
      return true;
    }).toList();

    if (selectable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有可用的跳板机')),
      );
      return;
    }

    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择跳板机'),
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
        ],
      ),
    );

    if (chosen != null && mounted) {
      setState(() => _jumpHosts.add(chosen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostsAsync = ref.watch(hostsStreamProvider);
    final allHosts = hostsAsync.valueOrNull ?? [];

    return FutureBuilder(
      future: _loadHost(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? '编辑主机' : '添加主机'),
            actions: [
              if (_isEditMode)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  tooltip: '删除主机',
                  onPressed: _delete,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FormSection(title: '基本信息', children: [
                  _buildField(
                    controller: _nameController,
                    label: '名称',
                    hint: '我的服务器',
                    validator: (v) => v == null || v.trim().isEmpty ? '请输入名称' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _hostnameController,
                    label: '主机名 / IP',
                    hint: '192.168.1.1 或 example.com',
                    validator: (v) => v == null || v.trim().isEmpty ? '请输入主机地址' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      flex: 3,
                      child: _buildField(
                        controller: _usernameController,
                        label: '用户名',
                        hint: 'root',
                        validator: (v) => v == null || v.trim().isEmpty ? '请输入用户名' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _portController,
                        label: '端口',
                        hint: '22',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final port = int.tryParse(v ?? '');
                          if (port == null || port < 1 || port > 65535) return '无效端口';
                          return null;
                        },
                      ),
                    ),
                  ]),
                ]),
                const SizedBox(height: 20),
                _FormSection(title: '认证方式', children: [
                  SegmentedButton<AuthMethod>(
                    segments: AuthMethod.values
                        .map((m) => ButtonSegment<AuthMethod>(value: m, label: Text(m.displayName)))
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
                _FormSection(title: '分组与标签', children: [
                  _buildField(
                    controller: _groupController,
                    label: '分组',
                    hint: '生产环境（可选）',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _tagsController,
                    label: '标签',
                    hint: 'web, prod, nginx（逗号分隔）',
                  ),
                ]),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('保存'),
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
    final keysAsync = ref.watch(keysStreamProvider);
    return keysAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('加载密钥失败: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      data: (keys) {
        if (keys.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '尚未添加任何 SSH 密钥，请先在"密钥"页面创建或导入密钥。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        // Ensure selected key still exists; clear if not.
        if (_selectedKeyId != null && !keys.any((k) => k.id == _selectedKeyId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedKeyId = null);
          });
        }
        return DropdownButtonFormField<String>(
          initialValue: _selectedKeyId,
          decoration: const InputDecoration(labelText: '选择密钥'),
          hint: const Text('请选择 SSH 密钥'),
          items: keys.map((SSHKeyEntity key) {
            return DropdownMenuItem<String>(
              value: key.id,
              child: Text('${key.name} (${key.type.displayName})'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedKeyId = value),
          validator: (v) => (_authMethod == AuthMethod.key && (v == null || v.isEmpty))
              ? '请选择一个 SSH 密钥'
              : null,
        );
      },
    );
  }

  Widget _buildJumpHostsSection(List<HostEntity> allHosts) {
    return _FormSection(title: '跳板机', children: [
      if (_jumpHosts.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '未配置跳板机',
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
        label: const Text('添加跳板机'),
      ),
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
    return StatefulBuilder(
      builder: (context, localSetState) {
        var obscure = true;
        return StatefulBuilder(
          builder: (context, innerSetState) => TextFormField(
            controller: _passwordController,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: '密码',
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
