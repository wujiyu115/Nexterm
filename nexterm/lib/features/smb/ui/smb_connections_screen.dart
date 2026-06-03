import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/smb_connection_entity.dart';
import 'package:nexterm/features/smb/providers/smb_provider.dart';
import 'package:nexterm/features/smb/services/smb_service.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class SmbConnectionsScreen extends ConsumerWidget {
  const SmbConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final connectionsAsync = ref.watch(smbConnectionsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.smb_title), actions: [
        IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/vaults/smb/add')),
      ]),
      body: connectionsAsync.when(
        data: (connections) {
          if (connections.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.smb_noConnections,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(l.smb_noConnectionsHint,
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
  final SmbConnectionEntity connection;
  const _ConnectionTile({required this.connection});

  Future<void> _connect(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    try {
      final service = SmbService();
      await service.connect(connection.host, connection.shareName,
          port: connection.port,
          username: connection.username,
          password: connection.password,
          domain: connection.domain);

      // Update last connected time
      final dao = ref.read(smbDaoProvider);
      await dao.updateConnection(
          connection.copyWith(lastConnected: DateTime.now()));

      if (context.mounted) {
        ref.read(terminalActionsProvider).connectFileService(
          connectionId: connection.id,
          name: connection.name,
          connectionType: ConnectionType.smb,
          service: service,
        );
        context.push('/smb/browse',
            extra: {'service': service, 'name': connection.name});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.smb_connectFailed(e.toString()))));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.smb_deleteTitle),
        content: Text(l.smb_deleteConfirm(connection.name)),
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
      await ref.read(smbDaoProvider).deleteConnection(connection.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final subtitleParts = <String>['\\\\${connection.host}\\${connection.shareName}'];
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
        leading: Icon(Icons.folder_shared_outlined,
            size: 24,
            color: p.fgSecondary),
        title: Text(connection.displayName),
        subtitle: Text(subtitleParts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12,
                color: p.fgTertiary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () =>
                  context.push('/vaults/smb/edit/${connection.id}'),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
        onTap: () => _connect(context, ref),
      ),
    );
  }
}
