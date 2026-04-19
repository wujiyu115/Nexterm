import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/terminal_themes.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/sync/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // 通用
          _SectionHeader(title: '通用'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('外观主题'),
            subtitle: Text(_themePreferenceLabel(themeState.preference)),
            onTap: () => _showThemePicker(context, themeState.preference, themeNotifier),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('语言'),
            subtitle: const Text('中文'),
            onTap: () {},
          ),

          // 终端
          _SectionHeader(title: '终端'),
          _FontSizeTile(
            fontSize: double.tryParse(
                  settings[SettingsKeys.terminalFontSize] ?? '',
                ) ??
                14.0,
            onChanged: (v) => settingsNotifier.set(SettingsKeys.terminalFontSize, v.round().toString()),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('终端配色方案'),
            subtitle: Text(_terminalThemeLabel(themeState.terminalThemeName)),
            onTap: () => _showTerminalThemePicker(context, themeState.terminalThemeName, themeNotifier),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields_outlined),
            title: const Text('光标样式'),
            subtitle: Text(_cursorStyleLabel(settings[SettingsKeys.cursorStyle] ?? 'block')),
            onTap: () => _showCursorStylePicker(context, settings[SettingsKeys.cursorStyle] ?? 'block', settingsNotifier),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_outlined),
            title: const Text('触觉反馈'),
            value: settings[SettingsKeys.hapticFeedback] == 'true',
            onChanged: (v) => settingsNotifier.set(SettingsKeys.hapticFeedback, v.toString()),
          ),

          // 安全
          _SectionHeader(title: '安全'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint_outlined),
            title: const Text('生物识别解锁'),
            value: settings[SettingsKeys.biometricEnabled] == 'true',
            onChanged: (v) => settingsNotifier.set(SettingsKeys.biometricEnabled, v.toString()),
          ),
          ListTile(
            leading: const Icon(Icons.lock_clock_outlined),
            title: const Text('自动锁定时间'),
            subtitle: Text(_autoLockLabel(settings[SettingsKeys.autoLockMinutes] ?? '5')),
            onTap: () => _showAutoLockPicker(context, settings[SettingsKeys.autoLockMinutes] ?? '5', settingsNotifier),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.content_paste_off_outlined),
            title: const Text('剪贴板自动清除'),
            subtitle: const Text('退出应用后自动清除剪贴板'),
            value: settings[SettingsKeys.clipboardAutoClear] == 'true',
            onChanged: (v) => settingsNotifier.set(SettingsKeys.clipboardAutoClear, v.toString()),
          ),

          // 同步
          _SectionHeader(title: '同步'),
          if (authState.isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('账户'),
              subtitle: Text(authState.email ?? '已登录'),
            ),
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: const Text('设备管理'),
              onTap: () => _showDeviceManagementDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.sync_outlined),
              title: const Text('立即同步'),
              onTap: () => _triggerManualSync(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('退出登录'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => _confirmLogout(context, ref),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.login_outlined),
              title: const Text('登录 / 注册'),
              subtitle: const Text('登录以同步您的数据'),
              onTap: () => _showLoginDialog(context, ref),
            ),
          ],

          // 数据
          _SectionHeader(title: '数据'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('导入 SSH 配置'),
            subtitle: const Text('从 ~/.ssh/config 文件导入'),
            onTap: () => _showImportDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('导出数据'),
            subtitle: const Text('将所有数据导出为 JSON 文件'),
            onTap: () => _showExportDialog(context),
          ),

          // 关于
          _SectionHeader(title: '关于'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('版本'),
            subtitle: Text('v0.1.0'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ---------- label helpers ----------

  static String _themePreferenceLabel(ThemePreference pref) => switch (pref) {
        ThemePreference.light => '浅色',
        ThemePreference.dark => '深色',
        ThemePreference.system => '跟随系统',
      };

  static String _terminalThemeLabel(String name) => switch (name) {
        'catppuccin' => 'Catppuccin Mocha',
        'dracula' => 'Dracula',
        'monokai' => 'Monokai',
        'solarized-dark' => 'Solarized Dark',
        'solarized-light' => 'Solarized Light',
        _ => name,
      };

  static String _cursorStyleLabel(String style) => switch (style) {
        'block' => '块状',
        'underline' => '下划线',
        'bar' => '竖线',
        _ => style,
      };

  static String _autoLockLabel(String minutes) {
    final m = int.tryParse(minutes);
    if (m == null || m <= 0) return '从不';
    if (m == 1) return '1 分钟';
    return '$m 分钟';
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设备管理'),
        content: const Text('设备管理功能即将推出。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('确定')),
        ],
      ),
    );
  }

  void _triggerManualSync(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在同步...')),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('退出'),
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

  void _showImportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入 SSH 配置'),
        content: const Text('请选择 SSH 配置文件（~/.ssh/config）进行导入。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('选择文件')),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text('将所有主机、密钥和片段数据导出为 JSON 文件。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已导出')),
              );
            },
            child: const Text('导出'),
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
    return ListTile(
      leading: const Icon(Icons.format_size_outlined),
      title: const Text('字体大小'),
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

  static String _label(ThemePreference pref) => switch (pref) {
        ThemePreference.light => '浅色',
        ThemePreference.dark => '深色',
        ThemePreference.system => '跟随系统',
      };

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('选择主题'),
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
                title: Text(_label(pref)),
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
    return SimpleDialog(
      title: const Text('选择终端配色'),
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

  static String _label(String style) => switch (style) {
        'block' => '块状',
        'underline' => '下划线',
        'bar' => '竖线',
        _ => style,
      };

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('选择光标样式'),
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
                title: Text(_label(style)),
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

  static String _label(String minutes) {
    final m = int.tryParse(minutes);
    if (m == null || m <= 0) return '从不';
    if (m == 1) return '1 分钟';
    return '$m 分钟';
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('自动锁定时间'),
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
                title: Text(_label(minutes)),
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
    return AlertDialog(
      title: Text(_isRegister ? '注册账户' : '登录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: '邮箱'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: '密码'),
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
          child: Text(_isRegister ? '已有账户？登录' : '没有账户？注册'),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isRegister ? '注册' : '登录'),
        ),
      ],
    );
  }
}
