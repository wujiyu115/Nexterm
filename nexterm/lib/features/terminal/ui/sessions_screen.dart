import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/webdav_connection_entity.dart';
import 'package:nexterm/domain/entities/smb_connection_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/webdav/providers/webdav_provider.dart';
import 'package:nexterm/features/webdav/services/webdav_service.dart';
import 'package:nexterm/features/smb/providers/smb_provider.dart';
import 'package:nexterm/features/smb/services/smb_service.dart';
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

            _RecentConnectionsList(tabs: tabs, isDark: isDark),

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

  String _subtitle(WidgetRef ref) {
    switch (tab.connectionType) {
      case ConnectionType.ssh:
      case ConnectionType.sftp:
        final host = ref.watch(hostByIdProvider(tab.hostId)).valueOrNull;
        final typeLabel = tab.connectionType == ConnectionType.sftp ? 'sftp' : 'ssh';
        return host != null
            ? '$typeLabel · ${host.username} · ${host.hostname}:${host.port}'
            : tab.title;
      case ConnectionType.webdav:
        final conn = ref.watch(webdavConnectionByIdProvider(tab.hostId)).valueOrNull;
        return conn != null ? 'webdav · ${conn.url}' : tab.title;
      case ConnectionType.smb:
        final conn = ref.watch(smbConnectionByIdProvider(tab.hostId)).valueOrNull;
        return conn != null ? 'smb · \\\\${conn.host}\\${conn.shareName}' : tab.title;
    }
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    switch (tab.connectionType) {
      case ConnectionType.ssh:
      case ConnectionType.sftp:
        final tabManager = ref.read(tabManagerProvider);
        final index = tabManager.tabs.indexWhere((t) => t.id == tab.id);
        if (index >= 0) tabManager.setActiveTab(index);
        context.push('/terminal/session/${tab.id}');
      case ConnectionType.webdav:
      case ConnectionType.smb:
        final service = ref.read(fileServicesProvider)[tab.id];
        if (service == null) return;
        final route = tab.connectionType == ConnectionType.webdav
            ? '/webdav/browse'
            : '/smb/browse';
        context.push(route, extra: {'service': service, 'name': tab.title});
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColor = switch (tab.status) {
      ConnectionStatus.connected => OutdoorColors.accent,
      ConnectionStatus.connecting => const Color(0xFFF9E2AF),
      ConnectionStatus.disconnected => isDark ? OutdoorColors.darkFgTertiary : OutdoorColors.lightFgTertiary,
      ConnectionStatus.error => const Color(0xFFF38BA8),
    };

    final subtitle = _subtitle(ref);

    return GlassCard(
      onTap: () => _onTap(context, ref),
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

class _RecentItem {
  final String name;
  final String subtitle;
  final IconData icon;
  final ConnectionType type;
  final DateTime lastConnected;
  final dynamic source;

  const _RecentItem({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.lastConnected,
    required this.source,
  });
}

class _RecentConnectionsList extends ConsumerWidget {
  final List<TerminalTab> tabs;
  final bool isDark;
  const _RecentConnectionsList({required this.tabs, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final hostsAsync = ref.watch(hostsStreamProvider);
    final webdavAsync = ref.watch(webdavConnectionsStreamProvider);
    final smbAsync = ref.watch(smbConnectionsStreamProvider);

    final hosts = hostsAsync.valueOrNull ?? [];
    final webdavConns = webdavAsync.valueOrNull ?? [];
    final smbConns = smbAsync.valueOrNull ?? [];

    final items = <_RecentItem>[];

    for (final h in hosts) {
      if (h.lastConnected == null) continue;
      final isSftp = h.lastConnectionType == ConnectionType.sftp;
      items.add(_RecentItem(
        name: h.name,
        subtitle: '${isSftp ? "sftp" : "ssh"} · ${h.username}@${h.hostname}:${h.port}',
        icon: isSftp ? Icons.folder_outlined : Icons.dns_outlined,
        type: h.lastConnectionType ?? ConnectionType.ssh,
        lastConnected: h.lastConnected!,
        source: h,
      ));
    }

    for (final w in webdavConns) {
      if (w.lastConnected == null) continue;
      items.add(_RecentItem(
        name: w.name,
        subtitle: 'webdav · ${w.url}',
        icon: Icons.cloud_outlined,
        type: ConnectionType.webdav,
        lastConnected: w.lastConnected!,
        source: w,
      ));
    }

    for (final s in smbConns) {
      if (s.lastConnected == null) continue;
      items.add(_RecentItem(
        name: s.name,
        subtitle: 'smb · \\\\${s.host}\\${s.shareName}',
        icon: Icons.folder_shared_outlined,
        type: ConnectionType.smb,
        lastConnected: s.lastConnected!,
        source: s,
      ));
    }

    items.sort((a, b) => b.lastConnected.compareTo(a.lastConnected));

    if (items.isEmpty && tabs.isEmpty) {
      return _EmptyState(isDark: isDark);
    }
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title: l.sessions_recentConnections),
        ...items.map((item) => _RecentCard(item: item)),
      ],
    );
  }
}

class _RecentCard extends ConsumerWidget {
  final _RecentItem item;
  const _RecentCard({required this.item});

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    switch (item.type) {
      case ConnectionType.ssh:
        final host = item.source as HostEntity;
        context.push('/terminal/connect/${host.id}');
      case ConnectionType.sftp:
        final host = item.source as HostEntity;
        final sessionId = await ref.read(terminalActionsProvider).connectHost(host.id, connectionType: ConnectionType.sftp);
        if (!context.mounted || sessionId == null) return;
        context.push('/sftp/$sessionId');
      case ConnectionType.webdav:
        final conn = item.source as WebdavConnectionEntity;
        try {
          final service = WebDavService();
          service.connect(conn.url, username: conn.username, password: conn.password);
          if (!context.mounted) return;
          ref.read(terminalActionsProvider).connectFileService(
            connectionId: conn.id,
            name: conn.name,
            connectionType: ConnectionType.webdav,
            service: service,
          );
          context.push('/webdav/browse', extra: {'service': service, 'name': conn.name});
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
      case ConnectionType.smb:
        final conn = item.source as SmbConnectionEntity;
        try {
          final service = SmbService();
          await service.connect(conn.host, conn.shareName, port: conn.port, username: conn.username, password: conn.password, domain: conn.domain);
          if (!context.mounted) return;
          ref.read(terminalActionsProvider).connectFileService(
            connectionId: conn.id,
            name: conn.name,
            connectionType: ConnectionType.smb,
            service: service,
          );
          context.push('/smb/browse', extra: {'service': service, 'name': conn.name});
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: () => _connect(context, ref),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OutdoorColors.accentDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: OutdoorColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? OutdoorColors.darkFg : OutdoorColors.lightFg,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
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
