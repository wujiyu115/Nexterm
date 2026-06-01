import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/smb_connection_entity.dart';
import 'package:nexterm/features/smb/providers/smb_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class SmbFormScreen extends ConsumerStatefulWidget {
  final String? connectionId;
  const SmbFormScreen({super.key, this.connectionId});

  @override
  ConsumerState<SmbFormScreen> createState() => _SmbFormScreenState();
}

class _SmbFormScreenState extends ConsumerState<SmbFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '445');
  final _shareNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _domainController = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _shareNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (_loaded || widget.connectionId == null) return;
    _loaded = true;
    final dao = ref.read(smbDaoProvider);
    final entity = await dao.getById(widget.connectionId!);
    if (entity != null) {
      _nameController.text = entity.name;
      _hostController.text = entity.host;
      _portController.text = entity.port.toString();
      _shareNameController.text = entity.shareName;
      _usernameController.text = entity.username ?? '';
      _passwordController.text = entity.password ?? '';
      _domainController.text = entity.domain ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final entity = SmbConnectionEntity(
      id: widget.connectionId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 445,
      shareName: _shareNameController.text.trim(),
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      password: _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim(),
      domain: _domainController.text.trim().isEmpty
          ? null
          : _domainController.text.trim(),
    );
    final dao = ref.read(smbDaoProvider);
    if (widget.connectionId != null) {
      await dao.updateConnection(entity);
    } else {
      await dao.insertConnection(entity);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.connectionId != null;

    if (isEdit && !_loaded) {
      _loadExisting();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.smb_editTitle : l.smb_addTitle),
        actions: [
          TextButton(onPressed: _save, child: Text(l.common_save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: l.smb_name, hintText: l.smb_nameHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.smb_nameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hostController,
              decoration: InputDecoration(
                  labelText: l.smb_host, hintText: l.smb_hostHint),
              keyboardType: TextInputType.url,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.smb_hostRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _portController,
              decoration: InputDecoration(labelText: l.smb_port),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shareNameController,
              decoration: InputDecoration(
                  labelText: l.smb_shareName, hintText: l.smb_shareNameHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.smb_shareNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: l.smb_username),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: l.smb_password),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _domainController,
              decoration: InputDecoration(
                  labelText: l.smb_domain, hintText: l.smb_domainHint),
            ),
          ],
        ),
      ),
    );
  }
}
