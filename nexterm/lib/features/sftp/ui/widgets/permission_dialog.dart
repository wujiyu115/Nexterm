import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';

/// Shows a dialog that allows the user to set Unix file permissions.
///
/// The dialog contains:
/// - An octal text field (e.g. "644")
/// - A 3x3 checkbox grid: Owner / Group / Other × r / w / x
///
/// Changes to either the octal field or the checkboxes are kept in sync.
/// Returns the selected permissions as an integer (octal) on confirmation,
/// or null if cancelled.
Future<int?> showPermissionDialog(
  BuildContext context, {
  int initialPermissions = 0x1A4, // 0o644
}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => _PermissionDialog(
      initialPermissions: initialPermissions,
    ),
  );
}

class _PermissionDialog extends StatefulWidget {
  final int initialPermissions;

  const _PermissionDialog({required this.initialPermissions});

  @override
  State<_PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<_PermissionDialog> {
  late final TextEditingController _octalController;

  // Bit layout: index 0..8 maps to [owner-r, owner-w, owner-x, group-r, ...]
  late List<bool> _bits;

  bool _syncing = false;

  static const List<String> _rowLabels = ['Owner', 'Group', 'Other'];
  static const List<String> _colLabels = ['r', 'w', 'x'];

  // Bit masks in the order of _bits[0..8].
  static const List<int> _masks = [
    0x100, 0x080, 0x040, // owner
    0x020, 0x010, 0x008, // group
    0x004, 0x002, 0x001, // other
  ];

  @override
  void initState() {
    super.initState();
    _bits = List.generate(9, (i) => (widget.initialPermissions & _masks[i]) != 0);
    _octalController = TextEditingController(
      text: _bitsToOctal(_bits),
    );
    _octalController.addListener(_onOctalChanged);
  }

  @override
  void dispose() {
    _octalController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sync helpers
  // ---------------------------------------------------------------------------

  String _bitsToOctal(List<bool> bits) {
    int value = 0;
    for (int i = 0; i < 9; i++) {
      if (bits[i]) value |= _masks[i];
    }
    // Express as 3-digit octal.
    final owner = (value >> 6) & 0x7;
    final group = (value >> 3) & 0x7;
    final other = value & 0x7;
    return '$owner$group$other';
  }

  int _currentValue() {
    int value = 0;
    for (int i = 0; i < 9; i++) {
      if (_bits[i]) value |= _masks[i];
    }
    return value;
  }

  void _onOctalChanged() {
    if (_syncing) return;
    final text = _octalController.text.trim();
    if (text.length != 3) return;

    final parsed = int.tryParse(text, radix: 8);
    if (parsed == null) return;

    _syncing = true;
    setState(() {
      for (int i = 0; i < 9; i++) {
        _bits[i] = (parsed & _masks[i]) != 0;
      }
    });
    _syncing = false;
  }

  void _onBitChanged(int index, bool value) {
    setState(() {
      _bits[index] = value;
    });

    if (_syncing) return;
    _syncing = true;
    final octal = _bitsToOctal(_bits);
    _octalController.text = octal;
    _syncing = false;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.permission_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _octalController,
              keyboardType: TextInputType.number,
              maxLength: 3,
              decoration: InputDecoration(
                labelText: l.permission_octalLabel,
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            // 3x3 checkbox grid
            Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                // Header row
                TableRow(
                  children: [
                    const SizedBox(width: 60), // label column spacer
                    for (final col in _colLabels)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          col,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                // Data rows: Owner, Group, Other
                for (int row = 0; row < 3; row++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _rowLabels[row],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      for (int col = 0; col < 3; col++)
                        Checkbox(
                          value: _bits[row * 3 + col],
                          onChanged: (v) =>
                              _onBitChanged(row * 3 + col, v ?? false),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_currentValue()),
          child: Text(l.permission_apply),
        ),
      ],
    );
  }
}
