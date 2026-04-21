import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/utils/file_icon.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:path/path.dart' as p;

class FileEditorScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String filePath;

  const FileEditorScreen({
    super.key,
    required this.sessionId,
    required this.filePath,
  });

  @override
  ConsumerState<FileEditorScreen> createState() => _FileEditorScreenState();
}

class _FileEditorScreenState extends ConsumerState<FileEditorScreen> {
  SftpService? _sftpService;

  // Editor state
  late final TextEditingController _textController;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  bool _isModified = false;
  bool _isPreviewMode = false;

  // Cursor / line tracking
  int _lineNumber = 1;
  int _columnNumber = 1;

  String get _fileName => p.basename(widget.filePath);
  String get _language => detectLanguage(_fileName);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _loadFile();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _sftpService?.disconnect();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // File I/O
  // ---------------------------------------------------------------------------

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final sshService = ref.read(sshServiceProvider);
      final client = sshService.getClient(widget.sessionId);
      if (client == null) {
        throw StateError('No active SSH session for id: ${widget.sessionId}');
      }

      final sftpService = SftpService();
      await sftpService.connect(client);
      _sftpService = sftpService;

      final bytes = await sftpService.readFile(widget.filePath);
      final content = utf8.decode(bytes, allowMalformed: true);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isModified = false;
        });
        _textController.text = content;
        // Reset modified flag after setting initial content.
        setState(() => _isModified = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  Future<void> _saveFile() async {
    final sftpService = _sftpService;
    if (sftpService == null) return;

    setState(() => _isSaving = true);

    try {
      final bytes = utf8.encode(_textController.text);
      await sftpService.writeFile(widget.filePath, bytes);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isModified = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.fileEditor_fileSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.fileEditor_saveFailed(e.toString()))),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Listeners
  // ---------------------------------------------------------------------------

  void _onTextChanged() {
    // Update line/column from cursor position.
    final selection = _textController.selection;
    if (selection.isValid && selection.isCollapsed) {
      final text = _textController.text;
      final cursorOffset = selection.baseOffset.clamp(0, text.length);
      final before = text.substring(0, cursorOffset);
      final lines = before.split('\n');
      final line = lines.length;
      final col = lines.last.length + 1;
      setState(() {
        _lineNumber = line;
        _columnNumber = col;
        _isModified = true;
      });
    } else {
      setState(() => _isModified = true);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = _isModified ? '$_fileName •' : _fileName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'monospace')),
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit_outlined : Icons.preview),
            tooltip: _isPreviewMode ? l.fileEditor_editMode : l.fileEditor_previewMode,
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
          ),
          if (!_isPreviewMode)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              tooltip: l.fileEditor_save,
              onPressed: _isSaving ? null : _saveFile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildError()
              : Column(
                  children: [
                    Expanded(child: _buildEditor()),
                    _buildStatusBar(),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.fileEditor_loadFailed(_loadError!)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadFile,
            child: Text(AppLocalizations.of(context)!.common_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    if (_isPreviewMode) {
      return _buildPreview();
    }
    return _buildEditView();
  }

  Widget _buildEditView() {
    return TextField(
      controller: _textController,
      maxLines: null,
      expands: true,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
      ),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(12),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildPreview() {
    final code = _textController.text;
    final lang = _language.isNotEmpty ? _language : 'plaintext';

    return SingleChildScrollView(
      child: HighlightView(
        code,
        language: lang,
        theme: monokaiSublimeTheme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final langLabel = _language.isNotEmpty ? _language : 'plain text';
    return Container(
      height: 28,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            'Ln $_lineNumber, Col $_columnNumber',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 16),
          Text(
            langLabel,
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 16),
          const Text(
            'UTF-8',
            style: TextStyle(fontSize: 11),
          ),
          const Spacer(),
          if (_isModified)
            Text(
              AppLocalizations.of(context)!.fileEditor_modified,
              style: const TextStyle(fontSize: 11, color: Colors.orange),
            ),
        ],
      ),
    );
  }
}
