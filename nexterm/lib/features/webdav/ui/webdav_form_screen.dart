import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/webdav_connection_entity.dart';
import 'package:nexterm/features/webdav/providers/webdav_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class WebDavFormScreen extends ConsumerStatefulWidget {
  final String? connectionId;
  const WebDavFormScreen({super.key, this.connectionId});

  @override
  ConsumerState<WebDavFormScreen> createState() => _WebDavFormScreenState();
}

class _WebDavFormScreenState extends ConsumerState<WebDavFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (_loaded || widget.connectionId == null) return;
    _loaded = true;
    final dao = ref.read(webdavDaoProvider);
    final entity = await dao.getById(widget.connectionId!);
    if (entity != null) {
      _nameController.text = entity.name;
      _urlController.text = entity.url;
      _usernameController.text = entity.username ?? '';
      _passwordController.text = entity.password ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final entity = WebdavConnectionEntity(
      id: widget.connectionId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      password: _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim(),
    );
    final dao = ref.read(webdavDaoProvider);
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
        title: Text(isEdit ? l.webdav_editTitle : l.webdav_addTitle),
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
                  labelText: l.webdav_name, hintText: l.webdav_nameHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.webdav_nameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                  labelText: l.webdav_url, hintText: l.webdav_urlHint),
              keyboardType: TextInputType.url,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.webdav_urlRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: l.webdav_username),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: l.webdav_password),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
