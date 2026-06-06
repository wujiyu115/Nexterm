import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/monitor/providers/monitor_provider.dart';
import 'package:nexterm/features/monitor/ui/widgets/cpu_chart.dart';
import 'package:nexterm/features/monitor/ui/widgets/disk_usage_card.dart';
import 'package:nexterm/features/monitor/ui/widgets/memory_chart.dart';
import 'package:nexterm/features/monitor/ui/widgets/network_chart.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';

class MonitorScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const MonitorScreen({super.key, required this.sessionId});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_startMonitoring);
  }

  void _startMonitoring() {
    if (!mounted) return;
    final sshService = ref.read(sshServiceProvider);
    final client = sshService.getClient(widget.sessionId);
    if (client != null) {
      ref.read(monitorProvider(widget.sessionId).notifier).start(client);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(monitorProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.monitor_title),
        actions: [
          if (state.latest != null) ...[
            if (state.latest!.osInfo != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Text(
                    state.latest!.osInfo!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ],
      ),
      body: _buildBody(context, l, state),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l, MonitorState state) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(l.monitor_connectionLost),
          ],
        ),
      );
    }

    if (state.isConnecting && state.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l.monitor_connecting),
          ],
        ),
      );
    }

    if (state.history.isEmpty) {
      return Center(child: Text(l.monitor_noData));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CpuChart(history: state.history),
        const SizedBox(height: 16),
        MemoryChart(history: state.history),
        const SizedBox(height: 16),
        NetworkChart(history: state.history),
        const SizedBox(height: 16),
        if (state.latest!.disks.isNotEmpty)
          DiskUsageCard(disks: state.latest!.disks),
        if (state.latest!.uptime != null || state.latest!.loadAverage != null) ...[
          const SizedBox(height: 16),
          _buildInfoCard(context, l, state.latest!),
        ],
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, AppLocalizations l, dynamic snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (snapshot.uptime != null)
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 8),
                  Text('${l.monitor_uptime}: ${snapshot.uptime}'),
                ],
              ),
            if (snapshot.loadAverage != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.speed, size: 16),
                  const SizedBox(width: 8),
                  Text('${l.monitor_loadAvg}: ${snapshot.loadAverage}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
