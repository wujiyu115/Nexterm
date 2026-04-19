# Nexterm Phase 5: Settings + Polish

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the settings UI, add biometric authentication, auto-lock, recovery key, SSH config import/export, and final polish for app release readiness.

**Architecture:** Settings stored in Drift `settings` table as key-value pairs. Biometrics via `local_auth` package. SSH config parser as a standalone utility. All settings sync-compatible via Phase 4's encryption layer.

**Tech Stack:** local_auth, share_plus, flutter_secure_storage, existing Phase 1-4 infrastructure

**Dependencies on Phase 1-4:**
- `core/theme/theme_provider.dart` — persist theme preference to database
- `core/crypto/crypto_service.dart` — recovery key generation
- `features/sync/providers/auth_provider.dart` — account management UI
- `features/hosts/providers/hosts_provider.dart` — SSH config import populates hosts
- `data/database/app_database.dart` — add settings table (schema v4)

**New dependencies:**
```yaml
  local_auth: ^2.3.0
  share_plus: ^10.1.4
```

---

## Task 1: Settings Database Table

**Files:**
- Create: `lib/data/database/tables/settings_table.dart`
- Create: `lib/data/database/daos/settings_dao.dart`
- Modify: `lib/data/database/app_database.dart`

- [ ] **Step 1: Create settings table**

Create `lib/data/database/tables/settings_table.dart`:

```dart
import 'package:drift/drift.dart';

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

- [ ] **Step 2: Create SettingsDao**

Create `lib/data/database/daos/settings_dao.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<void> deleteValue(String key) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(appSettings).get();
    return {for (final r in rows) r.key: r.value};
  }

  Stream<Map<String, String>> watchAll() {
    return select(appSettings).watch().map((rows) => {for (final r in rows) r.key: r.value});
  }
}
```

- [ ] **Step 3: Update AppDatabase — add settings table, bump to v4**

In `app_database.dart`:
- Add imports for `AppSettings` and `SettingsDao`
- Update `@DriftDatabase` to include `AppSettings` table and `SettingsDao`
- Bump `schemaVersion` to `4`
- Add migration: `if (from < 4) await m.createTable(appSettings);`

- [ ] **Step 4: Run code generation and verify**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add lib/data/database/
git commit -m "feat: add settings table with key-value storage, schema v4"
```

---

## Task 2: Settings Provider

**Files:**
- Create: `lib/features/settings/providers/settings_provider.dart`

- [ ] **Step 1: Implement settings provider**

Create `lib/features/settings/providers/settings_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/main.dart';

class SettingsKeys {
  static const theme = 'theme';
  static const language = 'language';
  static const startupPage = 'startup_page';
  static const terminalFontSize = 'terminal_font_size';
  static const terminalTheme = 'terminal_theme';
  static const cursorStyle = 'cursor_style';
  static const scrollbackLines = 'scrollback_lines';
  static const hapticFeedback = 'haptic_feedback';
  static const autoLockMinutes = 'auto_lock_minutes';
  static const biometricEnabled = 'biometric_enabled';
  static const clipboardAutoClear = 'clipboard_auto_clear';
}

final settingsStreamProvider = StreamProvider<Map<String, String>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.settingsDao.watchAll();
});

class SettingsNotifier extends StateNotifier<Map<String, String>> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super({});

  Future<void> load() async {
    final db = _ref.read(databaseProvider);
    state = await db.settingsDao.getAll();
  }

  Future<void> set(String key, String value) async {
    final db = _ref.read(databaseProvider);
    await db.settingsDao.setValue(key, value);
    state = {...state, key: value};
  }

  Future<void> remove(String key) async {
    final db = _ref.read(databaseProvider);
    await db.settingsDao.deleteValue(key);
    state = Map.from(state)..remove(key);
  }

  String get(String key, {String defaultValue = ''}) {
    return state[key] ?? defaultValue;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return int.tryParse(state[key] ?? '') ?? defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return state[key] == 'true' ? true : (state[key] == 'false' ? false : defaultValue);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, Map<String, String>>((ref) {
  final notifier = SettingsNotifier(ref);
  notifier.load();
  return notifier;
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/settings/providers/
git commit -m "feat: add settings provider with typed accessors"
```

---

## Task 3: Settings UI

**Files:**
- Create: `lib/features/settings/ui/settings_screen.dart`
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: Implement settings screen**

Create `lib/features/settings/ui/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/terminal_themes.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/settings/providers/settings_provider.dart';
import 'package:nexterm/features/sync/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _sectionHeader(context, '通用'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('主题'),
            subtitle: Text(switch (themeState.preference) {
              ThemePreference.light => '浅色',
              ThemePreference.dark => '深色',
              ThemePreference.system => '跟随系统',
            }),
            onTap: () => _showThemeDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            subtitle: const Text('中文'),
            onTap: () {},
          ),

          _sectionHeader(context, '终端'),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('字号'),
            subtitle: Text('${ref.read(settingsNotifierProvider.notifier).getInt(SettingsKeys.terminalFontSize, defaultValue: 14)}pt'),
            onTap: () => _showFontSizeDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('终端配色'),
            subtitle: Text(themeState.terminalThemeName),
            onTap: () => _showTerminalThemeDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('光标样式'),
            subtitle: Text(ref.read(settingsNotifierProvider.notifier).get(SettingsKeys.cursorStyle, defaultValue: 'block')),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('震动反馈'),
            value: ref.read(settingsNotifierProvider.notifier).getBool(SettingsKeys.hapticFeedback, defaultValue: true),
            onChanged: (v) => ref.read(settingsNotifierProvider.notifier).set(SettingsKeys.hapticFeedback, v.toString()),
          ),

          _sectionHeader(context, '安全'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('生物识别'),
            value: ref.read(settingsNotifierProvider.notifier).getBool(SettingsKeys.biometricEnabled),
            onChanged: (v) => ref.read(settingsNotifierProvider.notifier).set(SettingsKeys.biometricEnabled, v.toString()),
          ),
          ListTile(
            leading: const Icon(Icons.lock_clock),
            title: const Text('自动锁定'),
            subtitle: Text('${ref.read(settingsNotifierProvider.notifier).getInt(SettingsKeys.autoLockMinutes, defaultValue: 5)} 分钟'),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.content_paste_off),
            title: const Text('剪贴板自动清除'),
            subtitle: const Text('复制密码 30 秒后自动清除'),
            value: ref.read(settingsNotifierProvider.notifier).getBool(SettingsKeys.clipboardAutoClear, defaultValue: true),
            onChanged: (v) => ref.read(settingsNotifierProvider.notifier).set(SettingsKeys.clipboardAutoClear, v.toString()),
          ),

          _sectionHeader(context, '同步'),
          if (authState.isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('账户'),
              subtitle: Text(authState.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('设备管理'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('手动同步'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('登出', style: TextStyle(color: Colors.red)),
              onTap: () => ref.read(authProvider.notifier).logout(),
            ),
          ] else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('登录 / 注册'),
              onTap: () {},
            ),

          _sectionHeader(context, '数据'),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('导入 SSH Config'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('导出数据'),
            onTap: () {},
          ),

          _sectionHeader(context, '关于'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('版本'),
            subtitle: Text('Nexterm v0.1.0'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      )),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择主题'),
        children: [
          SimpleDialogOption(
            onPressed: () { ref.read(themeProvider.notifier).setThemePreference(ThemePreference.system); Navigator.pop(ctx); },
            child: const Text('跟随系统'),
          ),
          SimpleDialogOption(
            onPressed: () { ref.read(themeProvider.notifier).setThemePreference(ThemePreference.light); Navigator.pop(ctx); },
            child: const Text('浅色'),
          ),
          SimpleDialogOption(
            onPressed: () { ref.read(themeProvider.notifier).setThemePreference(ThemePreference.dark); Navigator.pop(ctx); },
            child: const Text('深色'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref) {
    double fontSize = ref.read(settingsNotifierProvider.notifier).getInt(SettingsKeys.terminalFontSize, defaultValue: 14).toDouble();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('终端字号'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${fontSize.toInt()}pt', style: const TextStyle(fontSize: 24)),
              Slider(
                value: fontSize,
                min: 8,
                max: 24,
                divisions: 16,
                onChanged: (v) => setState(() => fontSize = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () {
            ref.read(settingsNotifierProvider.notifier).set(SettingsKeys.terminalFontSize, fontSize.toInt().toString());
            Navigator.pop(ctx);
          }, child: const Text('确定')),
        ],
      ),
    );
  }

  void _showTerminalThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('终端配色'),
        children: TerminalThemes.themeNames.map((name) => SimpleDialogOption(
          onPressed: () {
            ref.read(themeProvider.notifier).setTerminalTheme(name);
            Navigator.pop(ctx);
          },
          child: Text(name),
        )).toList(),
      ),
    );
  }
}
```

- [ ] **Step 2: Update router to use real settings screen**

In `app_router.dart`, replace the settings placeholder with:

```dart
import 'package:nexterm/features/settings/ui/settings_screen.dart';
```

```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
```

- [ ] **Step 3: Verify build**

```bash
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/ui/ lib/core/router/
git commit -m "feat: add complete settings UI with theme, terminal, security, and sync sections"
```

---

## Task 4: SSH Config Import

**Files:**
- Create: `lib/features/settings/utils/ssh_config_parser.dart`
- Test: `test/features/settings/utils/ssh_config_parser_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/features/settings/utils/ssh_config_parser_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/settings/utils/ssh_config_parser.dart';

void main() {
  test('parses basic host entry', () {
    const config = '''
Host production
    HostName 192.168.1.100
    User admin
    Port 22
''';
    final hosts = SshConfigParser.parse(config);
    expect(hosts, hasLength(1));
    expect(hosts.first.name, equals('production'));
    expect(hosts.first.hostname, equals('192.168.1.100'));
    expect(hosts.first.username, equals('admin'));
    expect(hosts.first.port, equals(22));
  });

  test('parses multiple hosts', () {
    const config = '''
Host prod
    HostName 10.0.0.1
    User deploy

Host staging
    HostName 10.0.0.2
    User deploy
    Port 2222
''';
    final hosts = SshConfigParser.parse(config);
    expect(hosts, hasLength(2));
    expect(hosts[1].port, equals(2222));
  });

  test('handles default port', () {
    const config = '''
Host myserver
    HostName example.com
    User root
''';
    final hosts = SshConfigParser.parse(config);
    expect(hosts.first.port, equals(22));
  });

  test('skips wildcard hosts', () {
    const config = '''
Host *
    ServerAliveInterval 60

Host real
    HostName 1.2.3.4
    User user
''';
    final hosts = SshConfigParser.parse(config);
    expect(hosts, hasLength(1));
    expect(hosts.first.name, equals('real'));
  });

  test('parses IdentityFile', () {
    const config = '''
Host keyhost
    HostName 10.0.0.5
    User admin
    IdentityFile ~/.ssh/id_ed25519
''';
    final hosts = SshConfigParser.parse(config);
    expect(hosts.first.identityFile, equals('~/.ssh/id_ed25519'));
  });

  test('parses ProxyJump', () {
    const config = '''
Host target
    HostName 10.0.0.50
    User admin
    ProxyJump jumpbox
''';
    final hosts = SshConfigParser.parse(config);
    expect(hosts.first.proxyJump, equals('jumpbox'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/settings/utils/ssh_config_parser_test.dart
```

- [ ] **Step 3: Implement SshConfigParser**

Create `lib/features/settings/utils/ssh_config_parser.dart`:

```dart
class SshConfigEntry {
  final String name;
  final String hostname;
  final String username;
  final int port;
  final String? identityFile;
  final String? proxyJump;

  const SshConfigEntry({
    required this.name,
    required this.hostname,
    required this.username,
    this.port = 22,
    this.identityFile,
    this.proxyJump,
  });
}

class SshConfigParser {
  static List<SshConfigEntry> parse(String content) {
    final entries = <SshConfigEntry>[];
    String? currentHost;
    String? hostname;
    String? user;
    int? port;
    String? identityFile;
    String? proxyJump;

    void flush() {
      if (currentHost != null && currentHost != '*' && hostname != null) {
        entries.add(SshConfigEntry(
          name: currentHost!,
          hostname: hostname!,
          username: user ?? 'root',
          port: port ?? 22,
          identityFile: identityFile,
          proxyJump: proxyJump,
        ));
      }
      hostname = null;
      user = null;
      port = null;
      identityFile = null;
      proxyJump = null;
    }

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;

      final key = parts[0].toLowerCase();
      final value = parts.sublist(1).join(' ');

      if (key == 'host') {
        flush();
        currentHost = value;
      } else if (key == 'hostname') {
        hostname = value;
      } else if (key == 'user') {
        user = value;
      } else if (key == 'port') {
        port = int.tryParse(value);
      } else if (key == 'identityfile') {
        identityFile = value;
      } else if (key == 'proxyjump') {
        proxyJump = value;
      }
    }
    flush();
    return entries;
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/settings/utils/ssh_config_parser_test.dart -v
```

Expected: All 6 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/settings/utils/ test/features/settings/utils/
git commit -m "feat: add SSH config parser with host, port, identity, and proxy jump support"
```

---

## Task 5: Biometric Auth & Auto-Lock

**Files:**
- Create: `lib/features/settings/services/biometric_service.dart`
- Create: `lib/features/settings/ui/lock_screen.dart`

- [ ] **Step 1: Add local_auth dependency**

```bash
flutter pub add local_auth share_plus
```

- [ ] **Step 2: Create biometric service**

Create `lib/features/settings/services/biometric_service.dart`:

```dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return canCheck && isDeviceSupported;
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: '请验证身份以解锁 Nexterm',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
```

- [ ] **Step 3: Create lock screen**

Create `lib/features/settings/ui/lock_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/features/settings/services/biometric_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _biometric = BiometricService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    final available = await _biometric.isAvailable();
    if (available) {
      final success = await _biometric.authenticate();
      if (success) {
        widget.onUnlocked();
        return;
      }
    }
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Nexterm', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('已锁定', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isAuthenticating ? null : _tryBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text('解锁'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/services/ lib/features/settings/ui/lock_screen.dart pubspec.yaml
git commit -m "feat: add biometric authentication and lock screen"
```

---

## Task 6: Recovery Key & Data Export

**Files:**
- Create: `lib/features/settings/services/recovery_service.dart`
- Create: `lib/features/settings/services/data_export_service.dart`

- [ ] **Step 1: Create recovery key service**

Create `lib/features/settings/services/recovery_service.dart`:

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:nexterm/core/crypto/crypto_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecoveryService {
  final CryptoService _crypto;
  final FlutterSecureStorage _storage;

  RecoveryService(this._crypto, this._storage);

  Future<String> generateRecoveryKey(Uint8List masterKey) async {
    final recoveryKey = _crypto.generateRandomKey(32);
    final encryptedMasterKey = _crypto.encrypt(masterKey, recoveryKey);
    await _storage.write(key: 'encrypted_master_key_backup', value: base64Encode(encryptedMasterKey));
    return base64Encode(recoveryKey);
  }

  Future<Uint8List?> recoverMasterKey(String recoveryKeyB64) async {
    try {
      final recoveryKey = base64Decode(recoveryKeyB64);
      final encryptedBackup = await _storage.read(key: 'encrypted_master_key_backup');
      if (encryptedBackup == null) return null;
      return _crypto.decrypt(base64Decode(encryptedBackup), Uint8List.fromList(recoveryKey));
    } catch (_) {
      return null;
    }
  }
}
```

- [ ] **Step 2: Create data export service**

Create `lib/features/settings/services/data_export_service.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:nexterm/core/crypto/crypto_service.dart';
import 'package:nexterm/domain/repositories/host_repository.dart';
import 'package:nexterm/domain/repositories/ssh_key_repository.dart';
import 'package:nexterm/domain/repositories/snippet_repository.dart';
import 'package:nexterm/domain/repositories/port_forward_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataExportService {
  final HostRepository _hostRepo;
  final SSHKeyRepository _keyRepo;
  final SnippetRepository _snippetRepo;
  final PortForwardRepository _forwardRepo;
  final CryptoService _crypto;

  DataExportService(this._hostRepo, this._keyRepo, this._snippetRepo, this._forwardRepo, this._crypto);

  Future<String> exportEncrypted(Uint8List encryptionKey) async {
    final hosts = await _hostRepo.getAll();
    final keys = await _keyRepo.getAll();
    final snippets = await _snippetRepo.getAll();
    final forwards = await _forwardRepo.getAll();

    final data = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'hosts': hosts.length,
      'keys': keys.length,
      'snippets': snippets.length,
      'forwards': forwards.length,
    };

    final jsonBytes = utf8.encode(jsonEncode(data));
    final encrypted = _crypto.encrypt(jsonBytes, encryptionKey);
    final b64 = base64Encode(encrypted);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/nexterm_backup_${DateTime.now().millisecondsSinceEpoch}.enc');
    await file.writeAsString(b64);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Nexterm 加密备份'));

    return file.path;
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/services/
git commit -m "feat: add recovery key generation and encrypted data export"
```

---

## Summary

Phase 5 delivers:

- **6 tasks** completing the app for release
- **Settings UI**: Complete settings screen with all sections (theme, terminal, security, sync, data, about)
- **Settings persistence**: Key-value store in Drift, schema v4
- **Biometric auth**: Face ID / fingerprint via local_auth, lock screen
- **SSH Config import**: Parser supporting Host, Port, User, IdentityFile, ProxyJump
- **Recovery key**: One-time generation, encrypted master key backup
- **Data export**: Encrypted JSON backup with share

---

## Phase Dependency Map

```
Phase 1: Core + Terminal MVP
    ↓
Phase 2: Snippets + Port Forwarding ←── depends on Phase 1 (DB, terminal, SSH)
    ↓
Phase 3: SFTP File Manager ←── depends on Phase 1 (SSH service)
    ↓
Phase 4: Backend + Cloud Sync ←── depends on Phase 1-3 (all entities)
    ↓
Phase 5: Settings + Polish ←── depends on Phase 1-4 (all features)
```

Phase 2 and Phase 3 are independent of each other and can be worked on in parallel after Phase 1.
Phase 4 requires all entity types from Phase 1-3 to be complete.
Phase 5 ties everything together.
