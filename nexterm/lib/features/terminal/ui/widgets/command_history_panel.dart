import 'package:flutter/material.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Search bar.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.commandHistory_searchHint,
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
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
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: reversed.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  itemBuilder: (context, index) {
                    final cmd = reversed[index];
                    return InkWell(
                      onTap: () => widget.onCommandSelected(cmd),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cmd,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : Colors.black87,
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
