import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final tabManager = ref.watch(tabManagerProvider);
    final hasActiveTerminal = navigationShell.currentIndex == 1 && tabManager.tabs.isNotEmpty;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: hasActiveTerminal
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
              },
              destinations: [
                NavigationDestination(icon: const Icon(Icons.lock_outlined), selectedIcon: const Icon(Icons.lock), label: l.nav_vaults),
                NavigationDestination(icon: const Icon(Icons.terminal_outlined), selectedIcon: const Icon(Icons.terminal), label: l.nav_terminal),
                NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l.nav_settings),
              ],
            ),
    );
  }
}
