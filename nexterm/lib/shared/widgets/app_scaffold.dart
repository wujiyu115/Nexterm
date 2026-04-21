import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dns_outlined), selectedIcon: const Icon(Icons.dns), label: l.nav_hosts),
          NavigationDestination(icon: const Icon(Icons.terminal_outlined), selectedIcon: const Icon(Icons.terminal), label: l.nav_terminal),
          NavigationDestination(icon: const Icon(Icons.vpn_key_outlined), selectedIcon: const Icon(Icons.vpn_key), label: l.nav_keys),
          NavigationDestination(icon: const Icon(Icons.bolt_outlined), selectedIcon: const Icon(Icons.bolt), label: l.nav_snippets),
          NavigationDestination(icon: const Icon(Icons.swap_horiz_outlined), selectedIcon: const Icon(Icons.swap_horiz), label: l.nav_forwarding),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l.nav_settings),
        ],
      ),
    );
  }
}
