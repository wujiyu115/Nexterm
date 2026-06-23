import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/features/multiplexer/services/multiplexer_registry.dart';
import 'package:nexterm/features/multiplexer/services/multiplexer_service.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:nexterm/shared/widgets/glass_card.dart';

class MuxSessionSheet extends ConsumerStatefulWidget {
  final String sessionId;
  const MuxSessionSheet({super.key, required this.sessionId});

  @override
  ConsumerState<MuxSessionSheet> createState() => _MuxSessionSheetState();
}

class _MuxSessionSheetState extends ConsumerState<MuxSessionSheet> {
  List<MultiplexerService>? _installedMuxes;
  MultiplexerService? _activeMux;
  List<MuxSession>? _sessions;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detect();
  }

  SSHClient? get _client {
    final sshService = ref.read(sshServiceProvider);
    return sshService.getClient(widget.sessionId);
  }

  Future<void> _detect() async {
    final client = _client;
    if (client == null) {
      if (mounted) setState(() { _loading = false; _error = 'No SSH session'; });
      return;
    }
    try {
      final installed = await MultiplexerRegistry.detectInstalled(client);
      if (!mounted) return;
      if (installed.isEmpty) {
        setState(() { _loading = false; _installedMuxes = []; });
        return;
      }
      setState(() { _installedMuxes = installed; _activeMux = installed.first; });
      await _loadSessions();
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _loadSessions() async {
    final client = _client;
    final mux = _activeMux;
    if (client == null || mux == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final sessions = await mux.listSessions(client);
      if (mounted) setState(() { _sessions = sessions; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _attach(String sessionName) {
    Navigator.of(context).pop();
    final sshService = ref.read(sshServiceProvider);
    sshService.write(widget.sessionId, '${_activeMux!.attachCommand(sessionName)}\r');
  }

  Future<void> _killSession(String sessionName) async {
    final client = _client;
    final mux = _activeMux;
    if (client == null || mux == null) return;
    await mux.killSession(client, sessionName);
    _loadSessions();
  }

  void _renameSession(String oldName) {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: oldName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.mux_renameSession),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.mux_sessionName),
          onSubmitted: (v) {
            final name = v.trim();
            if (name.isNotEmpty && name != oldName) {
              Navigator.of(ctx).pop();
              _doRename(oldName, name);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && name != oldName) {
                Navigator.of(ctx).pop();
                _doRename(oldName, name);
              }
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _doRename(String oldName, String newName) async {
    final client = _client;
    final mux = _activeMux;
    if (client == null || mux == null) return;
    await mux.renameSession(client, oldName, newName);
    _loadSessions();
  }

  void _newSession() {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.mux_newSession),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.mux_sessionName),
          onSubmitted: (v) {
            final name = v.trim();
            if (name.isNotEmpty) {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              final sshService = ref.read(sshServiceProvider);
              sshService.write(widget.sessionId, '${_activeMux!.newSessionCommand(name)}\r');
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                final sshService = ref.read(sshServiceProvider);
                sshService.write(widget.sessionId, '${_activeMux!.newSessionCommand(name)}\r');
              }
            },
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: p.bgElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(width: 36, height: 4, decoration: BoxDecoration(color: p.fgTertiary.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(l.terminal_openMux, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (_activeMux != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _loadSessions,
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
              // Mux type chips
              if (_installedMuxes != null && _installedMuxes!.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _installedMuxes!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final mux = _installedMuxes![index];
                        final isSelected = mux.type == _activeMux?.type;
                        return ChoiceChip(
                          label: Text(mux.displayName),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _activeMux = mux);
                            _loadSessions();
                          },
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Expanded(child: _buildContent(l, theme, p, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(AppLocalizations l, ThemeData theme, ThemePalette p, ScrollController scrollController) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: p.fgSecondary)));
    }

    if (_installedMuxes != null && _installedMuxes!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48, color: p.fgTertiary),
            const SizedBox(height: 12),
            Text(l.mux_notInstalled, style: theme.textTheme.bodyMedium?.copyWith(color: p.fgSecondary)),
          ],
        ),
      );
    }

    final sessions = _sessions ?? [];

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        // New session button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: OutlinedButton.icon(
            onPressed: _newSession,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l.mux_newSession),
          ),
        ),
        if (sessions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text(l.mux_noSessions, style: theme.textTheme.bodyMedium?.copyWith(color: p.fgSecondary))),
          )
        else
          ...sessions.map((s) => _buildSessionTile(s, theme, p, l)),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildSessionTile(MuxSession session, ThemeData theme, ThemePalette p, AppLocalizations l) {
    final subtitleParts = <String>[l.mux_windows(session.windows)];
    if (session.isAttached) subtitleParts.add('${session.attachedCount} ${l.mux_attached}');
    if (session.lastActivity != null) subtitleParts.add(_formatTime(session.lastActivity));

    return GlassCard(
      onTap: () => _attach(session.name),
      child: Row(
        children: [
          Icon(_activeMux!.icon, size: 22, color: session.isAttached ? p.accent : p.fgSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(session.name, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
                    if (session.isAttached) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: p.accentDim, borderRadius: BorderRadius.circular(6)),
                        child: Text(l.mux_attached, style: theme.textTheme.labelSmall?.copyWith(color: p.accent)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitleParts.join(' · '), style: theme.textTheme.bodySmall?.copyWith(color: p.fgTertiary)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: p.fgSecondary),
            visualDensity: VisualDensity.compact,
            onPressed: () => _renameSession(session.name),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: p.statusError),
            visualDensity: VisualDensity.compact,
            onPressed: () => _killSession(session.name),
          ),
        ],
      ),
    );
  }
}
