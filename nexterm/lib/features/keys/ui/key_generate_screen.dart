import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';

class KeyGenerateScreen extends ConsumerStatefulWidget {
  const KeyGenerateScreen({super.key});

  @override
  ConsumerState<KeyGenerateScreen> createState() => _KeyGenerateScreenState();
}

class _KeyGenerateScreenState extends ConsumerState<KeyGenerateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passphraseController = TextEditingController();

  KeyType _selectedType = KeyType.ed25519;
  bool _isGenerating = false;
  bool _obscurePassphrase = true;

  static const _supportedTypes = [
    KeyType.ed25519,
    KeyType.rsa2048,
    KeyType.rsa4096,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isGenerating = true);

    final notifier = ref.read(keysNotifierProvider.notifier);
    final passphrase = _passphraseController.text.trim();
    final entity = await notifier.generateKey(
      name: _nameController.text.trim(),
      type: _selectedType,
      passphrase: passphrase.isEmpty ? null : passphrase,
    );

    if (!mounted) return;
    setState(() => _isGenerating = false);

    if (entity != null) {
      await _showPublicKeyDialog(entity);
      if (mounted) context.pop();
    } else {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.keyGenerate_failed)),
      );
    }
  }

  Future<void> _showPublicKeyDialog(SSHKeyEntity entity) async {
    final l = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.keyGenerate_doneTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.keyGenerate_doneMessage(entity.name),
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
              l.keyGenerate_fingerprint(entity.fingerprint),
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
                  SnackBar(content: Text(l.keyGenerate_publicKeyCopied), duration: const Duration(seconds: 2)),
                );
              }
            },
            child: Text(l.keyGenerate_copyPublicKey),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.keyGenerate_done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecorativeBackground(
      showRidge: false,
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.keyGenerate_title),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormSection(
              title: l.keyGenerate_sectionName,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l.keyGenerate_nameLabel,
                    hintText: l.keyGenerate_nameHint,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? l.keyGenerate_nameRequired : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FormSection(
              title: l.keyGenerate_sectionPassphrase,
              children: [
                TextFormField(
                  controller: _passphraseController,
                  obscureText: _obscurePassphrase,
                  decoration: InputDecoration(
                    labelText: l.keyGenerate_passphraseLabel,
                    hintText: l.keyGenerate_passphraseHint,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassphrase ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassphrase = !_obscurePassphrase),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FormSection(
              title: l.keyGenerate_sectionType,
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
                                  color: OutdoorColors.accentDim,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l.keyGenerate_recommended,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: OutdoorColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          switch (type) {
                            KeyType.ed25519 => l.keyGenerate_ed25519Desc,
                            KeyType.rsa2048 => l.keyGenerate_rsa2048Desc,
                            KeyType.rsa4096 => l.keyGenerate_rsa4096Desc,
                            _ => '',
                          },
                          style: theme.textTheme.bodySmall?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary),
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
                      l.keyGenerate_rsaWarning,
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
              label: Text(_isGenerating ? l.keyGenerate_generating : l.keyGenerate_button),
            ),
            const SizedBox(height: 80),
          ],
        ),
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
            color: OutdoorColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}
