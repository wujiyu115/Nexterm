import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/sftp/services/sftp_service.dart';
import 'package:nexterm/features/sftp/ui/utils/file_icon.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:path/path.dart' as p;

class FileEditorScreen extends ConsumerStatefulWidget {
  final String? sessionId;
  final String filePath;
  final bool viewOnly;
  final RemoteFileService? service;

  const FileEditorScreen({
    super.key,
    this.sessionId,
    required this.filePath,
    this.viewOnly = false,
    this.service,
  });

  @override
  ConsumerState<FileEditorScreen> createState() => _FileEditorScreenState();
}

class _FileEditorScreenState extends ConsumerState<FileEditorScreen> {
  RemoteFileService? _fileService;
  bool _ownsService = false;

  // Editor state
  late final TextEditingController _textController;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  bool _isModified = false;
  late bool _isPreviewMode;

  // Cursor / line tracking
  int _lineNumber = 1;
  int _columnNumber = 1;
  bool _showMarkdownSource = false;
  final _markdownScrollController = ScrollController();

  String get _fileName => p.basename(widget.filePath);
  String get _language => detectLanguage(_fileName);
  bool get _isMarkdown => const {'md', 'mdx', 'markdown'}
      .contains(p.extension(_fileName).toLowerCase().replaceFirst('.', ''));

  @override
  void initState() {
    super.initState();
    _isPreviewMode = widget.viewOnly;
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _loadFile();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _markdownScrollController.dispose();
    if (_ownsService) _fileService?.disconnect();
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
      final RemoteFileService fileService;
      if (widget.service != null) {
        fileService = widget.service!;
        _ownsService = false;
      } else {
        final sshService = ref.read(sshServiceProvider);
        final client = sshService.getClient(widget.sessionId!);
        if (client == null) {
          throw StateError('No active SSH session for id: ${widget.sessionId}');
        }

        final sftpService = SftpService();
        await sftpService.connect(client);
        fileService = sftpService;
        _ownsService = true;
      }
      _fileService = fileService;

      final bytes = await fileService.readFile(widget.filePath);
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
    final fileService = _fileService;
    if (fileService == null) return;

    setState(() => _isSaving = true);

    try {
      final bytes = utf8.encode(_textController.text);
      await fileService.writeFile(widget.filePath, bytes);
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
          if (_isMarkdown && _isPreviewMode && !_showMarkdownSource)
            IconButton(
              icon: const Icon(Icons.toc),
              tooltip: l.fileEditor_toc,
              onPressed: _showToc,
            ),
          if (_isMarkdown && _isPreviewMode)
            IconButton(
              icon: Icon(_showMarkdownSource ? Icons.article_outlined : Icons.code),
              tooltip: _showMarkdownSource ? l.fileEditor_renderMarkdown : l.fileEditor_markdownSource,
              onPressed: () => setState(() => _showMarkdownSource = !_showMarkdownSource),
            ),
          if (!widget.viewOnly)
            IconButton(
              icon: Icon(_isPreviewMode ? Icons.edit_outlined : Icons.preview),
              tooltip: _isPreviewMode ? l.fileEditor_editMode : l.fileEditor_previewMode,
              onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
            ),
          if (!_isPreviewMode && !widget.viewOnly)
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
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkStatusError : OutdoorColors.lightStatusError),
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

  List<({int level, String title, int charOffset})> _parseHeadings(String text) {
    final headings = <({int level, String title, int charOffset})>[];
    final lines = text.split('\n');
    int offset = 0;
    for (final line in lines) {
      final match = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (match != null) {
        headings.add((level: match.group(1)!.length, title: match.group(2)!.trim(), charOffset: offset));
      }
      offset += line.length + 1;
    }
    return headings;
  }

  void _showToc() {
    final code = _textController.text;
    final headings = _parseHeadings(code);
    if (headings.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: headings.length,
          itemBuilder: (_, index) {
            final h = headings[index];
            return ListTile(
              contentPadding: EdgeInsets.only(left: 16.0 + (h.level - 1) * 16.0, right: 16),
              dense: true,
              title: Text(
                h.title,
                style: TextStyle(
                  fontSize: h.level <= 2 ? 15 : 13,
                  fontWeight: h.level <= 2 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _scrollToHeading(h.charOffset, code.length);
              },
            );
          },
        ),
      ),
    );
  }

  void _scrollToHeading(int charOffset, int totalChars) {
    if (!_markdownScrollController.hasClients) return;
    final maxScroll = _markdownScrollController.position.maxScrollExtent;
    final fraction = totalChars > 0 ? charOffset / totalChars : 0.0;
    _markdownScrollController.animateTo(
      (fraction * maxScroll).clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPreview() {
    final code = _textController.text;

    if (_isMarkdown && !_showMarkdownSource) {
      return Markdown(
        data: code,
        selectable: true,
        controller: _markdownScrollController,
        padding: const EdgeInsets.all(12),
      );
    }

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
              style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? OutdoorColors.darkStatusConnecting : OutdoorColors.lightStatusConnecting),
            ),
        ],
      ),
    );
  }
}
