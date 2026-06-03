import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/terminal/providers/stt_provider.dart';
import 'package:nexterm/features/terminal/services/stt/stt_provider_interface.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/shared/widgets/section_label.dart';

class SttSettingsSection extends ConsumerStatefulWidget {
  const SttSettingsSection({super.key});

  @override
  ConsumerState<SttSettingsSection> createState() => _SttSettingsSectionState();
}

class _SttSettingsSectionState extends ConsumerState<SttSettingsSection> {
  bool _testing = false;

  String _providerLabel(SttProviderType type, AppLocalizations l) {
    return switch (type) {
      SttProviderType.system => l.settings_sttProviderSystem,
      SttProviderType.volcengine => l.settings_sttProviderVolcengine,
      SttProviderType.alibaba => l.settings_sttProviderAlibaba,
    };
  }

  void _showProviderPicker() {
    final l = AppLocalizations.of(context)!;
    final current = ref.read(sttProviderTypeProvider);
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settings_sttSelectProvider),
        children: SttProviderType.values.map((type) {
          return RadioListTile<SttProviderType>(
            title: Text(_providerLabel(type, l)),
            value: type,
            groupValue: current,
            onChanged: (v) {
              if (v != null) {
                ref.read(settingsNotifierProvider.notifier).set(SettingsKeys.sttProvider, v.name);
              }
              Navigator.of(ctx).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showCredentialEditor(String title, Future<String?> Function() getter, Future<void> Function(String) setter, {bool obscure = false}) {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    getter().then((v) => controller.text = v ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: obscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () async {
              await setter(controller.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.settings_sttCredentialsSaved)),
                );
                setState(() {});
              }
            },
            child: Text(l.common_save),
          ),
        ],
      ),
    );
  }

  Future<void> _testSpeed() async {
    setState(() => _testing = true);
    final l = AppLocalizations.of(context)!;
    try {
      final provider = ref.read(sttProviderInstanceProvider);
      final ms = await provider.testSpeed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.settings_sttSpeedTestResult(ms))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.settings_sttSpeedTestFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final type = ref.watch(sttProviderTypeProvider);
    final credentials = ref.watch(sttCredentialServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title: l.settings_sectionVoiceInput),
        ListTile(
          leading: const Icon(Icons.record_voice_over_outlined),
          title: Text(l.settings_sttProvider),
          subtitle: Text(_providerLabel(type, l)),
          onTap: _showProviderPicker,
        ),
        if (type == SttProviderType.volcengine) ...[
          _CredentialTile(
            title: l.settings_sttAppId,
            getter: () => credentials.volcAppId,
            setter: credentials.setVolcAppId,
            onTap: () => _showCredentialEditor(l.settings_sttAppId, () => credentials.volcAppId, credentials.setVolcAppId),
          ),
          _CredentialTile(
            title: l.settings_sttAccessToken,
            getter: () => credentials.volcAccessToken,
            setter: credentials.setVolcAccessToken,
            obscure: true,
            onTap: () => _showCredentialEditor(l.settings_sttAccessToken, () => credentials.volcAccessToken, credentials.setVolcAccessToken, obscure: true),
          ),
          _CredentialTile(
            title: l.settings_sttResourceId,
            getter: () => credentials.volcResourceId,
            setter: credentials.setVolcResourceId,
            onTap: () => _showCredentialEditor(l.settings_sttResourceId, () => credentials.volcResourceId, credentials.setVolcResourceId),
          ),
        ],
        if (type == SttProviderType.alibaba) ...[
          _CredentialTile(
            title: l.settings_sttAccessKeyId,
            getter: () => credentials.aliAccessKeyId,
            setter: credentials.setAliAccessKeyId,
            onTap: () => _showCredentialEditor(l.settings_sttAccessKeyId, () => credentials.aliAccessKeyId, credentials.setAliAccessKeyId),
          ),
          _CredentialTile(
            title: l.settings_sttAccessKeySecret,
            getter: () => credentials.aliAccessKeySecret,
            setter: credentials.setAliAccessKeySecret,
            obscure: true,
            onTap: () => _showCredentialEditor(l.settings_sttAccessKeySecret, () => credentials.aliAccessKeySecret, credentials.setAliAccessKeySecret, obscure: true),
          ),
          _CredentialTile(
            title: l.settings_sttAppKey,
            getter: () => credentials.aliAppKey,
            setter: credentials.setAliAppKey,
            onTap: () => _showCredentialEditor(l.settings_sttAppKey, () => credentials.aliAppKey, credentials.setAliAppKey),
          ),
        ],
        if (type != SttProviderType.system)
          ListTile(
            leading: _testing
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.speed_outlined),
            title: Text(l.settings_sttSpeedTest),
            onTap: _testing ? null : _testSpeed,
          ),
      ],
    );
  }
}

class _CredentialTile extends StatefulWidget {
  final String title;
  final Future<String?> Function() getter;
  final Future<void> Function(String) setter;
  final bool obscure;
  final VoidCallback onTap;

  const _CredentialTile({
    required this.title,
    required this.getter,
    required this.setter,
    this.obscure = false,
    required this.onTap,
  });

  @override
  State<_CredentialTile> createState() => _CredentialTileState();
}

class _CredentialTileState extends State<_CredentialTile> {
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final v = await widget.getter();
    if (mounted) setState(() => _hasValue = v != null && v.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    return ListTile(
      leading: Icon(
        _hasValue ? Icons.check_circle_outline : Icons.circle_outlined,
        color: _hasValue ? p.statusOnline : p.fgTertiary,
        size: 20,
      ),
      title: Text(widget.title),
      subtitle: Text(_hasValue ? l.settings_sttConfigured : l.settings_sttNotConfigured),
      onTap: () {
        widget.onTap();
        Future.delayed(const Duration(milliseconds: 500), _check);
      },
    );
  }
}
