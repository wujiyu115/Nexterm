import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/features/forwarding/providers/forwarding_provider.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';

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
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.forwardForm_deleteTitle),
        content: Text(l.forwardForm_deleteConfirm(_nameController.text)),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(l.common_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => ctx.pop(true),
            child: Text(l.common_delete),
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
        final l = AppLocalizations.of(context)!;
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
            title: Text(_isEditMode ? l.forwardForm_editTitle : l.forwardForm_addTitle),
            actions: [
              if (_isEditMode)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  tooltip: l.forwardForm_deleteTooltip,
                  onPressed: _delete,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FormSection(title: l.forwardForm_sectionBasic, children: [
                  _buildTextField(
                    controller: _nameController,
                    label: l.forwardForm_nameLabel,
                    hint: l.forwardForm_nameHint,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l.forwardForm_nameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  _buildHostDropdown(),
                ]),
                const SizedBox(height: 20),
                _FormSection(
                  title: l.forwardForm_sectionType,
                  trailing: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showForwardTypeHelp(context),
                  ),
                  children: [
                  SegmentedButton<ForwardType>(
                    segments: ForwardType.values
                        .map((t) => ButtonSegment<ForwardType>(
                              value: t,
                              label: Text(t.shortLabel),
                              tooltip: t.localizedName(l),
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
                    _forwardType.localizedName(l),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary,
                        ),
                  ),
                ]),
                const SizedBox(height: 20),
                _FormSection(title: l.forwardForm_sectionPorts, children: [
                  _buildTextField(
                    controller: _localPortController,
                    label: l.forwardForm_localPort,
                    hint: '8080',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final p = int.tryParse(v ?? '');
                      if (p == null || p < 1 || p > 65535) return l.forwardForm_portInvalid;
                      return null;
                    },
                  ),
                  if (_forwardType != ForwardType.dynamic) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _remoteHostController,
                      label: l.forwardForm_remoteHost,
                      hint: 'db.internal',
                      validator: (v) {
                        if (_forwardType == ForwardType.dynamic) return null;
                        if (v == null || v.trim().isEmpty) return l.forwardForm_remoteHostRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _remotePortController,
                      label: l.forwardForm_remotePort,
                      hint: '5432',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (_forwardType == ForwardType.dynamic) return null;
                        final p = int.tryParse(v ?? '');
                        if (p == null || p < 1 || p > 65535) return l.forwardForm_portInvalid;
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _bindAddressController,
                    label: l.forwardForm_bindAddress,
                    hint: '127.0.0.1',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l.forwardForm_bindAddressRequired : null,
                  ),
                ]),
                const SizedBox(height: 20),
                _FormSection(title: l.forwardForm_sectionOptions, children: [
                  SwitchListTile(
                    title: Text(l.forwardForm_autoStart),
                    subtitle: Text(l.forwardForm_autoStartHint),
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
                      : Text(l.common_save),
                ),
                const SizedBox(height: 80),
              ],
            ),
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

  void _showForwardTypeHelp(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.forwardForm_typeHelpTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                title: l.forwarding_local,
                description: l.forwardForm_typeHelpLocal,
              ),
              const SizedBox(height: 16),
              _HelpItem(
                title: l.forwarding_remote,
                description: l.forwardForm_typeHelpRemote,
              ),
              const SizedBox(height: 16),
              _HelpItem(
                title: l.forwarding_dynamic,
                description: l.forwardForm_typeHelpDynamic,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildHostDropdown() {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.watch(hostsStreamProvider);
    return hostsAsync.when(
      data: (hosts) {
        if (hosts.isEmpty) {
          return Text(l.forwardForm_noHosts);
        }
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
          decoration: InputDecoration(labelText: l.forwardForm_hostLabel),
          items: hosts
              .map((h) => DropdownMenuItem<String>(
                    value: h.id,
                    child: Text('${h.name} (${h.hostname})'),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedHostId = v),
          validator: (v) => v == null || v.isEmpty ? l.forwardForm_hostRequired : null,
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(l.forwardForm_hostLoadError(e.toString())),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String title;
  final String description;
  const _HelpItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const _FormSection({required this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: OutdoorColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}
