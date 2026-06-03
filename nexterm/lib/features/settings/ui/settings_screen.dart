import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/locale/locale_provider.dart';
import 'package:nexterm/core/theme/theme_catalog.dart';
import 'package:nexterm/core/theme/theme_palette.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_font_family_provider.dart';
import 'package:nexterm/features/terminal/providers/terminal_scrollback_provider.dart';
import 'package:nexterm/features/terminal/providers/voice_locale_provider.dart';
import 'package:nexterm/features/settings/ui/widgets/stt_settings_section.dart';
import 'package:nexterm/features/settings/utils/ssh_config_parser.dart';
import 'package:nexterm/features/sync/providers/auth_provider.dart';
import 'package:nexterm/shared/widgets/section_label.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).extension<ThemePalette>()!;
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListTileTheme(
          dense: true,
          minVerticalPadding: 2,
          child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _NavTitle(title: l.settings_title),
          ),
          SectionLabel(title: l.settings_sectionGeneral),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l.settings_theme),
            subtitle: Text(ThemeCatalog.displayName(ref.watch(themeProvider))),
            onTap: () => _showThemePicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l.settings_language),
            subtitle: Text(_languageLabel(ref, l)),
            onTap: () => _showLanguagePicker(context, ref),
          ),

          SectionLabel(title: l.settings_sectionTerminal),
          _FontSizeTile(
            fontSize: double.tryParse(
                  settings[SettingsKeys.terminalFontSize] ?? '',
                ) ??
                13.0,
            onChanged: (v) => settingsNotifier.set(SettingsKeys.terminalFontSize, v.round().toString()),
          ),
          ListTile(
            leading: const Icon(Icons.font_download_outlined),
            title: Text(l.settings_fontFamily),
            subtitle: Text(ref.watch(terminalFontFamilyProvider)),
            onTap: () => _showFontFamilyPicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: Text(l.settings_scrollbackLines),
            subtitle: Text('${ref.watch(terminalScrollbackProvider)} ${l.settings_scrollbackLinesSuffix}'),
            onTap: () => _showScrollbackPicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields_outlined),
            title: Text(l.settings_cursorStyle),
            subtitle: Text(_cursorStyleLabel(settings[SettingsKeys.cursorStyle] ?? 'block', l)),
            onTap: () => _showCursorStylePicker(context, settings[SettingsKeys.cursorStyle] ?? 'block', settingsNotifier),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_outlined),
            title: Text(l.settings_hapticFeedback),
            value: settings[SettingsKeys.hapticFeedback] == 'true',
            onChanged: (v) => settingsNotifier.set(SettingsKeys.hapticFeedback, v.toString()),
          ),

          const SttSettingsSection(),
          ListTile(
            leading: const Icon(Icons.mic_outlined),
            title: Text(l.settings_voiceLocale),
            subtitle: Text(_voiceLocaleLabel(ref, settings[SettingsKeys.voiceInputLocale] ?? '', l)),
            onTap: () => _showVoiceLocalePicker(context),
          ),

          SectionLabel(title: l.settings_sectionSecurity),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_outlined),
            title: Text(l.settings_biometric),
            value: settings[SettingsKeys.biometricEnabled] == 'true',
            onChanged: (v) => settingsNotifier.set(SettingsKeys.biometricEnabled, v.toString()),
          ),
          ListTile(
            leading: const Icon(Icons.lock_clock_outlined),
            title: Text(l.settings_autoLock),
            subtitle: Text(_autoLockLabel(settings[SettingsKeys.autoLockMinutes] ?? '5', l)),
            onTap: () => _showAutoLockPicker(context, settings[SettingsKeys.autoLockMinutes] ?? '5', settingsNotifier),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.content_paste_off_outlined),
            title: Text(l.settings_clipboardAutoClear),
            subtitle: Text(l.settings_clipboardAutoClearHint),
            value: settings[SettingsKeys.clipboardAutoClear] == 'true',
            onChanged: (v) => settingsNotifier.set(SettingsKeys.clipboardAutoClear, v.toString()),
          ),

          SectionLabel(title: l.settings_sectionSync),
          if (authState.isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(l.settings_account),
              subtitle: Text(authState.email ?? l.settings_loggedIn),
            ),
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: Text(l.settings_deviceManagement),
              onTap: () => _showDeviceManagementDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.sync_outlined),
              title: Text(l.settings_syncNow),
              onTap: () => _triggerManualSync(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: Text(l.settings_logout),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => _confirmLogout(context, ref),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login_outlined),
              title: Text(l.settings_loginRegister),
              subtitle: Text(l.settings_loginHint),
              onTap: () => _showLoginDialog(context, ref),
            ),
          ],

          SectionLabel(title: l.settings_sectionData),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(l.settings_importSshConfig),
            subtitle: Text(l.settings_importSshConfigHint),
            onTap: () => _showImportDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l.settings_exportData),
            subtitle: Text(l.settings_exportDataHint),
            onTap: () => _showExportDialog(context),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'v0.1.0',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: p.fgTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  // ---------- label helpers ----------

  static String _cursorStyleLabel(String style, AppLocalizations l) => switch (style) {
        'block' => l.settings_cursorBlock,
        'underline' => l.settings_cursorUnderline,
        'bar' => l.settings_cursorBar,
        _ => style,
      };

  static String _autoLockLabel(String minutes, AppLocalizations l) {
    final m = int.tryParse(minutes);
    if (m == null || m <= 0) return l.settings_autoLockNever;
    if (m == 1) return l.settings_autoLockOneMinute;
    return l.settings_autoLockMinutes(m);
  }

  static String _voiceLocaleLabel(WidgetRef ref, String localeId, AppLocalizations l) {
    if (localeId.isEmpty) return l.settings_voiceLocaleSystem;
    final async = ref.watch(availableSpeechLocalesProvider);
    final list = async.asData?.value;
    if (list != null) {
      for (final loc in list) {
        if (loc.localeId == localeId) return loc.name;
      }
    }
    return localeId;
  }

  static String _languageLabel(WidgetRef ref, AppLocalizations l) {
    final locale = ref.watch(localeProvider);
    if (locale == null) return l.settings_languageSystem;
    if (locale.languageCode == 'zh') return l.settings_languageChinese;
    if (locale.languageCode == 'en') return l.settings_languageEnglish;
    return l.settings_languageSystem;
  }

  // ---------- pickers / dialogs ----------

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _UnifiedThemePickerDialog(),
    );
  }

  void _showCursorStylePicker(BuildContext context, String current, SettingsNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CursorStylePickerDialog(current: current, notifier: notifier),
    );
  }

  void _showScrollbackPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(terminalScrollbackProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => _ScrollbackInputDialog(
        current: current,
        onConfirm: (v) => ref.read(terminalScrollbackProvider.notifier).setLines(v),
      ),
    );
  }

  void _showFontFamilyPicker(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _FontFamilyPickerDialog(ref: ref),
    );
  }

  void _showAutoLockPicker(BuildContext context, String current, SettingsNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _AutoLockPickerDialog(current: current, notifier: notifier),
    );
  }

  void _showDeviceManagementDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settings_deviceManagementTitle),
        content: Text(l.settings_deviceManagementContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_confirm)),
        ],
      ),
    );
  }

  void _triggerManualSync(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.settings_syncing)),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settings_logoutTitle),
        content: Text(l.settings_logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: Text(l.settings_logoutButton),
          ),
        ],
      ),
    );
  }

  void _showLoginDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _LoginDialog(ref: ref),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null) return;

    try {
      final content = await File(path).readAsString();
      final entries = SshConfigParser.parse(content);
      final hostsNotifier = ref.read(hostsNotifierProvider.notifier);
      for (final entry in entries) {
        final host = HostEntity(
          id: '',
          name: entry.name,
          hostname: entry.hostname,
          port: entry.port,
          username: entry.username,
          authMethod: AuthMethod.password,
        );
        await hostsNotifier.addHost(host);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.settings_importedCount(entries.length))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.settings_importFailed(e.toString()))),
        );
      }
    }
  }

  void _showExportDialog(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settings_exportTitle),
        content: Text(l.settings_exportContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.common_cancel)),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.settings_exported)),
              );
            },
            child: Text(l.settings_exportButton),
          ),
        ],
      ),
    );
  }

  void _showVoiceLocalePicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _VoiceLocalePickerDialog(),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.read(localeProvider);

    String currentValue;
    if (currentLocale == null) {
      currentValue = 'system';
    } else if (currentLocale.languageCode == 'zh') {
      currentValue = 'zh';
    } else {
      currentValue = 'en';
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settings_language),
        children: [
          RadioGroup<String>(
            groupValue: currentValue,
            onChanged: (v) {
              if (v != null) {
                localeNotifier.setLocale(v);
                Navigator.of(ctx).pop();
              }
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l.settings_languageSystem),
                  value: 'system',
                ),
                RadioListTile<String>(
                  title: Text(l.settings_languageChinese),
                  value: 'zh',
                ),
                RadioListTile<String>(
                  title: Text(l.settings_languageEnglish),
                  value: 'en',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Font size tile ----------

class _FontSizeTile extends StatelessWidget {
  final double fontSize;
  final ValueChanged<double> onChanged;
  const _FontSizeTile({required this.fontSize, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.format_size_outlined),
      title: Text(l.settings_fontSize),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${fontSize.round()} pt'),
          Slider(
            value: fontSize.clamp(8.0, 24.0),
            min: 8,
            max: 24,
            divisions: 16,
            label: '${fontSize.round()} pt',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ---------- Unified theme picker dialog ----------

class _UnifiedThemePickerDialog extends ConsumerWidget {
  const _UnifiedThemePickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final p = Theme.of(context).extension<ThemePalette>()!;
    final current = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.settings_selectTheme,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _ThemeGroup(
                    label: l.settings_themeGroupDark,
                    keys: ThemeCatalog.darkKeys,
                    current: current,
                    accent: p.accent,
                    onSelect: (k) {
                      notifier.setTheme(k);
                      Navigator.of(context).pop();
                    },
                  ),
                  _ThemeGroup(
                    label: l.settings_themeGroupLight,
                    keys: ThemeCatalog.lightKeys,
                    current: current,
                    accent: p.accent,
                    onSelect: (k) {
                      notifier.setTheme(k);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeGroup extends StatelessWidget {
  final String label;
  final List<String> keys;
  final String current;
  final Color accent;
  final ValueChanged<String> onSelect;

  const _ThemeGroup({
    required this.label,
    required this.keys,
    required this.current,
    required this.accent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final key in keys)
          _ThemeRow(
            themeKey: key,
            isSelected: key == current,
            accent: accent,
            onTap: () => onSelect(key),
          ),
      ],
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final String themeKey;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.themeKey,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = ThemeCatalog.byKey(themeKey);
    final swatches = [
      palette.terminal.black,
      palette.terminal.red,
      palette.terminal.green,
      palette.terminal.yellow,
      palette.terminal.blue,
    ];
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ThemeCatalog.displayName(themeKey),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            for (final swatch in swatches)
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.check,
              size: 18,
              color: isSelected ? accent : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Cursor style picker dialog ----------

class _CursorStylePickerDialog extends StatefulWidget {
  final String current;
  final SettingsNotifier notifier;
  const _CursorStylePickerDialog({required this.current, required this.notifier});

  @override
  State<_CursorStylePickerDialog> createState() => _CursorStylePickerDialogState();
}

class _CursorStylePickerDialogState extends State<_CursorStylePickerDialog> {
  late String _selected;
  static const _styles = ['block', 'underline', 'bar'];

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String labelFor(String style) => switch (style) {
      'block' => l.settings_cursorBlock,
      'underline' => l.settings_cursorUnderline,
      'bar' => l.settings_cursorBar,
      _ => style,
    };
    return SimpleDialog(
      title: Text(l.settings_selectCursorStyle),
      children: [
        RadioGroup<String>(
          groupValue: _selected,
          onChanged: (v) {
            if (v != null) {
              widget.notifier.set(SettingsKeys.cursorStyle, v);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: _styles.map((style) {
              return RadioListTile<String>(
                title: Text(labelFor(style)),
                value: style,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------- Font family picker dialog ----------

class _FontFamilyPickerDialog extends ConsumerWidget {
  final WidgetRef ref;
  const _FontFamilyPickerDialog({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final current = ref.watch(terminalFontFamilyProvider);
    return SimpleDialog(
      title: Text(l.settings_selectFontFamily),
      children: [
        RadioGroup<String>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) {
              ref.read(terminalFontFamilyProvider.notifier).setFamily(v);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: terminalFontFamilies.map((family) {
              return RadioListTile<String>(
                title: Text(family, style: TextStyle(fontFamily: family)),
                value: family,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------- Scrollback lines input dialog ----------

class _ScrollbackInputDialog extends StatefulWidget {
  final int current;
  final void Function(int) onConfirm;
  const _ScrollbackInputDialog({required this.current, required this.onConfirm});

  @override
  State<_ScrollbackInputDialog> createState() => _ScrollbackInputDialogState();
}

class _ScrollbackInputDialogState extends State<_ScrollbackInputDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.settings_selectScrollbackLines),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l.settings_scrollbackLines,
          suffixText: l.settings_scrollbackLinesSuffix,
          errorText: _error,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.common_cancel),
        ),
        FilledButton(
          onPressed: () {
            final value = int.tryParse(_controller.text.trim());
            if (value == null || value < 100 || value > 1000000) {
              setState(() => _error = '100 ~ 1,000,000');
              return;
            }
            widget.onConfirm(value);
            Navigator.of(context).pop();
          },
          child: Text(l.common_confirm),
        ),
      ],
    );
  }
}

// ---------- Auto-lock picker dialog ----------

class _AutoLockPickerDialog extends StatefulWidget {
  final String current;
  final SettingsNotifier notifier;
  const _AutoLockPickerDialog({required this.current, required this.notifier});

  @override
  State<_AutoLockPickerDialog> createState() => _AutoLockPickerDialogState();
}

class _AutoLockPickerDialogState extends State<_AutoLockPickerDialog> {
  late String _selected;
  static const _options = ['0', '1', '5', '10', '30'];

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String labelFor(String minutes) {
      final m = int.tryParse(minutes);
      if (m == null || m <= 0) return l.settings_autoLockNever;
      if (m == 1) return l.settings_autoLockOneMinute;
      return l.settings_autoLockMinutes(m);
    }
    return SimpleDialog(
      title: Text(l.settings_selectAutoLock),
      children: [
        RadioGroup<String>(
          groupValue: _selected,
          onChanged: (v) {
            if (v != null) {
              widget.notifier.set(SettingsKeys.autoLockMinutes, v);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: _options.map((minutes) {
              return RadioListTile<String>(
                title: Text(labelFor(minutes)),
                value: minutes,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------- Voice locale picker dialog ----------

class _VoiceLocalePickerDialog extends ConsumerWidget {
  const _VoiceLocalePickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final current = settings[SettingsKeys.voiceInputLocale] ?? '';
    final asyncLocales = ref.watch(availableSpeechLocalesProvider);

    return SimpleDialog(
      title: Text(l.settings_selectVoiceLocale),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: asyncLocales.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _buildList(context, current, const [], notifier, l),
            data: (locales) => _buildList(context, current, locales, notifier, l),
          ),
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    String current,
    List<dynamic> locales,
    SettingsNotifier notifier,
    AppLocalizations l,
  ) {
    return SingleChildScrollView(
      child: RadioGroup<String>(
        groupValue: current,
        onChanged: (v) {
          if (v != null) {
            notifier.set(SettingsKeys.voiceInputLocale, v);
            Navigator.of(context).pop();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l.settings_voiceLocaleSystem),
              value: '',
            ),
            for (final loc in locales)
              RadioListTile<String>(
                title: Text(loc.name),
                subtitle: Text(loc.localeId),
                value: loc.localeId as String,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------- Login dialog ----------

class _LoginDialog extends StatefulWidget {
  final WidgetRef ref;
  const _LoginDialog({required this.ref});

  @override
  State<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notifier = widget.ref.read(authProvider.notifier);
      if (_isRegister) {
        await notifier.register(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await notifier.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(_isRegister ? l.settings_registerTitle : l.settings_loginTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: InputDecoration(labelText: l.settings_emailLabel),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordCtrl,
            decoration: InputDecoration(labelText: l.settings_passwordLabel),
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _isRegister = !_isRegister),
          child: Text(_isRegister ? l.settings_switchToLogin : l.settings_switchToRegister),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.common_cancel)),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isRegister ? l.settings_registerButton : l.settings_loginButton),
        ),
      ],
    );
  }
}

class _NavTitle extends StatelessWidget {
  final String title;
  const _NavTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: [Theme.of(context).extension<ThemePalette>()!.accent, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}
