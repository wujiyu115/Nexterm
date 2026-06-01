import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/domain/entities/webdav_connection_entity.dart';
import 'package:nexterm/features/webdav/providers/webdav_provider.dart';
import 'package:nexterm/features/webdav/services/webdav_service.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class WebDavConnectionsScreen extends ConsumerWidget {
  const WebDavConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final connectionsAsync = ref.watch(webdavConnectionsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.webdav_title), actions: [
        IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/vaults/webdav/add')),
      ]),
      body: connectionsAsync.when(
        data: (connections) {
          if (connections.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.webdav_noConnections,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l.webdav_noConnectionsHint,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: connections.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _ConnectionTile(connection: connections[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _ConnectionTile extends ConsumerWidget {
  final WebdavConnectionEntity connection;
  const _ConnectionTile({required this.connection});

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    try {
      final service = WebDavService();
      service.connect(connection.url,
          username: connection.username, password: connection.password);

      // Update last connected time
      final dao = ref.read(webdavDaoProvider);
      await dao.updateConnection(
          connection.copyWith(lastConnected: DateTime.now()));

      if (context.mounted) {
        context.push('/webdav/browse',
            extra: {'service': service, 'name': connection.name});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.webdav_connectFailed(e.toString()))));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.webdav_deleteTitle),
        content: Text(l.webdav_deleteConfirm(connection.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.common_cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.common_delete)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(webdavDaoProvider).deleteConnection(connection.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleParts = <String>[connection.url];
    if (connection.lastConnected != null) {
      final dt = connection.lastConnected!;
      subtitleParts.add(
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}');
    }
    return Dismissible(
      key: ValueKey(connection.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _delete(context, ref);
        return false; // deletion handled in _delete
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Icon(Icons.cloud_outlined,
            size: 24,
            color: isDark
                ? OutdoorColors.darkFgSecondary
                : OutdoorColors.lightFgSecondary),
        title: Text(connection.displayName),
        subtitle: Text(subtitleParts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? OutdoorColors.darkFgTertiary
                    : OutdoorColors.lightFgTertiary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () =>
                  context.push('/vaults/webdav/edit/${connection.id}'),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
        onTap: () => _connect(context, ref),
      ),
    );
  }
}
