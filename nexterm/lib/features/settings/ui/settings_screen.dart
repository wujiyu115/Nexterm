import 'package:flutter/material.dart';
import 'package:nexterm/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/locale/locale_provider.dart';
import 'package:nexterm/core/theme/terminal_themes.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/settings/utils/ssh_config_parser.dart';
import 'package:nexterm/features/sync/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings_title)),
      body: ListView(
        children: [
          _SectionHeader(title: l.settings_sectionGeneral),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l.settings_theme),
            subtitle: Text(_themePreferenceLabel(themeState.preference, l)),
            onTap: () => _showThemePicker(context, themeState.preference, themeNotifier),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l.settings_language),
            subtitle: Text(_languageLabel(ref, l)),
            onTap: () => _showLanguagePicker(context, ref),
          ),

          _SectionHeader(title: l.settings_sectionTerminal),
          _FontSizeTile(
            fontSize: double.tryParse(
                  settings[SettingsKeys.terminalFontSize] ?? '',
                ) ??
                14.0,
            onChanged: (v) => settingsNotifier.set(SettingsKeys.terminalFontSize, v.round().toString()),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(l.settings_terminalTheme),
            subtitle: Text(_terminalThemeLabel(themeState.terminalThemeName)),
            onTap: () => _showTerminalThemePicker(context, themeState.terminalThemeName, themeNotifier),
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

          _SectionHeader(title: l.settings_sectionSecurity),
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

          _SectionHeader(title: l.settings_sectionSync),
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

          _SectionHeader(title: l.settings_sectionData),
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

          _SectionHeader(title: l.settings_sectionAbout),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.settings_version),
            subtitle: const Text('v0.1.0'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------- label helpers ----------

  static String _themePreferenceLabel(ThemePreference pref, AppLocalizations l) => switch (pref) {
        ThemePreference.light => l.settings_themeLight,
        ThemePreference.dark => l.settings_themeDark,
        ThemePreference.system => l.settings_themeSystem,
      };

  static String _terminalThemeLabel(String name) => switch (name) {
        'catppuccin' => 'Catppuccin Mocha',
        'dracula' => 'Dracula',
        'monokai' => 'Monokai',
        'solarized-dark' => 'Solarized Dark',
        'solarized-light' => 'Solarized Light',
        _ => name,
      };

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

  static String _languageLabel(WidgetRef ref, AppLocalizations l) {
    final locale = ref.watch(localeProvider);
    if (locale == null) return l.settings_languageSystem;
    if (locale.languageCode == 'zh') return l.settings_languageChinese;
    if (locale.languageCode == 'en') return l.settings_languageEnglish;
    return l.settings_languageSystem;
  }

  // ---------- pickers / dialogs ----------

  void _showThemePicker(BuildContext context, ThemePreference current, ThemeNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _ThemePickerDialog(current: current, notifier: notifier),
    );
  }

  void _showTerminalThemePicker(BuildContext context, String current, ThemeNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _TerminalThemePickerDialog(current: current, notifier: notifier),
    );
  }

  void _showCursorStylePicker(BuildContext context, String current, SettingsNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CursorStylePickerDialog(current: current, notifier: notifier),
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

// ---------- Section header ----------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
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

// ---------- Theme picker dialog ----------

class _ThemePickerDialog extends StatefulWidget {
  final ThemePreference current;
  final ThemeNotifier notifier;
  const _ThemePickerDialog({required this.current, required this.notifier});

  @override
  State<_ThemePickerDialog> createState() => _ThemePickerDialogState();
}

class _ThemePickerDialogState extends State<_ThemePickerDialog> {
  late ThemePreference _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String labelFor(ThemePreference pref) => switch (pref) {
      ThemePreference.light => l.settings_themeLight,
      ThemePreference.dark => l.settings_themeDark,
      ThemePreference.system => l.settings_themeSystem,
    };
    return SimpleDialog(
      title: Text(l.settings_selectTheme),
      children: [
        RadioGroup<ThemePreference>(
          groupValue: _selected,
          onChanged: (v) {
            if (v != null) {
              widget.notifier.setThemePreference(v);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: ThemePreference.values.map((pref) {
              return RadioListTile<ThemePreference>(
                title: Text(labelFor(pref)),
                value: pref,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------- Terminal theme picker dialog ----------

class _TerminalThemePickerDialog extends StatefulWidget {
  final String current;
  final ThemeNotifier notifier;
  const _TerminalThemePickerDialog({required this.current, required this.notifier});

  @override
  State<_TerminalThemePickerDialog> createState() => _TerminalThemePickerDialogState();
}

class _TerminalThemePickerDialogState extends State<_TerminalThemePickerDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  static String _label(String name) => switch (name) {
        'catppuccin' => 'Catppuccin Mocha',
        'dracula' => 'Dracula',
        'monokai' => 'Monokai',
        'solarized-dark' => 'Solarized Dark',
        'solarized-light' => 'Solarized Light',
        _ => name,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SimpleDialog(
      title: Text(l.settings_selectTerminalTheme),
      children: [
        RadioGroup<String>(
          groupValue: _selected,
          onChanged: (v) {
            if (v != null) {
              widget.notifier.setTerminalTheme(v);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: TerminalThemes.all.keys.map((name) {
              return RadioListTile<String>(
                title: Text(_label(name)),
                value: name,
              );
            }).toList(),
          ),
        ),
      ],
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
