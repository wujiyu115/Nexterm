import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/features/forwarding/providers/forwarding_provider.dart';
import 'package:nexterm/features/forwarding/services/port_forward_service.dart';
import 'package:nexterm/features/forwarding/ui/port_detection_sheet.dart';
import 'package:nexterm/features/forwarding/ui/widgets/forward_list_tile.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/shared/widgets/decorative_background.dart';
import 'package:nexterm/shared/widgets/section_label.dart';

class ForwardingScreen extends ConsumerWidget {
  const ForwardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final forwardsAsync = ref.watch(forwardsStreamProvider);
    final service = ref.watch(portForwardServiceProvider);
    final notifier = ref.read(forwardingNotifierProvider.notifier);

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
        title: Text(l.forwarding_title),
        actions: [
          IconButton(
            tooltip: l.portDetect_tooltip,
            onPressed: () => _showDetectionSheet(context),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.accentDim,
              ),
              child: Icon(Icons.radar, size: 16, color: p.accent),
            ),
          ),
          IconButton(
            tooltip: l.forwarding_addTooltip,
            onPressed: () => context.push('/vaults/forwarding/add'),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.accentDim,
              ),
              child: Icon(Icons.add, size: 16, color: p.accent),
            ),
          ),
        ],
      ),
      body: forwardsAsync.when(
        data: (forwards) => _buildBody(context, forwards, service, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.common_error(e.toString()))),
      ),
    ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<PortForwardEntity> forwards,
    PortForwardService service,
    ForwardingNotifier notifier,
  ) {
    // Find ephemeral forwards (active but not saved in DB)
    final savedIds = forwards.map((f) => f.id).toSet();
    final ephemeral = service.activeForwards
        .where((af) => !savedIds.contains(af.entity.id))
        .toList();

    if (forwards.isEmpty && ephemeral.isEmpty) return _buildEmptyState(context);

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
            SectionLabel(title: type.localizedName(l)),
            ...groups[type]!.map((f) => _buildTile(context, f, service, notifier)),
          ],
        if (ephemeral.isNotEmpty) ...[
          SectionLabel(title: l.forwarding_ephemeral),
          ...ephemeral.map((af) => _buildEphemeralTile(context, af, service)),
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
      onEdit: () => context.push('/vaults/forwarding/edit/${forward.id}'),
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

  Widget _buildEphemeralTile(
    BuildContext context,
    ActiveForward af,
    PortForwardService service,
  ) {
    final entity = af.entity;
    return ForwardListTile(
      key: ValueKey(entity.id),
      forward: entity,
      status: ForwardStatus.active,
      onEdit: () {},
      onStartStop: () => service.stop(entity.id),
    );
  }

  void _showDetectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PortDetectionSheet(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz_outlined,
            size: 64,
            color: p.fgTertiary,
          ),
          const SizedBox(height: 16),
          Text(l.forwarding_noForwards, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.push('/vaults/forwarding/add'),
            icon: const Icon(Icons.add),
            label: Text(l.forwarding_add),
          ),
        ],
      ),
    );
  }
}

