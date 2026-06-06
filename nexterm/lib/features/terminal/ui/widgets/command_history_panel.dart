import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/providers/command_history_provider.dart';

class CommandHistoryPanel extends ConsumerStatefulWidget {
  final String sessionId;
  final String? hostId;
  final void Function(String command) onCommandSelected;

  const CommandHistoryPanel({
    super.key,
    required this.sessionId,
    this.hostId,
    required this.onCommandSelected,
  });

  @override
  ConsumerState<CommandHistoryPanel> createState() =>
      _CommandHistoryPanelState();
}

class _CommandHistoryPanelState extends ConsumerState<CommandHistoryPanel> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _showHostHistory = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: l.commandHistory_searchHint,
                    hintStyle: TextStyle(color: p.fgTertiary),
                    prefixIcon: Icon(Icons.search, size: 20, color: p.fgTertiary),
                    filled: true,
                    fillColor: p.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(OutdoorColors.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              if (widget.hostId != null) ...[
                const SizedBox(width: 8),
                _ModeToggle(
                  isHostMode: _showHostHistory,
                  onToggle: () =>
                      setState(() => _showHostHistory = !_showHostHistory),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _showHostHistory && widget.hostId != null
              ? _HostHistoryList(
                  hostId: widget.hostId!,
                  query: _query,
                  onCommandSelected: widget.onCommandSelected,
                )
              : _SessionHistoryList(
                  sessionId: widget.sessionId,
                  query: _query,
                  onCommandSelected: widget.onCommandSelected,
                ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isHostMode;
  final VoidCallback onToggle;

  const _ModeToggle({required this.isHostMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    return IconButton(
      icon: Icon(
        isHostMode ? Icons.storage : Icons.terminal,
        size: 20,
        color: isHostMode ? p.accent : p.fgSecondary,
      ),
      tooltip: isHostMode ? 'Host history' : 'Session history',
      onPressed: onToggle,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SessionHistoryList extends ConsumerWidget {
  final String sessionId;
  final String query;
  final void Function(String command) onCommandSelected;

  const _SessionHistoryList({
    required this.sessionId,
    required this.query,
    required this.onCommandSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(commandHistoryServiceProvider);
    final commands = query.isEmpty
        ? service.getAll(sessionId)
        : service.search(sessionId, query);
    final reversed = commands.reversed.toList();

    return _CommandList(
      commands: reversed.map((c) => _DisplayCommand(command: c)).toList(),
      onCommandSelected: onCommandSelected,
      emptyQuery: query,
    );
  }
}

class _HostHistoryList extends ConsumerWidget {
  final String hostId;
  final String query;
  final void Function(String command) onCommandSelected;

  const _HostHistoryList({
    required this.hostId,
    required this.query,
    required this.onCommandSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(hostCommandHistoryProvider(hostId));

    return historyAsync.when(
      data: (entries) {
        final filtered = query.isEmpty
            ? entries
            : entries
                .where((e) =>
                    e.command.toLowerCase().contains(query.toLowerCase()))
                .toList();
        return _CommandList(
          commands: filtered
              .map((e) => _DisplayCommand(
                    command: e.command,
                    frequency: e.frequency,
                  ))
              .toList(),
          onCommandSelected: onCommandSelected,
          emptyQuery: query,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class _DisplayCommand {
  final String command;
  final int? frequency;

  const _DisplayCommand({required this.command, this.frequency});
}

class _CommandList extends StatelessWidget {
  final List<_DisplayCommand> commands;
  final void Function(String command) onCommandSelected;
  final String emptyQuery;

  const _CommandList({
    required this.commands,
    required this.onCommandSelected,
    required this.emptyQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;
    final l = AppLocalizations.of(context)!;

    if (commands.isEmpty) {
      return Center(
        child: Text(
          emptyQuery.isEmpty
              ? l.commandHistory_empty
              : l.commandHistory_noMatch,
          style: theme.textTheme.bodyLarge!.copyWith(color: p.fgSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: commands.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: p.border),
      itemBuilder: (context, index) {
        final item = commands[index];
        return InkWell(
          onTap: () => onCommandSelected(item.command),
          borderRadius: BorderRadius.circular(OutdoorColors.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.chevron_right, size: 16, color: p.fgTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.command,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontFamily: AppFonts.mono,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.frequency != null && item.frequency! > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.frequency}',
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: p.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
