import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class VaultsScreen extends StatelessWidget {
  const VaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 44,
        titleTextStyle: Theme.of(context).textTheme.titleMedium,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.vaults_title),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l.vaults_hosts),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text(l.vaults_hosts),
            onTap: () => context.push('/vaults/hosts'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz_outlined),
            title: Text(l.vaults_portForwarding),
            onTap: () => context.push('/vaults/forwarding'),
          ),
          ListTile(
            leading: const Icon(Icons.bolt_outlined),
            title: Text(l.vaults_snippets),
            onTap: () => context.push('/vaults/snippets'),
          ),

          _SectionHeader(title: l.vaults_keychain),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: Text(l.vaults_keychain),
            onTap: () => context.push('/vaults/keys'),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
