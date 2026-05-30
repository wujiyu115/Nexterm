import 'package:flutter/material.dart';
import 'package:nexterm/features/git/models/git_commit.dart';
import 'package:nexterm/features/git/providers/git_provider.dart';
import 'package:nexterm/features/git/ui/widgets/commit_detail_sheet.dart';
import 'package:nexterm/features/git/ui/widgets/commit_list.dart';

class BranchLogScreen extends StatefulWidget {
  final String branchName;
  final GitNotifier gitNotifier;
  const BranchLogScreen({super.key, required this.branchName, required this.gitNotifier});

  @override
  State<BranchLogScreen> createState() => _BranchLogScreenState();
}

class _BranchLogScreenState extends State<BranchLogScreen> {
  List<GitCommit>? _commits;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommits();
  }

  Future<void> _loadCommits() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final commits = await widget.gitNotifier.getBranchLog(widget.branchName);
      if (mounted) setState(() { _commits = commits; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _onCommitTap(GitCommit commit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommitDetailSheet(commit: commit, gitNotifier: widget.gitNotifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.branchName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : CommitList(commits: _commits ?? [], onCommitTap: _onCommitTap),
    );
  }
}
