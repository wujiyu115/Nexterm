import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';
import 'package:nexterm/shared/widgets/section_label.dart';

class VaultsScreen extends StatelessWidget {
  const VaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _NavTitle(title: l.vaults_title),
            ),

            SectionLabel(title: l.vaults_connections),
            GlassCard(
              onTap: () => context.push('/vaults/hosts'),
              child: _VaultItem(icon: Icons.dns_outlined, title: l.vaults_hosts),
            ),
            GlassCard(
              onTap: () => context.push('/vaults/webdav'),
              child: _VaultItem(icon: Icons.cloud_outlined, title: l.webdav_title),
            ),
            GlassCard(
              onTap: () => context.push('/vaults/smb'),
              child: _VaultItem(icon: Icons.folder_shared_outlined, title: l.smb_title),
            ),

            SectionLabel(title: l.vaults_tools),
            GlassCard(
              onTap: () => context.push('/vaults/forwarding'),
              child: _VaultItem(icon: Icons.swap_horiz_outlined, title: l.vaults_portForwarding),
            ),
            GlassCard(
              onTap: () => context.push('/vaults/snippets'),
              child: _VaultItem(icon: Icons.bolt_outlined, title: l.vaults_snippets),
            ),
            GlassCard(
              onTap: () => context.push('/vaults/git'),
              child: _VaultItem(icon: Icons.source_outlined, title: l.git_repos),
            ),

            SectionLabel(title: l.vaults_keychain),
            GlassCard(
              onTap: () => context.push('/vaults/keys'),
              child: _VaultItem(icon: Icons.vpn_key_outlined, title: l.vaults_keychain),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NavTitle extends StatelessWidget {
  final String title;
  const _NavTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: const LinearGradient(
              colors: [OutdoorColors.accent, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

class _VaultItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _VaultItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}
