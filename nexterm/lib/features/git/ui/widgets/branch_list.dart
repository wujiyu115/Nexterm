import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/features/git/models/git_branch.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class BranchList extends StatelessWidget {
  final List<GitBranch> branches;
  final VoidCallback onBranchGraphTap;
  final Future<void> Function(GitBranch branch) onDeleteBranch;
  const BranchList({super.key, required this.branches, required this.onBranchGraphTap, required this.onDeleteBranch});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (branches.isEmpty) return Center(child: Text(l.git_noBranches));
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: SizedBox(width: double.infinity,
        child: OutlinedButton.icon(onPressed: onBranchGraphTap, icon: const Icon(Icons.account_tree_outlined, size: 18), label: Text(l.git_branchGraph)))),
      Expanded(child: ListView.separated(
        itemCount: branches.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final branch = branches[index];
          final canDelete = !branch.isCurrent && !branch.isDefault && !branch.isRemote;
          return Dismissible(
            key: Key(branch.name),
            direction: canDelete ? DismissDirection.endToStart : DismissDirection.none,
            confirmDismiss: (_) async {
              if (!canDelete) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.git_deleteBranchProtected))); return false; }
              return true;
            },
            onDismissed: (_) => onDeleteBranch(branch),
            background: Container(color: const Color(0xFFE06C75), alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
            child: ListTile(
              dense: true, visualDensity: VisualDensity.compact,
              leading: Icon(branch.isRemote ? Icons.cloud_outlined : Icons.call_split, size: 18,
                  color: branch.isCurrent ? OutdoorColors.accent : (isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary)),
              title: Text(branch.name, style: TextStyle(fontSize: 14, fontWeight: branch.isCurrent ? FontWeight.w600 : FontWeight.normal,
                  color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (branch.isCurrent) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: OutdoorColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text(l.git_currentBranch, style: TextStyle(fontSize: 10, color: OutdoorColors.accent))),
                const SizedBox(width: 4),
                Text(branch.shortSha, style: TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono', color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary)),
              ]),
            ),
          );
        },
      )),
    ]);
  }
}
