import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/features/forwarding/providers/forwarding_provider.dart';
import 'package:nexterm/features/forwarding/services/port_forward_service.dart';
import 'package:nexterm/features/forwarding/ui/widgets/forward_list_tile.dart';

// ---------------------------------------------------------------------------
// Service provider — one instance per app lifetime, disposed on teardown.
// ---------------------------------------------------------------------------

final portForwardServiceProvider = Provider<PortForwardService>((ref) {
  final service = PortForwardService();
  ref.onDispose(() => service.stopAll());
  return service;
});

// ---------------------------------------------------------------------------
// Forwarding screen
// ---------------------------------------------------------------------------

class ForwardingScreen extends ConsumerWidget {
  const ForwardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final forwardsAsync = ref.watch(forwardsStreamProvider);
    final service = ref.watch(portForwardServiceProvider);
    final notifier = ref.read(forwardingNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.forwarding_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l.forwarding_addTooltip,
            onPressed: () => context.push('/forwarding/add'),
          ),
        ],
      ),
      body: forwardsAsync.when(
        data: (forwards) => _buildBody(context, forwards, service, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<PortForwardEntity> forwards,
    PortForwardService service,
    ForwardingNotifier notifier,
  ) {
    if (forwards.isEmpty) return _buildEmptyState(context);

    // Group by ForwardType
    final groups = <ForwardType, List<PortForwardEntity>>{
      ForwardType.local: [],
      ForwardType.remote: [],
      ForwardType.dynamic: [],
    };
    for (final f in forwards) {
      groups[f.type]!.add(f);
    }

    final l = AppLocalizations.of(context)!;

    return ListView(
      children: [
        for (final type in ForwardType.values)
          if (groups[type]!.isNotEmpty) ...[
            _SectionHeader(title: type.localizedName(l)),
            ...groups[type]!.map((f) => _buildTile(context, f, service, notifier)),
          ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    PortForwardEntity forward,
    PortForwardService service,
    ForwardingNotifier notifier,
  ) {
    return ForwardListTile(
      key: ValueKey(forward.id),
      forward: forward,
      status: service.getStatus(forward.id),
      onEdit: () => context.push('/forwarding/edit/${forward.id}'),
      onStartStop: () {
        // Toggle: stop if active, otherwise show a snackbar (no client here).
        if (service.isActive(forward.id)) {
          service.stop(forward.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.forwarding_startFromTerminal),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
            Icons.swap_horiz_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(l.forwarding_noForwards, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/forwarding/add'),
            icon: const Icon(Icons.add),
            label: Text(l.forwarding_add),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
