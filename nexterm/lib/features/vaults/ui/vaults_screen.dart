import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class _VaultItem {
  final IconData icon;
  final String Function(AppLocalizations l) titleBuilder;
  final String route;

  const _VaultItem({
    required this.icon,
    required this.titleBuilder,
    required this.route,
  });
}

final _vaultItems = [
  _VaultItem(
    icon: Icons.dns_outlined,
    titleBuilder: (l) => l.vaults_hosts,
    route: '/vaults/hosts',
  ),
  _VaultItem(
    icon: Icons.swap_horiz_outlined,
    titleBuilder: (l) => l.vaults_portForwarding,
    route: '/vaults/forwarding',
  ),
  _VaultItem(
    icon: Icons.bolt_outlined,
    titleBuilder: (l) => l.vaults_snippets,
    route: '/vaults/snippets',
  ),
  _VaultItem(
    icon: Icons.vpn_key_outlined,
    titleBuilder: (l) => l.vaults_keychain,
    route: '/vaults/keys',
  ),
  _VaultItem(
    icon: Icons.wifi_tethering_outlined,
    titleBuilder: (l) => l.vaults_knownHosts,
    route: '/vaults/known-hosts',
  ),
  _VaultItem(
    icon: Icons.receipt_long_outlined,
    titleBuilder: (l) => l.vaults_logs,
    route: '/vaults/logs',
  ),
];

class VaultsScreen extends StatelessWidget {
  const VaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _vaultItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
        itemBuilder: (context, index) {
          final item = _vaultItems[index];
          return ListTile(
            leading: Icon(item.icon, color: theme.colorScheme.onSurfaceVariant),
            title: Text(item.titleBuilder(l)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(item.route),
          );
        },
      ),
    );
  }
}
