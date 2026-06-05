import 'package:flutter/cupertino.dart';
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
import 'package:nexterm/shared/widgets/decorative_background.dart';
import 'package:nexterm/shared/widgets/outdoor_search_bar.dart';
import 'package:nexterm/shared/widgets/swipe_delete_glass_card.dart';
import 'package:nexterm/shared/widgets/swipe_to_delete_wrapper.dart';

class SmbConnectionsScreen extends ConsumerStatefulWidget {
  const SmbConnectionsScreen({super.key});

  @override
  ConsumerState<SmbConnectionsScreen> createState() => _SmbConnectionsScreenState();
}

class _SmbConnectionsScreenState extends ConsumerState<SmbConnectionsScreen> {
  final _searchController = TextEditingController();
  final _swipeController = SwipeToDeleteController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  Future<void> _connect(SmbConnectionEntity connection) async {
    final l = AppLocalizations.of(context)!;
    try {
      final service = SmbService();
      await service.connect(connection.host, connection.shareName,
          port: connection.port,
          username: connection.username,
          password: connection.password,
          domain: connection.domain);

      final dao = ref.read(smbDaoProvider);
      await dao.updateConnection(
          connection.copyWith(lastConnected: DateTime.now()));

      if (mounted) {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.smb_connectFailed(e.toString()))));
      }
    }
  }

  Future<void> _confirmDelete(SmbConnectionEntity connection) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.smb_deleteTitle),
        content: Text(l.smb_deleteConfirm(connection.name)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.common_cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.common_delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(smbDaoProvider).deleteConnection(connection.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;

    Widget buildContent() {
      if (_searchQuery.isNotEmpty) {
        final searchAsync = ref.watch(smbSearchProvider(_searchQuery));
        return searchAsync.when(
          data: (connections) => _buildList(connections),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
        );
      }

      final connectionsAsync = ref.watch(smbConnectionsStreamProvider);
      return connectionsAsync.when(
        data: (connections) => _buildList(connections),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      );
    }

    return DecorativeBackground(
      showRidge: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(l.smb_title),
          actions: [
            IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.accentDim),
                child: Icon(Icons.add, size: 16, color: p.accent),
              ),
              tooltip: l.smb_add,
              onPressed: () => context.push('/vaults/smb/add'),
            ),
          ],
        ),
        body: Column(
          children: [
            OutdoorSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              hintText: l.smb_search,
            ),
            Expanded(child: buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<SmbConnectionEntity> connections) {
    if (connections.isEmpty) {
      return _buildEmptyState();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _swipeController.closeAny();
        return false;
      },
      child: ListView(
        children: [
          ...connections.map((conn) => _buildTile(conn)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTile(SmbConnectionEntity connection) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final subtitleParts = <String>['\\\\${connection.host}\\${connection.shareName}'];
    if (connection.lastConnected != null) {
      final dt = connection.lastConnected!;
      subtitleParts.add(
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}');
    }

    return SwipeDeleteGlassCard(
      key: ValueKey(connection.id),
      swipeController: _swipeController,
      onTap: () => _connect(connection),
      onDelete: () => _confirmDelete(connection),
      child: Row(
        children: [
          Icon(Icons.folder_shared_outlined, size: 24, color: p.fgSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connection.displayName,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleParts.join(' · '),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: p.fgSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: p.fgTertiary),
            onPressed: () => context.push('/vaults/smb/edit/${connection.id}'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_shared_outlined, size: 64, color: p.fgTertiary),
          const SizedBox(height: 16),
          Text(l.smb_noConnections, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l.smb_noConnectionsHint, style: TextStyle(color: p.fgTertiary)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/vaults/smb/add'),
            icon: const Icon(Icons.add),
            label: Text(l.smb_add),
          ),
        ],
      ),
    );
  }
}
