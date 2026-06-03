import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/shared/widgets/dashed_divider.dart';
import 'package:nexterm/features/git/models/git_tag.dart';
import 'package:nexterm/features/git/providers/git_provider.dart';
import 'package:nexterm/features/git/services/git_command_service.dart';
import 'package:nexterm/features/git/ui/widgets/branch_graph_screen.dart';
import 'package:nexterm/features/git/models/git_branch.dart';
import 'package:nexterm/features/git/ui/widgets/branch_list.dart';
import 'package:nexterm/features/git/ui/widgets/branch_log_screen.dart';
import 'package:nexterm/features/git/ui/widgets/diff_view.dart';
import 'package:nexterm/features/git/ui/widgets/git_init_prompt.dart';
import 'package:nexterm/features/git/ui/widgets/status_file_list.dart';
import 'package:nexterm/features/git/ui/widgets/tag_list.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class GitScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String remotePath;
  const GitScreen({super.key, required this.sessionId, required this.remotePath});
  @override
  ConsumerState<GitScreen> createState() => _GitScreenState();
}

class _GitScreenState extends ConsumerState<GitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GitNotifier? _gitNotifier;
  GitState _gitState = const GitState();
  bool _isInitializing = true;
  String? _initError;
  late String _currentPath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentPath = widget.remotePath;
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final sshService = ref.read(sshServiceProvider);
      final client = sshService.getClient(widget.sessionId);
      if (client == null) throw StateError('No active SSH session');
      final service = GitCommandService(client: client, repoPath: _currentPath);
      final notifier = GitNotifier(service);
      notifier.addListener(() { if (mounted) setState(() => _gitState = notifier.state); });
      setState(() { _gitNotifier = notifier; _isInitializing = false; });
      await notifier.loadAll();
    } catch (e) {
      if (mounted) setState(() { _initError = e.toString(); _isInitializing = false; });
    }
  }

  void _changePath(String newPath) {
    _gitNotifier?.dispose();
    setState(() {
      _currentPath = newPath;
      _gitNotifier = null;
      _gitState = const GitState();
      _isInitializing = true;
      _initError = null;
    });
    _initialize();
  }

  void _showChangePathDialog() {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _currentPath);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.git_changePath),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 14),
          decoration: InputDecoration(
            hintText: '/home/user/project',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onSubmitted: (v) {
            final path = v.trim();
            if (path.isNotEmpty) {
              Navigator.of(ctx).pop();
              _changePath(path);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                Navigator.of(ctx).pop();
                _changePath(path);
              }
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { _tabController.dispose(); _gitNotifier?.dispose(); super.dispose(); }

  void _showFileDiff(entry, bool staged) async {
    final diffs = await _gitNotifier!.getFileDiff(entry.path, staged: staged);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(appBar: AppBar(title: Text(entry.path.split('/').last)), body: DiffView(diffs: diffs))));
  }

  void _openBranchLog(GitBranch branch) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BranchLogScreen(branchName: branch.name, gitNotifier: _gitNotifier!)));
  }

  void _openBranchGraph() async {
    await _gitNotifier!.loadGraph();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BranchGraphScreen(rows: _gitNotifier!.state.graphRows, gitNotifier: _gitNotifier!)));
  }

  Future<void> _handleCheckoutTag(GitTag tag) async {
    final l = AppLocalizations.of(context)!;
    final status = _gitState.status;
    if (status != null && status.isDirty) {
      final result = await showCupertinoDialog<String>(context: context, builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.git_checkoutDirtyTitle), content: Text(l.git_checkoutDirtyMessage),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop('cancel'), child: Text(l.common_cancel)),
          CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop('stash'), child: Text(l.git_stashAndCheckout)),
        ],
      ));
      if (result == 'stash') await _gitNotifier!.stashAndCheckoutTag(tag.name);
    } else {
      await _gitNotifier!.checkoutTag(tag.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_initError != null) return Scaffold(appBar: AppBar(title: const Text('Git')), body: Center(child: Text(_initError!)));
    if (_gitState.isLoading && !_gitState.isRepo) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_gitState.isRepo) return Scaffold(
      appBar: AppBar(title: const Text('Git')),
      body: GitInitPrompt(
        onInit: () => _gitNotifier!.initRepo(),
        errorDetail: _gitState.error,
        remotePath: _currentPath,
        onChangePath: _changePath,
      ),
    );
    return _buildMain(context);
  }

  Widget _buildMain(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Git', style: theme.textTheme.headlineSmall!.copyWith(fontSize: 17)),
          Text(_gitState.currentBranch, style: theme.textTheme.bodySmall!.copyWith(color: p.fgSecondary)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open, size: 20), onPressed: _showChangePathDialog),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _gitNotifier!.loadAll()),
        ],
        bottom: TabBar(controller: _tabController, dividerColor: Colors.transparent, tabs: [Tab(text: l.git_tabWorkTree), Tab(text: l.git_tabBranches), Tab(text: l.git_tabTags)]),
      ),
      body: Column(
        children: [
          DashedDivider(color: p.border.withValues(alpha: 0.4), padding: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: _gitState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _gitState.error != null
                    ? Center(child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.error_outline, size: 48, color: p.statusError),
                          const SizedBox(height: 12),
                          Text(_gitState.error!, textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium!.copyWith(fontFamily: AppFonts.mono,
                                  color: p.fgSecondary)),
                          const SizedBox(height: 16),
                          FilledButton(onPressed: () => _gitNotifier!.loadAll(), child: Text(l.common_retry)),
                        ]),
                      ))
                    : TabBarView(controller: _tabController, children: [
                        _gitState.status != null ? StatusFileList(status: _gitState.status!, onFileTap: _showFileDiff) : const Center(child: CircularProgressIndicator()),
                        BranchList(
                          branches: _gitState.branches,
                          onBranchGraphTap: _openBranchGraph,
                          onDeleteBranch: (branch) => _gitNotifier!.deleteBranch(branch.name),
                          onBranchTap: _openBranchLog,
                        ),
                        TagList(tags: _gitState.tags, onDeleteTag: (tag) => _gitNotifier!.deleteTag(tag.name), onCheckoutTag: _handleCheckoutTag),
                      ]),
          ),
        ],
      ),
    );
  }
}
