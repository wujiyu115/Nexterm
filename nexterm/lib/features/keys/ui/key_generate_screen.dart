import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';

class KeyGenerateScreen extends ConsumerStatefulWidget {
  const KeyGenerateScreen({super.key});

  @override
  ConsumerState<KeyGenerateScreen> createState() => _KeyGenerateScreenState();
}

class _KeyGenerateScreenState extends ConsumerState<KeyGenerateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  KeyType _selectedType = KeyType.ed25519;
  bool _isGenerating = false;

  // Supported types for generation (Ed25519 and RSA)
  static const _supportedTypes = [
    KeyType.ed25519,
    KeyType.rsa2048,
    KeyType.rsa4096,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isGenerating = true);

    final notifier = ref.read(keysNotifierProvider.notifier);
    final entity = await notifier.generateKey(
      name: _nameController.text.trim(),
      type: _selectedType,
    );

    if (!mounted) return;
    setState(() => _isGenerating = false);

    if (entity != null) {
      await _showPublicKeyDialog(entity);
      if (mounted) context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密钥生成失败，请重试')),
      );
    }
  }

  Future<void> _showPublicKeyDialog(SSHKeyEntity entity) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('密钥已生成'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '「${entity.name}」已成功生成。将以下公钥添加到服务器的 ~/.ssh/authorized_keys 文件中：',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                entity.publicKey,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '指纹: ${entity.fingerprint}',
              style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: entity.publicKey));
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('公钥已复制'), duration: Duration(seconds: 2)),
                );
              }
            },
            child: const Text('复制公钥'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('生成密钥')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormSection(
              title: '密钥名称',
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    hintText: '我的 SSH 密钥',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? '请输入密钥名称' : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FormSection(
              title: '密钥类型',
              children: [
                RadioGroup<KeyType>(
                  groupValue: _selectedType,
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                  child: Column(
                    children: _supportedTypes.map((type) {
                      final isRecommended = type == KeyType.ed25519;
                      return RadioListTile<KeyType>(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Text(type.displayName),
                            if (isRecommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '推荐',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          switch (type) {
                            KeyType.ed25519 => '更快、更安全的现代算法',
                            KeyType.rsa2048 => '兼容性好，适合旧系统',
                            KeyType.rsa4096 => '更高安全级别，生成较慢',
                            _ => '',
                          },
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        value: type,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.tertiaryContainer),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: colorScheme.tertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'RSA 密钥生成需要较长时间，请耐心等待。',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isGenerating ? null : _generate,
              icon: _isGenerating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.generating_tokens),
              label: Text(_isGenerating ? '生成中…' : '生成密钥'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
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
