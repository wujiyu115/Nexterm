import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_tag.dart';
import 'package:nexterm/features/git/providers/git_provider.dart';
import 'package:nexterm/features/git/services/git_command_service.dart';
import 'package:nexterm/features/git/ui/widgets/branch_graph_screen.dart';
import 'package:nexterm/features/git/ui/widgets/branch_list.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final sshService = ref.read(sshServiceProvider);
      final client = sshService.getClient(widget.sessionId);
      if (client == null) throw StateError('No active SSH session');
      final service = GitCommandService(client: client, repoPath: widget.remotePath);
      final notifier = GitNotifier(service);
      notifier.addListener(() { if (mounted) setState(() => _gitState = notifier.state); });
      setState(() { _gitNotifier = notifier; _isInitializing = false; });
      await notifier.loadAll();
    } catch (e) {
      if (mounted) setState(() { _initError = e.toString(); _isInitializing = false; });
    }
  }

  @override
  void dispose() { _tabController.dispose(); _gitNotifier?.dispose(); super.dispose(); }

  void _showFileDiff(entry, bool staged) async {
    final diffs = await _gitNotifier!.getFileDiff(entry.path, staged: staged);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(appBar: AppBar(title: Text(entry.path.split('/').last)), body: DiffView(diffs: diffs))));
  }

  void _openBranchGraph() async {
    await _gitNotifier!.loadGraph();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BranchGraphScreen(rows: _gitNotifier!.state.graphRows)));
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
    if (!_gitState.isRepo) return Scaffold(appBar: AppBar(title: const Text('Git')), body: GitInitPrompt(onInit: () => _gitNotifier!.initRepo()));
    return _buildMain(context);
  }

  Widget _buildMain(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Git', style: TextStyle(fontSize: 17)),
          Text(_gitState.currentBranch, style: TextStyle(fontSize: 12, color: isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary)),
        ]),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _gitNotifier!.loadAll())],
        bottom: TabBar(controller: _tabController, tabs: [Tab(text: l.git_tabWorkTree), Tab(text: l.git_tabBranches), Tab(text: l.git_tabTags)]),
      ),
      body: _gitState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabController, children: [
              _gitState.status != null ? StatusFileList(status: _gitState.status!, onFileTap: _showFileDiff) : const SizedBox.shrink(),
              BranchList(branches: _gitState.branches, onBranchGraphTap: _openBranchGraph, onDeleteBranch: (branch) => _gitNotifier!.deleteBranch(branch.name)),
              TagList(tags: _gitState.tags, onDeleteTag: (tag) => _gitNotifier!.deleteTag(tag.name), onCheckoutTag: _handleCheckoutTag),
            ]),
    );
  }
}
