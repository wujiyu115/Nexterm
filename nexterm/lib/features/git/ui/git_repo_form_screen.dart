import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/git_repo_entity.dart';
import 'package:nexterm/features/git/providers/git_repos_provider.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class GitRepoFormScreen extends ConsumerStatefulWidget {
  final String? repoId;
  const GitRepoFormScreen({super.key, this.repoId});

  @override
  ConsumerState<GitRepoFormScreen> createState() => _GitRepoFormScreenState();
}

class _GitRepoFormScreenState extends ConsumerState<GitRepoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _pathController = TextEditingController();
  String? _selectedHostId;

  @override
  void initState() {
    super.initState();
    if (widget.repoId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final repo = await ref.read(gitRepoRepositoryProvider).getById(widget.repoId!);
    if (repo != null && mounted) {
      setState(() {
        _labelController.text = repo.label ?? '';
        _pathController.text = repo.remotePath;
        _selectedHostId = repo.hostId;
      });
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHostId == null) return;
    final repo = GitRepoEntity(
      id: widget.repoId ?? const Uuid().v4(),
      hostId: _selectedHostId!,
      remotePath: _pathController.text.trim(),
      label: _labelController.text.trim().isEmpty
          ? null
          : _labelController.text.trim(),
    );
    final repository = ref.read(gitRepoRepositoryProvider);
    if (widget.repoId != null) {
      await repository.update(repo);
    } else {
      await repository.insert(repo);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.watch(hostsStreamProvider);
    final isEdit = widget.repoId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.git_editRepo : l.git_addRepo),
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
              controller: _labelController,
              decoration: InputDecoration(
                  labelText: l.git_repoLabel, hintText: l.git_repoLabelHint),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pathController,
              decoration: InputDecoration(
                  labelText: l.git_repoPath, hintText: l.git_repoPathHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            hostsAsync.when(
              data: (hosts) => DropdownButtonFormField<String>(
                value: _selectedHostId,
                decoration: InputDecoration(labelText: l.git_selectHost),
                items: hosts
                    .map((h) =>
                        DropdownMenuItem(value: h.id, child: Text(h.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedHostId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
