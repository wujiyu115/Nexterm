import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';
import 'package:nexterm/shared/widgets/section_label.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final tabManager = ref.watch(tabManagerProvider);
    final tabs = tabManager.tabs;
    final hostsAsync = ref.watch(hostsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _NavTitle(title: l.sessions_title),
            ),

            if (tabs.isNotEmpty) ...[
              SectionLabel(title: l.sessions_activeConnections),
              ...tabs.map((tab) => _ActiveSessionCard(tab: tab)),
            ],

            hostsAsync.when(
              data: (hosts) {
                final recent = hosts
                    .where((h) => h.lastConnected != null)
                    .toList()
                  ..sort((a, b) => b.lastConnected!.compareTo(a.lastConnected!));

                if (recent.isEmpty && tabs.isEmpty) {
                  return _EmptyState(isDark: isDark);
                }
                if (recent.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(title: l.sessions_recentConnections),
                    ...recent.map((host) => _HostCard(host: host)),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(e.toString()),
              ),
            ),

            const SizedBox(height: 100),
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

class _ActiveSessionCard extends ConsumerWidget {
  final TerminalTab tab;
  const _ActiveSessionCard({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hostAsync = ref.watch(hostByIdProvider(tab.hostId));
    final host = hostAsync.valueOrNull;

    final statusColor = switch (tab.status) {
      ConnectionStatus.connected => OutdoorColors.accent,
      ConnectionStatus.connecting => const Color(0xFFF9E2AF),
      ConnectionStatus.disconnected => isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
      ConnectionStatus.error => const Color(0xFFF38BA8),
    };

    final typeLabel = tab.connectionType == ConnectionType.sftp ? 'sftp' : 'ssh';
    final subtitle = host != null
        ? '$typeLabel · ${host.username} · ${host.hostname}:${host.port}'
        : tab.title;

    return GlassCard(
      onTap: () {
        final tabManager = ref.read(tabManagerProvider);
        final index = tabManager.tabs.indexWhere((t) => t.id == tab.id);
        if (index >= 0) tabManager.setActiveTab(index);
        context.push('/terminal/session/${tab.id}');
      },
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: tab.status == ConnectionStatus.connected
                  ? [BoxShadow(color: OutdoorColors.accentGlow, blurRadius: 6)]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tab.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
            ),
            onPressed: () => ref.read(terminalActionsProvider).disconnectTab(tab.id),
          ),
        ],
      ),
    );
  }
}

class _HostCard extends ConsumerWidget {
  final HostEntity host;
  const _HostCard({required this.host});

  Future<void> _connectSftp(BuildContext context, WidgetRef ref) async {
    final sessionId = await ref.read(terminalActionsProvider).connectHost(host.id, connectionType: ConnectionType.sftp);
    if (!context.mounted) return;
    if (sessionId != null) {
      context.push('/sftp/$sessionId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSftp = host.lastConnectionType == ConnectionType.sftp;
    final typeLabel = isSftp ? 'sftp' : 'ssh';

    return GlassCard(
      onTap: () {
        if (isSftp) {
          _connectSftp(context, ref);
        } else {
          context.push('/terminal/connect/${host.id}');
        }
      },
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OutdoorColors.accentDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isSftp ? Icons.folder_outlined : Icons.dns_outlined, size: 18, color: OutdoorColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$typeLabel · ${host.username}@${host.hostname}:${host.port}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fgSecondary = isDark ? OutdoorColors.darkFgSecondary : OutdoorColors.lightFgSecondary;
    final fgTertiary = isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.link_off, size: 56, color: fgTertiary),
            const SizedBox(height: 16),
            Text(l.sessions_noActive, style: TextStyle(fontSize: 16, color: fgSecondary)),
            const SizedBox(height: 8),
            Text(l.sessions_noActiveHint, style: TextStyle(fontSize: 13, color: fgTertiary)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/vaults/hosts/add'),
              icon: const Icon(Icons.add),
              label: Text(l.hosts_add),
            ),
          ],
        ),
      ),
    );
  }
}
