import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/git/models/git_branch.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class BranchList extends StatefulWidget {
  final List<GitBranch> branches;
  final VoidCallback onBranchGraphTap;
  final Future<void> Function(GitBranch branch) onDeleteBranch;
  final void Function(GitBranch branch) onBranchTap;
  const BranchList({super.key, required this.branches, required this.onBranchGraphTap, required this.onDeleteBranch, required this.onBranchTap});

  @override
  State<BranchList> createState() => _BranchListState();
}

class _BranchListState extends State<BranchList> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GitBranch> get _filtered {
    if (_query.isEmpty) return widget.branches;
    final lower = _query.toLowerCase();
    return widget.branches.where((b) => b.name.toLowerCase().contains(lower)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    if (widget.branches.isEmpty) return Center(child: Text(l.git_noBranches));
    final filtered = _filtered;
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: SizedBox(width: double.infinity,
        child: OutlinedButton.icon(onPressed: widget.onBranchGraphTap, icon: const Icon(Icons.account_tree_outlined, size: 18), label: Text(l.git_branchGraph)))),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: l.toolbar_groupSearch,
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() { _searchController.clear(); _query = ''; }),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          style: theme.textTheme.bodyLarge!,
        ),
      ),
      Expanded(child: filtered.isEmpty
        ? Center(child: Text(l.git_noBranches))
        : ListView.separated(
        itemCount: filtered.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final branch = filtered[index];
          final canDelete = !branch.isCurrent && !branch.isDefault && !branch.isRemote;
          return Dismissible(
            key: Key(branch.name),
            direction: canDelete ? DismissDirection.endToStart : DismissDirection.none,
            confirmDismiss: (_) async {
              if (!canDelete) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.git_deleteBranchProtected))); return false; }
              return true;
            },
            onDismissed: (_) => widget.onDeleteBranch(branch),
            background: Container(color: const Color(0xFFE06C75), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
            child: ListTile(
              dense: true, visualDensity: VisualDensity.compact,
              onTap: () => widget.onBranchTap(branch),
              leading: Icon(branch.isRemote ? Icons.cloud_outlined : Icons.call_split, size: 18,
                  color: branch.isCurrent ? p.accent : p.fgSecondary),
              title: Text(branch.name, style: (branch.isCurrent ? theme.textTheme.titleSmall! : theme.textTheme.bodyLarge!).copyWith(
                  color: p.fg)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (branch.isCurrent) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text(l.git_currentBranch, style: theme.textTheme.labelSmall!.copyWith(fontSize: 10, color: p.accent))),
                const SizedBox(width: 4),
                Text(branch.shortSha, style: theme.textTheme.bodySmall!.copyWith(fontFamily: AppFonts.mono, color: p.fgTertiary)),
              ]),
            ),
          );
        },
      )),
    ]);
  }
}
