import 'package:flutter/material.dart';
import 'package:nexterm/core/theme/outdoor_colors.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/features/terminal/providers/command_history_provider.dart';

/// Panel that displays command history for a terminal session.
///
/// Includes a search bar at the top and a scrollable list of commands.
/// Tapping a command sends it to the terminal.
class CommandHistoryPanel extends ConsumerStatefulWidget {
  final String sessionId;
  final void Function(String command) onCommandSelected;

  const CommandHistoryPanel({
    super.key,
    required this.sessionId,
    required this.onCommandSelected,
  });

  @override
  ConsumerState<CommandHistoryPanel> createState() =>
      _CommandHistoryPanelState();
}

class _CommandHistoryPanelState extends ConsumerState<CommandHistoryPanel> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(commandHistoryServiceProvider);
    final commands = _query.isEmpty
        ? service.getAll(widget.sessionId)
        : service.search(widget.sessionId, _query);

    // Show most recent first.
    final reversed = commands.reversed.toList();

    final theme = Theme.of(context);
    final p = theme.extension<ThemePalette>()!;

    return Column(
      children: [
        // Search bar.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchController,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.commandHistory_searchHint,
              hintStyle: TextStyle(
                color: p.fgTertiary,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: p.fgTertiary,
              ),
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
        // Command list.
        Expanded(
          child: reversed.isEmpty
              ? Center(
                  child: Text(
                    _query.isEmpty ? AppLocalizations.of(context)!.commandHistory_empty : AppLocalizations.of(context)!.commandHistory_noMatch,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: p.fgSecondary,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: reversed.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: p.border,
                  ),
                  itemBuilder: (context, index) {
                    final cmd = reversed[index];
                    return InkWell(
                      onTap: () => widget.onCommandSelected(cmd),
                      borderRadius: BorderRadius.circular(OutdoorColors.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: p.fgTertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cmd,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontFamily: AppFonts.mono,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
