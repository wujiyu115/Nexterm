import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/forwarding/models/detected_port.dart';
import 'package:nexterm/features/forwarding/providers/forwarding_provider.dart';
import 'package:nexterm/features/forwarding/providers/port_detection_provider.dart';
import 'package:nexterm/features/forwarding/ui/widgets/detected_port_tile.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/shared/widgets/section_label.dart';

class PortDetectionSheet extends ConsumerStatefulWidget {
  const PortDetectionSheet({super.key});

  @override
  ConsumerState<PortDetectionSheet> createState() => _PortDetectionSheetState();
}

class _PortDetectionSheetState extends ConsumerState<PortDetectionSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessions = ref.read(activeSessionsForDetectionProvider);
      if (sessions.length == 1) {
        ref.read(portDetectionNotifierProvider.notifier).scan(sessions.first.sessionId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final sessions = ref.watch(activeSessionsForDetectionProvider);
    final detectionState = ref.watch(portDetectionNotifierProvider);
    final forwardsAsync = ref.watch(forwardsStreamProvider);

    final forwardedPorts = <int>{};
    forwardsAsync.whenData((forwards) {
      for (final f in forwards) {
        forwardedPorts.add(f.remotePort ?? f.localPort);
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: p.bgElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.fgTertiary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      l.portDetect_title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (detectionState.activeSessionId != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        tooltip: l.portDetect_rescanButton,
                        onPressed: () {
                          ref.read(portDetectionNotifierProvider.notifier)
                              .scan(detectionState.activeSessionId!);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              // Session picker (if multiple)
              if (sessions.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isSelected = detectionState.activeSessionId == session.sessionId;
                        return ChoiceChip(
                          label: Text(session.hostName),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(portDetectionNotifierProvider.notifier)
                                .scan(session.sessionId);
                          },
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ),
              ],
              // Search
              if (detectionState.ports.valueOrNull != null && detectionState.ports.valueOrNull!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      hintText: l.portDetect_search,
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() { _searchController.clear(); _searchQuery = ''; }),
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              // Content
              Expanded(
                child: _buildContent(
                  context,
                  detectionState,
                  sessions,
                  forwardedPorts,
                  scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    PortDetectionState state,
    List<SessionInfo> sessions,
    Set<int> forwardedPorts,
    ScrollController scrollController,
  ) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final secondaryColor = p.fgSecondary;

    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l.portDetect_noSessions,
            style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.activeSessionId == null && sessions.length > 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l.portDetect_selectSession,
            style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return state.ports.when(
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l.portDetect_scanning, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                l.portDetect_error(e.toString()),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.read(portDetectionNotifierProvider.notifier)
                      .scan(state.activeSessionId!);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l.portDetect_rescanButton),
              ),
            ],
          ),
        ),
      ),
      data: (ports) {
        if (ports.isEmpty) {
          return Center(
            child: Text(
              l.portDetect_noPorts,
              style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
            ),
          );
        }

        final filtered = _searchQuery.isEmpty
            ? ports
            : ports.where((p) {
                final q = _searchQuery.toLowerCase();
                return p.port.toString().contains(q) ||
                    (p.processName?.toLowerCase().contains(q) ?? false) ||
                    p.bindAddress.toLowerCase().contains(q) ||
                    p.protocolGuess.toLowerCase().contains(q);
              }).toList();

        final userPorts = filtered.where((p) => p.category == PortCategory.user).toList();
        final systemPorts = filtered.where((p) => p.category == PortCategory.system).toList();

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                l.portDetect_portsFound(ports.length),
                style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor),
              ),
            ),
            if (userPorts.isNotEmpty) ...[
              SectionLabel(title: l.portDetect_userPorts),
              ...userPorts.map((p) => _buildPortTile(p, forwardedPorts)),
            ],
            if (systemPorts.isNotEmpty) ...[
              SectionLabel(title: l.portDetect_systemPorts),
              ...systemPorts.map((p) => _buildPortTile(p, forwardedPorts)),
            ],
            // Permission hint if any ports lack process name
            if (ports.any((p) => p.processName == null))
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                child: Text(
                  l.portDetect_permissionHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.fgTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  static const _httpPorts = {80, 443, 3000, 3001, 4200, 5000, 5173, 5174, 8000, 8080, 8443, 8888, 9000};
  static const _httpProcessHints = ['node', 'python', 'python3', 'tsx', 'npx', 'next', 'vite', 'nginx', 'apache', 'caddy', 'deno', 'bun'];

  bool _isHttpLike(DetectedPort port) {
    final proto = port.protocolGuess.toLowerCase();
    if (proto.contains('http')) return true;
    if (_httpPorts.contains(port.port)) return true;
    final cmd = port.commandLine?.toLowerCase() ?? '';
    if (cmd.isNotEmpty) {
      for (final hint in _httpProcessHints) {
        if (cmd.contains(hint)) return true;
      }
    }
    if (port.port > 1024) return true;
    return false;
  }

  Widget _buildPortTile(DetectedPort port, Set<int> forwardedPorts) {
    final isForwarded = forwardedPorts.contains(port.port);
    final sessions = ref.read(activeSessionsForDetectionProvider);
    final activeSessionId = ref.read(portDetectionNotifierProvider).activeSessionId;
    final session = sessions.firstWhere((s) => s.sessionId == activeSessionId);

    return DetectedPortTile(
      port: port,
      isForwarded: isForwarded,
      onPreview: _isHttpLike(port)
          ? () {
              Navigator.of(context).pop();
              ref.read(terminalActionsProvider).openWebPreview(
                hostId: session.hostId,
                remotePort: port.port,
                sessionId: session.sessionId,
                title: port.processName ?? ':${port.port}',
              );
            }
          : null,
      onTap: () {
        Navigator.of(context).pop();
        context.push('/vaults/forwarding/add', extra: <String, dynamic>{
          'name': '${port.processName ?? port.protocolGuess}:${port.port}',
          'hostId': session.hostId,
          'localPort': port.port,
          'remoteHost': 'localhost',
          'remotePort': port.port,
        });
      },
    );
  }
}
