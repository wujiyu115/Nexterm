import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class VaultsScreen extends StatelessWidget {
  const VaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.vaults_title),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
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
          ListTile(
            leading: const Icon(Icons.wifi_tethering_outlined),
            title: Text(l.vaults_knownHosts),
            onTap: () => context.push('/vaults/known-hosts'),
          ),

          _SectionHeader(title: l.vaults_logs),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(l.vaults_logs),
            onTap: () => context.push('/vaults/logs'),
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
