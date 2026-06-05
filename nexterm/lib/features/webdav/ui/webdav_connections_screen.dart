import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/webdav_connection_entity.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/webdav/providers/webdav_provider.dart';
import 'package:nexterm/features/webdav/services/webdav_service.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';
import 'package:nexterm/shared/widgets/outdoor_search_bar.dart';
import 'package:nexterm/shared/widgets/swipe_delete_glass_card.dart';
import 'package:nexterm/shared/widgets/swipe_to_delete_wrapper.dart';

class WebDavConnectionsScreen extends ConsumerStatefulWidget {
  const WebDavConnectionsScreen({super.key});

  @override
  ConsumerState<WebDavConnectionsScreen> createState() => _WebDavConnectionsScreenState();
}

class _WebDavConnectionsScreenState extends ConsumerState<WebDavConnectionsScreen> {
  final _searchController = TextEditingController();
  final _swipeController = SwipeToDeleteController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  Future<void> _connect(WebdavConnectionEntity connection) async {
    final l = AppLocalizations.of(context)!;
    try {
      final service = WebDavService();
      service.connect(connection.url,
          username: connection.username, password: connection.password);

      final dao = ref.read(webdavDaoProvider);
      await dao.updateConnection(
          connection.copyWith(lastConnected: DateTime.now()));

      if (mounted) {
        ref.read(terminalActionsProvider).connectFileService(
          connectionId: connection.id,
          name: connection.name,
          connectionType: ConnectionType.webdav,
          service: service,
        );
        context.push('/webdav/browse',
            extra: {'service': service, 'name': connection.name});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.webdav_connectFailed(e.toString()))));
      }
    }
  }

  Future<void> _confirmDelete(WebdavConnectionEntity connection) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.webdav_deleteTitle),
        content: Text(l.webdav_deleteConfirm(connection.name)),
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
      await ref.read(webdavDaoProvider).deleteConnection(connection.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;

    Widget buildContent() {
      if (_searchQuery.isNotEmpty) {
        final searchAsync = ref.watch(webdavSearchProvider(_searchQuery));
        return searchAsync.when(
          data: (connections) => _buildList(connections),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
        );
      }

      final connectionsAsync = ref.watch(webdavConnectionsStreamProvider);
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
          title: Text(l.webdav_title),
          actions: [
            IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.accentDim),
                child: Icon(Icons.add, size: 16, color: p.accent),
              ),
              tooltip: l.webdav_add,
              onPressed: () => context.push('/vaults/webdav/add'),
            ),
          ],
        ),
        body: Column(
          children: [
            OutdoorSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              hintText: l.webdav_search,
            ),
            Expanded(child: buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<WebdavConnectionEntity> connections) {
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

  Widget _buildTile(WebdavConnectionEntity connection) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final subtitleParts = <String>[connection.url];
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
          Icon(Icons.cloud_outlined, size: 24, color: p.fgSecondary),
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
            onPressed: () => context.push('/vaults/webdav/edit/${connection.id}'),
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
          Icon(Icons.cloud_outlined, size: 64, color: p.fgTertiary),
          const SizedBox(height: 16),
          Text(l.webdav_noConnections, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l.webdav_noConnectionsHint, style: TextStyle(color: p.fgTertiary)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/vaults/webdav/add'),
            icon: const Icon(Icons.add),
            label: Text(l.webdav_add),
          ),
        ],
      ),
    );
  }
}
