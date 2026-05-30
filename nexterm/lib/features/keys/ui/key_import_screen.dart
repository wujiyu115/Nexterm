import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';

class KeyImportScreen extends ConsumerStatefulWidget {
  const KeyImportScreen({super.key});

  @override
  ConsumerState<KeyImportScreen> createState() => _KeyImportScreenState();
}

class _KeyImportScreenState extends ConsumerState<KeyImportScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passphraseController = TextEditingController();
  final _pemController = TextEditingController();

  late final TabController _tabController;
  bool _isImporting = false;
  bool _obscurePassphrase = true;

  String? _selectedFileName;
  String? _selectedFileContent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passphraseController.dispose();
    _pemController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      final content = String.fromCharCodes(file.bytes!);
      setState(() {
        _selectedFileName = file.name;
        _selectedFileContent = content;
      });
    }
  }

  String? _getPemContent() {
    if (_tabController.index == 0) {
      return _selectedFileContent;
    } else {
      final text = _pemController.text.trim();
      return text.isEmpty ? null : text;
    }
  }

  Future<void> _import() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final pemContent = _getPemContent();
    if (pemContent == null || pemContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tabController.index == 0 ? l.keyImport_noFileSelected : l.keyImport_noContent,
          ),
        ),
      );
      return;
    }

    setState(() => _isImporting = true);

    final notifier = ref.read(keysNotifierProvider.notifier);
    final passphrase = _passphraseController.text.trim();

    try {
      final entity = await notifier.importKey(
        name: _nameController.text.trim(),
        privateKeyPem: pemContent,
        passphrase: passphrase.isEmpty ? null : passphrase,
      );

      if (!mounted) return;
      setState(() => _isImporting = false);

      if (entity != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.keyImport_success(entity.name)),
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.keyImport_formatError)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.keyImport_failed(e.toString()))),
      );
    }
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
        title: Text(l.keyImport_title),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormSection(
              title: l.keyImport_sectionName,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l.keyImport_nameLabel,
                    hintText: l.keyImport_nameHint,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l.keyImport_nameRequired : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FormSection(
              title: l.keyImport_sectionMethod,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: OutdoorColors.accentDim,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: OutdoorColors.accent,
                    unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.file_open_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(l.keyImport_fromFile),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.paste_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(l.keyImport_pasteKey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: _tabController.index == 0
                      ? _buildFileImportTab(context)
                      : _buildPasteImportTab(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FormSection(
              title: l.keyImport_sectionPassphrase,
              children: [
                TextFormField(
                  controller: _passphraseController,
                  obscureText: _obscurePassphrase,
                  decoration: InputDecoration(
                    labelText: l.keyImport_passphraseLabel,
                    hintText: l.keyImport_passphraseHint,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassphrase
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscurePassphrase = !_obscurePassphrase),
                    ),
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
                  Icon(Icons.info_outline,
                      size: 18, color: colorScheme.tertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.keyImport_formatHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isImporting ? null : _import,
              icon: _isImporting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download),
              label: Text(_isImporting ? l.keyImport_importing : l.keyImport_button),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFileImportTab(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.folder_open),
          label: Text(l.keyImport_selectFile),
        ),
        if (_selectedFileName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_drive_file,
                    size: 20, color: OutdoorColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFileName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  onPressed: () => setState(() {
                    _selectedFileName = null;
                    _selectedFileContent = null;
                  }),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasteImportTab(BuildContext context) {
    return TextFormField(
      controller: _pemController,
      maxLines: 8,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
          ),
      decoration: const InputDecoration(
        hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
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
