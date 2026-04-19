import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/features/forwarding/providers/forwarding_provider.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';

class ForwardFormScreen extends ConsumerStatefulWidget {
  final String? forwardId;
  const ForwardFormScreen({super.key, this.forwardId});

  @override
  ConsumerState<ForwardFormScreen> createState() => _ForwardFormScreenState();
}

class _ForwardFormScreenState extends ConsumerState<ForwardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _localPortController = TextEditingController();
  final _remoteHostController = TextEditingController();
  final _remotePortController = TextEditingController();
  final _bindAddressController = TextEditingController(text: '127.0.0.1');

  ForwardType _forwardType = ForwardType.local;
  String? _selectedHostId;
  bool _autoStart = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  PortForwardEntity? _existing;

  bool get _isEditMode => widget.forwardId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _localPortController.dispose();
    _remoteHostController.dispose();
    _remotePortController.dispose();
    _bindAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadForward() async {
    if (_isInitialized || !_isEditMode) {
      _isInitialized = true;
      return;
    }
    _isInitialized = true;
    final forward =
        await ref.read(portForwardRepositoryProvider).getById(widget.forwardId!);
    if (forward != null && mounted) {
      setState(() {
        _existing = forward;
        _nameController.text = forward.name;
        _localPortController.text = forward.localPort.toString();
        _remoteHostController.text = forward.remoteHost ?? '';
        _remotePortController.text = forward.remotePort?.toString() ?? '';
        _bindAddressController.text = forward.bindAddress;
        _forwardType = forward.type;
        _selectedHostId = forward.hostId;
        _autoStart = forward.autoStart;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(forwardingNotifierProvider.notifier);

    final remoteHost = _forwardType != ForwardType.dynamic &&
            _remoteHostController.text.trim().isNotEmpty
        ? _remoteHostController.text.trim()
        : null;
    final remotePort = _forwardType != ForwardType.dynamic &&
            _remotePortController.text.trim().isNotEmpty
        ? int.tryParse(_remotePortController.text)
        : null;

    if (_isEditMode && _existing != null) {
      final updated = _existing!.copyWith(
        name: _nameController.text.trim(),
        type: _forwardType,
        hostId: _selectedHostId!,
        localPort: int.parse(_localPortController.text),
        remoteHost: () => remoteHost,
        remotePort: () => remotePort,
        bindAddress: _bindAddressController.text.trim(),
        autoStart: _autoStart,
      );
      await notifier.updateForward(updated);
    } else {
      final newForward = PortForwardEntity(
        id: '',
        name: _nameController.text.trim(),
        type: _forwardType,
        hostId: _selectedHostId!,
        localPort: int.parse(_localPortController.text),
        remoteHost: remoteHost,
        remotePort: remotePort,
        bindAddress: _bindAddressController.text.trim(),
        autoStart: _autoStart,
      );
      await notifier.addForward(newForward);
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
        title: const Text('删除转发'),
        content: Text('确定要删除「${_nameController.text}」吗？'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => ctx.pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(forwardingNotifierProvider.notifier)
          .deleteForward(widget.forwardId!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadForward(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditMode ? '编辑转发' : '添加转发'),
            actions: [
              if (_isEditMode)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  tooltip: '删除转发',
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
                  _buildTextField(
                    controller: _nameController,
                    label: '名称',
                    hint: '数据库隧道',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '请输入名称' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildHostDropdown(),
                ]),
                const SizedBox(height: 20),
                _FormSection(title: '转发类型', children: [
                  SegmentedButton<ForwardType>(
                    segments: ForwardType.values
                        .map((t) => ButtonSegment<ForwardType>(
                              value: t,
                              label: Text(t.shortLabel),
                              tooltip: t.displayName,
                            ))
                        .toList(),
                    selected: {_forwardType},
                    onSelectionChanged: (s) =>
                        setState(() => _forwardType = s.first),
                    style: const ButtonStyle(
                        visualDensity: VisualDensity.compact),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _forwardType.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ]),
                const SizedBox(height: 20),
                _FormSection(title: '端口配置', children: [
                  _buildTextField(
                    controller: _localPortController,
                    label: '本地端口',
                    hint: '8080',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final p = int.tryParse(v ?? '');
                      if (p == null || p < 1 || p > 65535) return '请输入有效端口 (1-65535)';
                      return null;
                    },
                  ),
                  if (_forwardType != ForwardType.dynamic) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _remoteHostController,
                      label: '远程主机',
                      hint: 'db.internal',
                      validator: (v) {
                        if (_forwardType == ForwardType.dynamic) return null;
                        if (v == null || v.trim().isEmpty) return '请输入远程主机';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _remotePortController,
                      label: '远程端口',
                      hint: '5432',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (_forwardType == ForwardType.dynamic) return null;
                        final p = int.tryParse(v ?? '');
                        if (p == null || p < 1 || p > 65535) return '请输入有效端口 (1-65535)';
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _bindAddressController,
                    label: '绑定地址',
                    hint: '127.0.0.1',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '请输入绑定地址' : null,
                  ),
                ]),
                const SizedBox(height: 20),
                _FormSection(title: '选项', children: [
                  SwitchListTile(
                    title: const Text('自动启动'),
                    subtitle: const Text('连接到主机时自动开启此转发'),
                    value: _autoStart,
                    onChanged: (v) => setState(() => _autoStart = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ]),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
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

  Widget _buildTextField({
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

  Widget _buildHostDropdown() {
    final hostsAsync = ref.watch(hostsStreamProvider);
    return hostsAsync.when(
      data: (hosts) {
        if (hosts.isEmpty) {
          return const Text('暂无可用主机，请先添加主机');
        }
        // Ensure selected host still exists; clear if not.
        final effectiveHostId =
            (_selectedHostId != null && hosts.any((h) => h.id == _selectedHostId))
                ? _selectedHostId
                : null;
        if (effectiveHostId != _selectedHostId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedHostId = null);
          });
        }
        return DropdownButtonFormField<String>(
          value: effectiveHostId,
          decoration: const InputDecoration(labelText: '主机'),
          items: hosts
              .map((h) => DropdownMenuItem<String>(
                    value: h.id,
                    child: Text('${h.name} (${h.hostname})'),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedHostId = v),
          validator: (v) => v == null || v.isEmpty ? '请选择主机' : null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('加载主机失败: $e'),
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
