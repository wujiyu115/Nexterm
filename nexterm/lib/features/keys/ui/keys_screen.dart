import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/features/keys/ui/widgets/key_list_tile.dart';

class KeysScreen extends ConsumerWidget {
  const KeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final keysAsync = ref.watch(keysStreamProvider);
    final notifier = ref.read(keysNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.keys_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: l.keys_importTooltip,
            onPressed: () => context.push('/keys/import'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l.keys_generateTooltip,
            onPressed: () => context.push('/keys/generate'),
          ),
        ],
      ),
      body: keysAsync.when(
        data: (keys) => _buildContent(context, keys, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SSHKeyEntity> keys, KeysNotifier notifier) {
    if (keys.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return KeyListTile(
          key: ValueKey(key.id),
          sshKey: key,
          onDelete: () => notifier.deleteKey(key.id),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.vpn_key_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(l.keys_noKeys, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l.keys_noKeysHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/keys/generate'),
            icon: const Icon(Icons.add),
            label: Text(l.keys_generate),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/keys/import'),
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(l.keys_import),
          ),
        ],
      ),
    );
  }
}
