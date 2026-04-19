# Nexterm Phase 1: Core Foundation + Terminal MVP

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a working SSH terminal client with host management, key management, multi-tab terminal, and mobile keyboard enhancements.

**Architecture:** Flutter app using clean architecture with Riverpod for state management. SSH via dartssh2, terminal rendering via xterm.dart, local persistence via Drift (SQLite). Domain entities are pure Dart; data layer handles DB and encryption; features layer contains UI + state per module.

**Tech Stack:** Flutter, Dart, dartssh2, xterm.dart, Riverpod, GoRouter, Drift, flutter_secure_storage, pointycastle, connectivity_plus

**Phase Roadmap:**
- **Phase 1 (this plan):** Core + Terminal MVP
- **Phase 2:** Snippets + Port Forwarding
- **Phase 3:** SFTP File Manager
- **Phase 4:** Backend API + Cloud Sync
- **Phase 5:** Settings + Polish

---

## File Structure

```
nexterm/
├── lib/
│   ├── main.dart
│   ├── app.dart                              # MaterialApp + theme + router
│   ├── core/
│   │   ├── crypto/
│   │   │   └── crypto_service.dart           # AES-256-GCM encrypt/decrypt
│   │   ├── theme/
│   │   │   ├── app_theme.dart                # Light/dark ThemeData
│   │   │   ├── terminal_themes.dart          # Terminal color schemes
│   │   │   └── theme_provider.dart           # Riverpod theme state
│   │   └── router/
│   │       └── app_router.dart               # GoRouter configuration
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart             # Drift database class
│   │   │   ├── app_database.g.dart           # Generated
│   │   │   ├── tables/
│   │   │   │   ├── hosts_table.dart
│   │   │   │   └── ssh_keys_table.dart
│   │   │   └── daos/
│   │   │       ├── hosts_dao.dart
│   │   │       ├── hosts_dao.g.dart          # Generated
│   │   │       ├── ssh_keys_dao.dart
│   │   │       └── ssh_keys_dao.g.dart       # Generated
│   │   └── repositories/
│   │       ├── host_repository_impl.dart
│   │       └── ssh_key_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── host_entity.dart
│   │   │   ├── ssh_key_entity.dart
│   │   │   └── enums.dart
│   │   └── repositories/
│   │       ├── host_repository.dart
│   │       └── ssh_key_repository.dart
│   ├── features/
│   │   ├── hosts/
│   │   │   ├── providers/
│   │   │   │   └── hosts_provider.dart
│   │   │   └── ui/
│   │   │       ├── hosts_screen.dart
│   │   │       ├── host_form_screen.dart
│   │   │       └── widgets/
│   │   │           ├── host_list_tile.dart
│   │   │           └── host_search_bar.dart
│   │   ├── keys/
│   │   │   ├── providers/
│   │   │   │   └── keys_provider.dart
│   │   │   └── ui/
│   │   │       ├── keys_screen.dart
│   │   │       ├── key_generate_screen.dart
│   │   │       └── widgets/
│   │   │           └── key_list_tile.dart
│   │   └── terminal/
│   │       ├── providers/
│   │       │   └── terminal_provider.dart
│   │       ├── services/
│   │       │   ├── ssh_service.dart
│   │       │   └── reconnect_service.dart
│   │       └── ui/
│   │           ├── terminal_screen.dart
│   │           ├── widgets/
│   │           │   ├── terminal_tab_bar.dart
│   │           │   ├── keyboard_toolbar.dart
│   │           │   └── terminal_view.dart
│   │           └── tab_manager.dart
│   └── shared/
│       └── widgets/
│           ├── app_scaffold.dart
│           └── status_indicator.dart
├── test/
│   ├── core/
│   │   └── crypto/
│   │       └── crypto_service_test.dart
│   ├── data/
│   │   ├── database/
│   │   │   └── daos/
│   │   │       ├── hosts_dao_test.dart
│   │   │       └── ssh_keys_dao_test.dart
│   │   └── repositories/
│   │       ├── host_repository_impl_test.dart
│   │       └── ssh_key_repository_impl_test.dart
│   └── features/
│       ├── hosts/
│       │   └── providers/
│       │       └── hosts_provider_test.dart
│       ├── keys/
│       │   └── providers/
│       │       └── keys_provider_test.dart
│       └── terminal/
│           ├── services/
│           │   └── ssh_service_test.dart
│           └── tab_manager_test.dart
└── pubspec.yaml
```

---

## Task 1: Flutter Project Scaffolding

**Files:**
- Create: `nexterm/pubspec.yaml`
- Create: `nexterm/lib/main.dart`
- Create: `nexterm/analysis_options.yaml`

- [ ] **Step 1: Create Flutter project**

```bash
cd /home/admin/workspace/termius
flutter create --org com.nexterm --platforms=ios,android nexterm
```

- [ ] **Step 2: Replace pubspec.yaml with project dependencies**

Replace `nexterm/pubspec.yaml`:

```yaml
name: nexterm
description: A full-featured SSH terminal client
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.7.0
  flutter: ">=3.29.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Routing
  go_router: ^14.8.1

  # Database
  drift: ^2.23.1
  sqlite3_flutter_libs: ^0.5.28

  # SSH
  dartssh2: ^4.4.0

  # Terminal
  xterm: ^4.0.0

  # Network
  dio: ^5.7.0
  connectivity_plus: ^6.1.2

  # Security
  flutter_secure_storage: ^9.2.4
  pointycastle: ^3.9.1

  # Utils
  uuid: ^4.5.1
  path_provider: ^2.1.5
  path: ^1.9.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.14
  drift_dev: ^2.23.1
  riverpod_generator: ^2.6.3
  mockito: ^5.4.5
  build_verify: ^3.1.0

flutter:
  uses-material-design: true
  fonts:
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

- [ ] **Step 3: Install dependencies**

```bash
cd /home/admin/workspace/termius/nexterm
flutter pub get
```

- [ ] **Step 4: Create minimal main.dart**

Replace `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: NextermApp()));
}

class NextermApp extends StatelessWidget {
  const NextermApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexterm',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(child: Text('Nexterm')),
      ),
    );
  }
}
```

- [ ] **Step 5: Verify project builds**

```bash
cd /home/admin/workspace/termius/nexterm
flutter analyze
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add nexterm/
git commit -m "feat: scaffold Flutter project with dependencies"
```

---

## Task 2: Domain Entities & Enums

**Files:**
- Create: `lib/domain/entities/enums.dart`
- Create: `lib/domain/entities/host_entity.dart`
- Create: `lib/domain/entities/ssh_key_entity.dart`

- [ ] **Step 1: Create enums**

Create `lib/domain/entities/enums.dart`:

```dart
enum AuthMethod {
  password,
  key,
  keyboardInteractive;

  String get displayName => switch (this) {
    password => '密码认证',
    key => '密钥认证',
    keyboardInteractive => '键盘交互',
  };
}

enum KeyType {
  ed25519,
  rsa2048,
  rsa4096,
  ecdsa256,
  ecdsa384,
  ecdsa521;

  String get displayName => switch (this) {
    ed25519 => 'Ed25519',
    rsa2048 => 'RSA 2048',
    rsa4096 => 'RSA 4096',
    ecdsa256 => 'ECDSA 256',
    ecdsa384 => 'ECDSA 384',
    ecdsa521 => 'ECDSA 521',
  };
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error;
}

enum CursorStyle {
  block,
  underline,
  bar;
}
```

- [ ] **Step 2: Create HostEntity**

Create `lib/domain/entities/host_entity.dart`:

```dart
import 'package:nexterm/domain/entities/enums.dart';

class HostEntity {
  final String id;
  final String name;
  final String hostname;
  final int port;
  final String username;
  final AuthMethod authMethod;
  final String? password;
  final String? keyId;
  final String? group;
  final List<String> tags;
  final bool isFavorite;
  final List<String> jumpHosts;
  final String? startupSnippetId;
  final DateTime? lastConnected;
  final int sortOrder;

  const HostEntity({
    required this.id,
    required this.name,
    required this.hostname,
    this.port = 22,
    required this.username,
    required this.authMethod,
    this.password,
    this.keyId,
    this.group,
    this.tags = const [],
    this.isFavorite = false,
    this.jumpHosts = const [],
    this.startupSnippetId,
    this.lastConnected,
    this.sortOrder = 0,
  });

  HostEntity copyWith({
    String? id,
    String? name,
    String? hostname,
    int? port,
    String? username,
    AuthMethod? authMethod,
    String? Function()? password,
    String? Function()? keyId,
    String? Function()? group,
    List<String>? tags,
    bool? isFavorite,
    List<String>? jumpHosts,
    String? Function()? startupSnippetId,
    DateTime? Function()? lastConnected,
    int? sortOrder,
  }) {
    return HostEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      password: password != null ? password() : this.password,
      keyId: keyId != null ? keyId() : this.keyId,
      group: group != null ? group() : this.group,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      jumpHosts: jumpHosts ?? this.jumpHosts,
      startupSnippetId: startupSnippetId != null ? startupSnippetId() : this.startupSnippetId,
      lastConnected: lastConnected != null ? lastConnected() : this.lastConnected,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
```

- [ ] **Step 3: Create SSHKeyEntity**

Create `lib/domain/entities/ssh_key_entity.dart`:

```dart
import 'package:nexterm/domain/entities/enums.dart';

class SSHKeyEntity {
  final String id;
  final String name;
  final KeyType type;
  final String privateKey;
  final String publicKey;
  final String fingerprint;
  final String? passphrase;
  final DateTime createdAt;

  const SSHKeyEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.privateKey,
    required this.publicKey,
    required this.fingerprint,
    this.passphrase,
    required this.createdAt,
  });

  SSHKeyEntity copyWith({
    String? id,
    String? name,
    KeyType? type,
    String? privateKey,
    String? publicKey,
    String? fingerprint,
    String? Function()? passphrase,
    DateTime? createdAt,
  }) {
    return SSHKeyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      fingerprint: fingerprint ?? this.fingerprint,
      passphrase: passphrase != null ? passphrase() : this.passphrase,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

- [ ] **Step 4: Create repository interfaces**

Create `lib/domain/repositories/host_repository.dart`:

```dart
import 'package:nexterm/domain/entities/host_entity.dart';

abstract class HostRepository {
  Future<List<HostEntity>> getAll();
  Future<HostEntity?> getById(String id);
  Future<List<HostEntity>> getByGroup(String? group);
  Future<List<HostEntity>> getFavorites();
  Future<List<HostEntity>> search(String query);
  Future<void> insert(HostEntity host);
  Future<void> update(HostEntity host);
  Future<void> delete(String id);
  Future<void> deleteMultiple(List<String> ids);
  Stream<List<HostEntity>> watchAll();
}
```

Create `lib/domain/repositories/ssh_key_repository.dart`:

```dart
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

abstract class SSHKeyRepository {
  Future<List<SSHKeyEntity>> getAll();
  Future<SSHKeyEntity?> getById(String id);
  Future<void> insert(SSHKeyEntity key);
  Future<void> update(SSHKeyEntity key);
  Future<void> delete(String id);
  Stream<List<SSHKeyEntity>> watchAll();
}
```

- [ ] **Step 5: Verify compilation**

```bash
cd /home/admin/workspace/termius/nexterm
flutter analyze
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/domain/
git commit -m "feat: add domain entities and repository interfaces"
```

---

## Task 3: Drift Database Schema & DAOs

**Files:**
- Create: `lib/data/database/tables/hosts_table.dart`
- Create: `lib/data/database/tables/ssh_keys_table.dart`
- Create: `lib/data/database/daos/hosts_dao.dart`
- Create: `lib/data/database/daos/ssh_keys_dao.dart`
- Create: `lib/data/database/app_database.dart`

- [ ] **Step 1: Create hosts table**

Create `lib/data/database/tables/hosts_table.dart`:

```dart
import 'package:drift/drift.dart';

class Hosts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get hostname => text().withLength(min: 1, max: 255)();
  IntColumn get port => integer().withDefault(const Constant(22))();
  TextColumn get username => text().withLength(min: 1, max: 255)();
  TextColumn get authMethod => text()();
  TextColumn get password => text().nullable()();
  TextColumn get keyId => text().nullable()();
  TextColumn get group => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get jumpHosts => text().withDefault(const Constant('[]'))();
  TextColumn get startupSnippetId => text().nullable()();
  DateTimeColumn get lastConnected => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 2: Create ssh_keys table**

Create `lib/data/database/tables/ssh_keys_table.dart`:

```dart
import 'package:drift/drift.dart';

class SshKeys extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get type => text()();
  TextColumn get privateKey => text()();
  TextColumn get publicKey => text()();
  TextColumn get fingerprint => text()();
  TextColumn get passphrase => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 3: Create HostsDao**

Create `lib/data/database/daos/hosts_dao.dart`:

```dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/hosts_table.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';

part 'hosts_dao.g.dart';

@DriftAccessor(tables: [Hosts])
class HostsDao extends DatabaseAccessor<AppDatabase> with _$HostsDaoMixin {
  HostsDao(super.db);

  HostEntity _rowToEntity(Host row) {
    return HostEntity(
      id: row.id,
      name: row.name,
      hostname: row.hostname,
      port: row.port,
      username: row.username,
      authMethod: AuthMethod.values.byName(row.authMethod),
      password: row.password,
      keyId: row.keyId,
      group: row.group,
      tags: (jsonDecode(row.tags) as List).cast<String>(),
      isFavorite: row.isFavorite,
      jumpHosts: (jsonDecode(row.jumpHosts) as List).cast<String>(),
      startupSnippetId: row.startupSnippetId,
      lastConnected: row.lastConnected,
      sortOrder: row.sortOrder,
    );
  }

  HostsCompanion _entityToCompanion(HostEntity entity) {
    return HostsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      hostname: Value(entity.hostname),
      port: Value(entity.port),
      username: Value(entity.username),
      authMethod: Value(entity.authMethod.name),
      password: Value(entity.password),
      keyId: Value(entity.keyId),
      group: Value(entity.group),
      tags: Value(jsonEncode(entity.tags)),
      isFavorite: Value(entity.isFavorite),
      jumpHosts: Value(jsonEncode(entity.jumpHosts)),
      startupSnippetId: Value(entity.startupSnippetId),
      lastConnected: Value(entity.lastConnected),
      sortOrder: Value(entity.sortOrder),
      updatedAt: Value(DateTime.now()),
    );
  }

  Future<List<HostEntity>> getAll() async {
    final rows = await (select(hosts)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .get();
    return rows.map(_rowToEntity).toList();
  }

  Future<HostEntity?> getById(String id) async {
    final row = await (select(hosts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<List<HostEntity>> getByGroup(String? group) async {
    final query = select(hosts);
    if (group == null) {
      query.where((t) => t.group.isNull());
    } else {
      query.where((t) => t.group.equals(group));
    }
    final rows = await query.get();
    return rows.map(_rowToEntity).toList();
  }

  Future<List<HostEntity>> getFavorites() async {
    final rows = await (select(hosts)
      ..where((t) => t.isFavorite.equals(true)))
      .get();
    return rows.map(_rowToEntity).toList();
  }

  Future<List<HostEntity>> search(String query) async {
    final pattern = '%$query%';
    final rows = await (select(hosts)
      ..where((t) =>
          t.name.like(pattern) |
          t.hostname.like(pattern) |
          t.tags.like(pattern)))
      .get();
    return rows.map(_rowToEntity).toList();
  }

  Future<void> insertHost(HostEntity entity) {
    return into(hosts).insert(_entityToCompanion(entity));
  }

  Future<void> updateHost(HostEntity entity) {
    return (update(hosts)..where((t) => t.id.equals(entity.id)))
        .write(_entityToCompanion(entity));
  }

  Future<void> deleteHost(String id) {
    return (delete(hosts)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteMultiple(List<String> ids) {
    return (delete(hosts)..where((t) => t.id.isIn(ids))).go();
  }

  Stream<List<HostEntity>> watchAll() {
    return (select(hosts)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .watch()
      .map((rows) => rows.map(_rowToEntity).toList());
  }
}
```

- [ ] **Step 4: Create SshKeysDao**

Create `lib/data/database/daos/ssh_keys_dao.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/database/tables/ssh_keys_table.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

part 'ssh_keys_dao.g.dart';

@DriftAccessor(tables: [SshKeys])
class SshKeysDao extends DatabaseAccessor<AppDatabase> with _$SshKeysDaoMixin {
  SshKeysDao(super.db);

  SSHKeyEntity _rowToEntity(SshKey row) {
    return SSHKeyEntity(
      id: row.id,
      name: row.name,
      type: KeyType.values.byName(row.type),
      privateKey: row.privateKey,
      publicKey: row.publicKey,
      fingerprint: row.fingerprint,
      passphrase: row.passphrase,
      createdAt: row.createdAt,
    );
  }

  SshKeysCompanion _entityToCompanion(SSHKeyEntity entity) {
    return SshKeysCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.name),
      privateKey: Value(entity.privateKey),
      publicKey: Value(entity.publicKey),
      fingerprint: Value(entity.fingerprint),
      passphrase: Value(entity.passphrase),
      createdAt: Value(entity.createdAt),
    );
  }

  Future<List<SSHKeyEntity>> getAll() async {
    final rows = await select(sshKeys).get();
    return rows.map(_rowToEntity).toList();
  }

  Future<SSHKeyEntity?> getById(String id) async {
    final row = await (select(sshKeys)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _rowToEntity(row) : null;
  }

  Future<void> insertKey(SSHKeyEntity entity) {
    return into(sshKeys).insert(_entityToCompanion(entity));
  }

  Future<void> updateKey(SSHKeyEntity entity) {
    return (update(sshKeys)..where((t) => t.id.equals(entity.id)))
        .write(_entityToCompanion(entity));
  }

  Future<void> deleteKey(String id) {
    return (delete(sshKeys)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<SSHKeyEntity>> watchAll() {
    return select(sshKeys).watch()
        .map((rows) => rows.map(_rowToEntity).toList());
  }
}
```

- [ ] **Step 5: Create AppDatabase**

Create `lib/data/database/app_database.dart`:

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:nexterm/data/database/tables/hosts_table.dart';
import 'package:nexterm/data/database/tables/ssh_keys_table.dart';
import 'package:nexterm/data/database/daos/hosts_dao.dart';
import 'package:nexterm/data/database/daos/ssh_keys_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Hosts, SshKeys], daos: [HostsDao, SshKeysDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nexterm.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 6: Run code generation**

```bash
cd /home/admin/workspace/termius/nexterm
dart run build_runner build --delete-conflicting-outputs
```

Expected: Generated `.g.dart` files for database and DAOs.

- [ ] **Step 7: Verify compilation**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 8: Commit**

```bash
git add lib/data/
git commit -m "feat: add Drift database schema with hosts and ssh_keys tables"
```

---

## Task 4: Core Crypto Engine

**Files:**
- Create: `lib/core/crypto/crypto_service.dart`
- Test: `test/core/crypto/crypto_service_test.dart`

- [ ] **Step 1: Write failing test for encrypt/decrypt**

Create `test/core/crypto/crypto_service_test.dart`:

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/core/crypto/crypto_service.dart';

void main() {
  late CryptoService crypto;

  setUp(() {
    crypto = CryptoService();
  });

  group('AES-256-GCM', () {
    test('encrypts and decrypts string data', () {
      final key = crypto.generateRandomKey(32);
      const plaintext = 'Hello, Nexterm! 你好世界';

      final encrypted = crypto.encrypt(utf8.encode(plaintext), key);
      final decrypted = crypto.decrypt(encrypted, key);

      expect(utf8.decode(decrypted), equals(plaintext));
    });

    test('produces different ciphertext for same plaintext', () {
      final key = crypto.generateRandomKey(32);
      const plaintext = 'same data';
      final data = utf8.encode(plaintext);

      final encrypted1 = crypto.encrypt(data, key);
      final encrypted2 = crypto.encrypt(data, key);

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('fails to decrypt with wrong key', () {
      final key1 = crypto.generateRandomKey(32);
      final key2 = crypto.generateRandomKey(32);
      final encrypted = crypto.encrypt(utf8.encode('secret'), key1);

      expect(() => crypto.decrypt(encrypted, key2), throwsException);
    });

    test('fails to decrypt tampered ciphertext', () {
      final key = crypto.generateRandomKey(32);
      final encrypted = crypto.encrypt(utf8.encode('secret'), key);
      encrypted[encrypted.length - 1] ^= 0xFF;

      expect(() => crypto.decrypt(encrypted, key), throwsException);
    });
  });

  group('Key derivation', () {
    test('derives consistent key from same password and salt', () {
      const password = 'my-master-password';
      final salt = crypto.generateRandomKey(16);

      final key1 = crypto.deriveKey(password, salt);
      final key2 = crypto.deriveKey(password, salt);

      expect(key1, equals(key2));
    });

    test('derives different keys from different passwords', () {
      final salt = crypto.generateRandomKey(16);

      final key1 = crypto.deriveKey('password1', salt);
      final key2 = crypto.deriveKey('password2', salt);

      expect(key1, isNot(equals(key2)));
    });

    test('derived key is 32 bytes', () {
      final salt = crypto.generateRandomKey(16);
      final key = crypto.deriveKey('password', salt);

      expect(key.length, equals(32));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /home/admin/workspace/termius/nexterm
flutter test test/core/crypto/crypto_service_test.dart
```

Expected: FAIL — `crypto_service.dart` does not exist.

- [ ] **Step 3: Implement CryptoService**

Create `lib/core/crypto/crypto_service.dart`:

```dart
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class CryptoService {
  static const int _ivLength = 12;
  static const int _tagLength = 16;

  final SecureRandom _secureRandom;

  CryptoService() : _secureRandom = _createSecureRandom();

  static SecureRandom _createSecureRandom() {
    final random = FortunaRandom();
    final seed = Uint8List(32);
    final dartRandom = Random.secure();
    for (var i = 0; i < 32; i++) {
      seed[i] = dartRandom.nextInt(256);
    }
    random.seed(KeyParameter(seed));
    return random;
  }

  Uint8List generateRandomKey(int length) {
    return _secureRandom.nextBytes(length);
  }

  /// Encrypts data with AES-256-GCM. Returns IV + ciphertext + tag.
  Uint8List encrypt(List<int> plaintext, Uint8List key) {
    final iv = generateRandomKey(_ivLength);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(key),
          _tagLength * 8,
          iv,
          Uint8List(0),
        ),
      );

    final input = Uint8List.fromList(plaintext);
    final output = Uint8List(input.length + _tagLength);
    var offset = 0;
    offset += cipher.processBytes(input, 0, input.length, output, offset);
    cipher.doFinal(output, offset);

    // IV (12) + ciphertext + tag (16)
    return Uint8List.fromList([...iv, ...output]);
  }

  /// Decrypts AES-256-GCM data. Input format: IV + ciphertext + tag.
  Uint8List decrypt(Uint8List data, Uint8List key) {
    if (data.length < _ivLength + _tagLength) {
      throw ArgumentError('Data too short to contain IV and tag');
    }

    final iv = data.sublist(0, _ivLength);
    final ciphertextAndTag = data.sublist(_ivLength);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(key),
          _tagLength * 8,
          iv,
          Uint8List(0),
        ),
      );

    final output = Uint8List(ciphertextAndTag.length - _tagLength);
    var offset = 0;
    offset += cipher.processBytes(
        ciphertextAndTag, 0, ciphertextAndTag.length, output, offset);
    cipher.doFinal(output, offset);

    return output;
  }

  /// Derives a 32-byte key from password using PBKDF2-HMAC-SHA256.
  /// Note: Argon2id will be used in production (Phase 4).
  /// PBKDF2 serves as a portable Dart-only placeholder.
  Uint8List deriveKey(String password, Uint8List salt, {int iterations = 100000}) {
    final params = Pbkdf2Parameters(salt, iterations, 32);
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(params);
    return kdf.process(Uint8List.fromList(password.codeUnits));
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/core/crypto/crypto_service_test.dart -v
```

Expected: All 7 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/crypto/ test/core/crypto/
git commit -m "feat: add AES-256-GCM crypto service with key derivation"
```

---

## Task 5: Theme System (Light/Dark)

**Files:**
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/theme/terminal_themes.dart`
- Create: `lib/core/theme/theme_provider.dart`

- [ ] **Step 1: Create app themes**

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const primary = Color(0xFF6c5ce7);
    const background = Color(0xFFF5F5F5);
    const surface = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF1A1A1A);
    const onSurfaceVariant = Color(0xFF666666);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData dark() {
    const primary = Color(0xFFCBA6F7);
    const background = Color(0xFF1E1E2E);
    const surface = Color(0xFF313244);
    const onSurface = Color(0xFFCDD6F4);
    const onSurfaceVariant = Color(0xFFA6ADC8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF181825),
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static const Color onlineGreen = Color(0xFFA6E3A1);
  static const Color onlineGreenLight = Color(0xFF00B894);
  static const Color errorRed = Color(0xFFF38BA8);
  static const Color errorRedLight = Color(0xFFE17055);
  static const Color warningYellow = Color(0xFFF9E2AF);
}
```

- [ ] **Step 2: Create terminal color schemes**

Create `lib/core/theme/terminal_themes.dart`:

```dart
import 'package:xterm/xterm.dart';
import 'package:flutter/material.dart';

class TerminalThemes {
  static const String defaultTheme = 'catppuccin';

  static final Map<String, TerminalTheme> themes = {
    'catppuccin': TerminalTheme(
      cursor: Color(0xFFF5E0DC),
      selection: Color(0x80585B70),
      foreground: Color(0xFFCDD6F4),
      background: Color(0xFF1E1E2E),
      black: Color(0xFF45475A),
      red: Color(0xFFF38BA8),
      green: Color(0xFFA6E3A1),
      yellow: Color(0xFFF9E2AF),
      blue: Color(0xFF89B4FA),
      magenta: Color(0xFFF5C2E7),
      cyan: Color(0xFF94E2D5),
      white: Color(0xFFBAC2DE),
      brightBlack: Color(0xFF585B70),
      brightRed: Color(0xFFF38BA8),
      brightGreen: Color(0xFFA6E3A1),
      brightYellow: Color(0xFFF9E2AF),
      brightBlue: Color(0xFF89B4FA),
      brightMagenta: Color(0xFFF5C2E7),
      brightCyan: Color(0xFF94E2D5),
      brightWhite: Color(0xFFA6ADC8),
      searchHitBackground: Color(0x80F9E2AF),
      searchHitBackgroundCurrent: Color(0xFFF9E2AF),
      searchHitForeground: Color(0xFF1E1E2E),
    ),
    'dracula': TerminalTheme(
      cursor: Color(0xFFF8F8F2),
      selection: Color(0x8044475A),
      foreground: Color(0xFFF8F8F2),
      background: Color(0xFF282A36),
      black: Color(0xFF21222C),
      red: Color(0xFFFF5555),
      green: Color(0xFF50FA7B),
      yellow: Color(0xFFF1FA8C),
      blue: Color(0xFF6272A4),
      magenta: Color(0xFFFF79C6),
      cyan: Color(0xFF8BE9FD),
      white: Color(0xFFF8F8F2),
      brightBlack: Color(0xFF6272A4),
      brightRed: Color(0xFFFF6E6E),
      brightGreen: Color(0xFF69FF94),
      brightYellow: Color(0xFFFFFFA5),
      brightBlue: Color(0xFFD6ACFF),
      brightMagenta: Color(0xFFFF92DF),
      brightCyan: Color(0xFFA4FFFF),
      brightWhite: Color(0xFFFFFFFF),
      searchHitBackground: Color(0x80F1FA8C),
      searchHitBackgroundCurrent: Color(0xFFF1FA8C),
      searchHitForeground: Color(0xFF282A36),
    ),
    'monokai': TerminalTheme(
      cursor: Color(0xFFF8F8F0),
      selection: Color(0x8049483E),
      foreground: Color(0xFFF8F8F2),
      background: Color(0xFF272822),
      black: Color(0xFF272822),
      red: Color(0xFFF92672),
      green: Color(0xFFA6E22E),
      yellow: Color(0xFFF4BF75),
      blue: Color(0xFF66D9EF),
      magenta: Color(0xFFAE81FF),
      cyan: Color(0xFFA1EFE4),
      white: Color(0xFFF8F8F2),
      brightBlack: Color(0xFF75715E),
      brightRed: Color(0xFFF92672),
      brightGreen: Color(0xFFA6E22E),
      brightYellow: Color(0xFFF4BF75),
      brightBlue: Color(0xFF66D9EF),
      brightMagenta: Color(0xFFAE81FF),
      brightCyan: Color(0xFFA1EFE4),
      brightWhite: Color(0xFFF9F8F5),
      searchHitBackground: Color(0x80F4BF75),
      searchHitBackgroundCurrent: Color(0xFFF4BF75),
      searchHitForeground: Color(0xFF272822),
    ),
    'solarized-dark': TerminalTheme(
      cursor: Color(0xFF839496),
      selection: Color(0x80073642),
      foreground: Color(0xFF839496),
      background: Color(0xFF002B36),
      black: Color(0xFF073642),
      red: Color(0xFFDC322F),
      green: Color(0xFF859900),
      yellow: Color(0xFFB58900),
      blue: Color(0xFF268BD2),
      magenta: Color(0xFFD33682),
      cyan: Color(0xFF2AA198),
      white: Color(0xFFEEE8D5),
      brightBlack: Color(0xFF002B36),
      brightRed: Color(0xFFCB4B16),
      brightGreen: Color(0xFF586E75),
      brightYellow: Color(0xFF657B83),
      brightBlue: Color(0xFF839496),
      brightMagenta: Color(0xFF6C71C4),
      brightCyan: Color(0xFF93A1A1),
      brightWhite: Color(0xFFFDF6E3),
      searchHitBackground: Color(0x80B58900),
      searchHitBackgroundCurrent: Color(0xFFB58900),
      searchHitForeground: Color(0xFF002B36),
    ),
    'solarized-light': TerminalTheme(
      cursor: Color(0xFF657B83),
      selection: Color(0x80EEE8D5),
      foreground: Color(0xFF657B83),
      background: Color(0xFFFDF6E3),
      black: Color(0xFF073642),
      red: Color(0xFFDC322F),
      green: Color(0xFF859900),
      yellow: Color(0xFFB58900),
      blue: Color(0xFF268BD2),
      magenta: Color(0xFFD33682),
      cyan: Color(0xFF2AA198),
      white: Color(0xFFEEE8D5),
      brightBlack: Color(0xFF002B36),
      brightRed: Color(0xFFCB4B16),
      brightGreen: Color(0xFF586E75),
      brightYellow: Color(0xFF657B83),
      brightBlue: Color(0xFF839496),
      brightMagenta: Color(0xFF6C71C4),
      brightCyan: Color(0xFF93A1A1),
      brightWhite: Color(0xFFFDF6E3),
      searchHitBackground: Color(0x80B58900),
      searchHitBackgroundCurrent: Color(0xFFB58900),
      searchHitForeground: Color(0xFFFDF6E3),
    ),
  };

  static TerminalTheme getTheme(String name) {
    return themes[name] ?? themes[defaultTheme]!;
  }

  static List<String> get themeNames => themes.keys.toList();
}
```

- [ ] **Step 3: Create theme provider**

Create `lib/core/theme/theme_provider.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreference { light, dark, system }

class ThemeState {
  final ThemePreference preference;
  final String terminalThemeName;

  const ThemeState({
    this.preference = ThemePreference.system,
    this.terminalThemeName = 'catppuccin',
  });

  ThemeState copyWith({
    ThemePreference? preference,
    String? terminalThemeName,
  }) {
    return ThemeState(
      preference: preference ?? this.preference,
      terminalThemeName: terminalThemeName ?? this.terminalThemeName,
    );
  }

  ThemeMode get themeMode => switch (preference) {
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
    ThemePreference.system => ThemeMode.system,
  };
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void setThemePreference(ThemePreference preference) {
    state = state.copyWith(preference: preference);
  }

  void setTerminalTheme(String themeName) {
    state = state.copyWith(terminalThemeName: themeName);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
```

- [ ] **Step 4: Verify compilation**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/core/theme/
git commit -m "feat: add light/dark theme system with terminal color schemes"
```

---

## Task 6: App Shell & GoRouter Routing

**Files:**
- Create: `lib/core/router/app_router.dart`
- Modify: `lib/app.dart`
- Modify: `lib/main.dart`
- Create: `lib/shared/widgets/app_scaffold.dart`

- [ ] **Step 1: Create bottom navigation scaffold**

Create `lib/shared/widgets/app_scaffold.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dns_outlined), selectedIcon: Icon(Icons.dns), label: '主机'),
          NavigationDestination(icon: Icon(Icons.terminal_outlined), selectedIcon: Icon(Icons.terminal), label: '终端'),
          NavigationDestination(icon: Icon(Icons.vpn_key_outlined), selectedIcon: Icon(Icons.vpn_key), label: '密钥'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create router configuration**

Create `lib/core/router/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/shared/widgets/app_scaffold.dart';
import 'package:nexterm/features/hosts/ui/hosts_screen.dart';
import 'package:nexterm/features/hosts/ui/host_form_screen.dart';
import 'package:nexterm/features/keys/ui/keys_screen.dart';
import 'package:nexterm/features/keys/ui/key_generate_screen.dart';
import 'package:nexterm/features/terminal/ui/terminal_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/hosts',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/hosts',
            builder: (context, state) => const HostsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const HostFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => HostFormScreen(hostId: state.pathParameters['id']),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/terminal',
            builder: (context, state) => const TerminalScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/keys',
            builder: (context, state) => const KeysScreen(),
            routes: [
              GoRoute(
                path: 'generate',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const KeyGenerateScreen(),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('设置 — Phase 5')),
            ),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/terminal/connect/:hostId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TerminalScreen(hostId: state.pathParameters['hostId']),
    ),
  ],
);
```

- [ ] **Step 3: Create app.dart with theme integration**

Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/core/theme/app_theme.dart';
import 'package:nexterm/core/theme/theme_provider.dart';
import 'package:nexterm/core/router/app_router.dart';

class NextermApp extends ConsumerWidget {
  const NextermApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Nexterm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeState.themeMode,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 4: Update main.dart with database initialization**

Replace `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/app.dart';
import 'package:nexterm/data/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: NextermApp()));
}
```

- [ ] **Step 5: Create placeholder screens**

Create `lib/features/hosts/ui/hosts_screen.dart`:

```dart
import 'package:flutter/material.dart';

class HostsScreen extends StatelessWidget {
  const HostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主机')),
      body: const Center(child: Text('主机列表')),
    );
  }
}
```

Create `lib/features/hosts/ui/host_form_screen.dart`:

```dart
import 'package:flutter/material.dart';

class HostFormScreen extends StatelessWidget {
  final String? hostId;
  const HostFormScreen({super.key, this.hostId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hostId == null ? '添加主机' : '编辑主机')),
      body: const Center(child: Text('主机表单')),
    );
  }
}
```

Create `lib/features/keys/ui/keys_screen.dart`:

```dart
import 'package:flutter/material.dart';

class KeysScreen extends StatelessWidget {
  const KeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('密钥')),
      body: const Center(child: Text('密钥列表')),
    );
  }
}
```

Create `lib/features/keys/ui/key_generate_screen.dart`:

```dart
import 'package:flutter/material.dart';

class KeyGenerateScreen extends StatelessWidget {
  const KeyGenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成密钥')),
      body: const Center(child: Text('密钥生成表单')),
    );
  }
}
```

Create `lib/features/terminal/ui/terminal_screen.dart`:

```dart
import 'package:flutter/material.dart';

class TerminalScreen extends StatelessWidget {
  final String? hostId;
  const TerminalScreen({super.key, this.hostId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('终端')),
      body: const Center(child: Text('终端视图')),
    );
  }
}
```

- [ ] **Step 6: Verify build**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 7: Commit**

```bash
git add lib/
git commit -m "feat: add GoRouter shell with bottom navigation and placeholder screens"
```

---

## Task 7: Host Repository & Providers

**Files:**
- Create: `lib/data/repositories/host_repository_impl.dart`
- Create: `lib/features/hosts/providers/hosts_provider.dart`
- Test: `test/data/repositories/host_repository_impl_test.dart`

- [ ] **Step 1: Write failing test for HostRepositoryImpl**

Create `test/data/repositories/host_repository_impl_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/repositories/host_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';

void main() {
  late AppDatabase db;
  late HostRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = HostRepositoryImpl(db.hostsDao);
  });

  tearDown(() => db.close());

  HostEntity _makeHost({String id = 'h1', String name = 'Test Server'}) {
    return HostEntity(
      id: id,
      name: name,
      hostname: '192.168.1.1',
      username: 'admin',
      authMethod: AuthMethod.password,
      password: 'secret',
    );
  }

  test('insert and getAll returns host', () async {
    await repo.insert(_makeHost());
    final hosts = await repo.getAll();
    expect(hosts, hasLength(1));
    expect(hosts.first.name, equals('Test Server'));
    expect(hosts.first.hostname, equals('192.168.1.1'));
  });

  test('getById returns matching host', () async {
    await repo.insert(_makeHost(id: 'h1'));
    final host = await repo.getById('h1');
    expect(host, isNotNull);
    expect(host!.id, equals('h1'));
  });

  test('getById returns null for missing id', () async {
    final host = await repo.getById('missing');
    expect(host, isNull);
  });

  test('update modifies host', () async {
    await repo.insert(_makeHost());
    final updated = _makeHost().copyWith(name: 'Updated Name');
    await repo.update(updated);
    final host = await repo.getById('h1');
    expect(host!.name, equals('Updated Name'));
  });

  test('delete removes host', () async {
    await repo.insert(_makeHost());
    await repo.delete('h1');
    final hosts = await repo.getAll();
    expect(hosts, isEmpty);
  });

  test('search finds by name', () async {
    await repo.insert(_makeHost(name: 'Production Server'));
    await repo.insert(_makeHost(id: 'h2', name: 'Staging DB'));
    final results = await repo.search('prod');
    expect(results, hasLength(1));
    expect(results.first.name, equals('Production Server'));
  });

  test('getFavorites returns only favorites', () async {
    await repo.insert(_makeHost(id: 'h1'));
    await repo.insert(_makeHost(id: 'h2').copyWith(isFavorite: true));
    final favorites = await repo.getFavorites();
    expect(favorites, hasLength(1));
    expect(favorites.first.id, equals('h2'));
  });

  test('deleteMultiple removes multiple hosts', () async {
    await repo.insert(_makeHost(id: 'h1'));
    await repo.insert(_makeHost(id: 'h2'));
    await repo.insert(_makeHost(id: 'h3'));
    await repo.deleteMultiple(['h1', 'h3']);
    final hosts = await repo.getAll();
    expect(hosts, hasLength(1));
    expect(hosts.first.id, equals('h2'));
  });

  test('tags are persisted correctly', () async {
    await repo.insert(_makeHost().copyWith(tags: ['web', 'prod']));
    final host = await repo.getById('h1');
    expect(host!.tags, equals(['web', 'prod']));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/data/repositories/host_repository_impl_test.dart
```

Expected: FAIL — `host_repository_impl.dart` does not exist.

- [ ] **Step 3: Implement HostRepositoryImpl**

Create `lib/data/repositories/host_repository_impl.dart`:

```dart
import 'package:nexterm/data/database/daos/hosts_dao.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/repositories/host_repository.dart';

class HostRepositoryImpl implements HostRepository {
  final HostsDao _dao;

  HostRepositoryImpl(this._dao);

  @override
  Future<List<HostEntity>> getAll() => _dao.getAll();

  @override
  Future<HostEntity?> getById(String id) => _dao.getById(id);

  @override
  Future<List<HostEntity>> getByGroup(String? group) => _dao.getByGroup(group);

  @override
  Future<List<HostEntity>> getFavorites() => _dao.getFavorites();

  @override
  Future<List<HostEntity>> search(String query) => _dao.search(query);

  @override
  Future<void> insert(HostEntity host) => _dao.insertHost(host);

  @override
  Future<void> update(HostEntity host) => _dao.updateHost(host);

  @override
  Future<void> delete(String id) => _dao.deleteHost(id);

  @override
  Future<void> deleteMultiple(List<String> ids) => _dao.deleteMultiple(ids);

  @override
  Stream<List<HostEntity>> watchAll() => _dao.watchAll();
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/data/repositories/host_repository_impl_test.dart -v
```

Expected: All 9 tests PASS.

- [ ] **Step 5: Create hosts provider**

Create `lib/features/hosts/providers/hosts_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/repositories/host_repository_impl.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/repositories/host_repository.dart';
import 'package:nexterm/main.dart';
import 'package:uuid/uuid.dart';

final hostRepositoryProvider = Provider<HostRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HostRepositoryImpl(db.hostsDao);
});

final hostsStreamProvider = StreamProvider<List<HostEntity>>((ref) {
  final repo = ref.watch(hostRepositoryProvider);
  return repo.watchAll();
});

final hostSearchProvider = FutureProvider.family<List<HostEntity>, String>((ref, query) {
  final repo = ref.watch(hostRepositoryProvider);
  if (query.isEmpty) return repo.getAll();
  return repo.search(query);
});

final hostByIdProvider = FutureProvider.family<HostEntity?, String>((ref, id) {
  final repo = ref.watch(hostRepositoryProvider);
  return repo.getById(id);
});

class HostsNotifier extends StateNotifier<AsyncValue<void>> {
  final HostRepository _repo;

  HostsNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> addHost(HostEntity host) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newHost = host.copyWith(id: const Uuid().v4());
      await _repo.insert(newHost);
    });
  }

  Future<void> updateHost(HostEntity host) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.update(host));
  }

  Future<void> deleteHost(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }

  Future<void> deleteMultiple(List<String> ids) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.deleteMultiple(ids));
  }

  Future<void> toggleFavorite(HostEntity host) async {
    await _repo.update(host.copyWith(isFavorite: !host.isFavorite));
  }

  Future<void> updateLastConnected(String hostId) async {
    final host = await _repo.getById(hostId);
    if (host != null) {
      await _repo.update(host.copyWith(lastConnected: () => DateTime.now()));
    }
  }
}

final hostsNotifierProvider = StateNotifierProvider<HostsNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(hostRepositoryProvider);
  return HostsNotifier(repo);
});
```

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/host_repository_impl.dart lib/features/hosts/providers/ test/data/repositories/
git commit -m "feat: add host repository implementation and Riverpod providers"
```

---

## Task 8: Host Management UI

**Files:**
- Modify: `lib/features/hosts/ui/hosts_screen.dart`
- Modify: `lib/features/hosts/ui/host_form_screen.dart`
- Create: `lib/features/hosts/ui/widgets/host_list_tile.dart`
- Create: `lib/features/hosts/ui/widgets/host_search_bar.dart`
- Create: `lib/shared/widgets/status_indicator.dart`

- [ ] **Step 1: Create status indicator widget**

Create `lib/shared/widgets/status_indicator.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/core/theme/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final ConnectionStatus status;
  final double size;

  const StatusIndicator({super.key, required this.status, this.size = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (status) {
      ConnectionStatus.connected => isDark ? AppTheme.onlineGreen : AppTheme.onlineGreenLight,
      ConnectionStatus.connecting => AppTheme.warningYellow,
      ConnectionStatus.error => isDark ? AppTheme.errorRed : AppTheme.errorRedLight,
      ConnectionStatus.disconnected => Theme.of(context).colorScheme.onSurfaceVariant,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
```

- [ ] **Step 2: Create host list tile**

Create `lib/features/hosts/ui/widgets/host_list_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/shared/widgets/status_indicator.dart';

class HostListTile extends StatelessWidget {
  final HostEntity host;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleFavorite;

  const HostListTile({
    super.key,
    required this.host,
    required this.onTap,
    required this.onEdit,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const StatusIndicator(status: ConnectionStatus.disconnected),
        title: Text(host.name, style: theme.textTheme.bodyLarge),
        subtitle: Text(
          '${host.username}@${host.hostname}:${host.port} · ${host.authMethod.displayName}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (host.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  host.tags.map((t) => '#$t').join(' '),
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
            IconButton(
              icon: Icon(host.isFavorite ? Icons.star : Icons.star_border,
                  color: host.isFavorite ? Colors.amber : null, size: 20),
              onPressed: onToggleFavorite,
            ),
          ],
        ),
        onTap: onTap,
        onLongPress: onEdit,
      ),
    );
  }
}
```

- [ ] **Step 3: Create search bar**

Create `lib/features/hosts/ui/widgets/host_search_bar.dart`:

```dart
import 'package:flutter/material.dart';

class HostSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const HostSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: '搜索主机、IP、标签...',
          prefixIcon: Icon(Icons.search, size: 20),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implement hosts screen**

Replace `lib/features/hosts/ui/hosts_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_list_tile.dart';
import 'package:nexterm/features/hosts/ui/widgets/host_search_bar.dart';

class HostsScreen extends ConsumerStatefulWidget {
  const HostsScreen({super.key});

  @override
  ConsumerState<HostsScreen> createState() => _HostsScreenState();
}

class _HostsScreenState extends ConsumerState<HostsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final hostsAsync = _searchQuery.isEmpty
        ? ref.watch(hostsStreamProvider)
        : ref.watch(hostSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('主机'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.go('/hosts/add')),
        ],
      ),
      body: Column(
        children: [
          HostSearchBar(onChanged: (q) => setState(() => _searchQuery = q)),
          Expanded(
            child: hostsAsync.when(
              data: (hosts) {
                if (hosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.dns_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('暂无主机', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => context.go('/hosts/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('添加主机'),
                        ),
                      ],
                    ),
                  );
                }

                final favorites = hosts.where((h) => h.isFavorite).toList();
                final groups = <String?, List<dynamic>>{};
                for (final host in hosts.where((h) => !h.isFavorite)) {
                  groups.putIfAbsent(host.group, () => []).add(host);
                }

                return ListView(
                  children: [
                    if (favorites.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text('★ 收藏', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        )),
                      ),
                      ...favorites.map((host) => HostListTile(
                        host: host,
                        onTap: () => context.go('/terminal/connect/${host.id}'),
                        onEdit: () => context.go('/hosts/edit/${host.id}'),
                        onToggleFavorite: () => ref.read(hostsNotifierProvider.notifier).toggleFavorite(host),
                      )),
                    ],
                    ...groups.entries.map((entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(entry.key ?? '未分组', style: Theme.of(context).textTheme.labelLarge),
                        ),
                        ...entry.value.map((host) => HostListTile(
                          host: host,
                          onTap: () => context.go('/terminal/connect/${host.id}'),
                          onEdit: () => context.go('/hosts/edit/${host.id}'),
                          onToggleFavorite: () => ref.read(hostsNotifierProvider.notifier).toggleFavorite(host),
                        )),
                      ],
                    )),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('加载失败: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Implement host form screen**

Replace `lib/features/hosts/ui/host_form_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';

class HostFormScreen extends ConsumerStatefulWidget {
  final String? hostId;
  const HostFormScreen({super.key, this.hostId});

  @override
  ConsumerState<HostFormScreen> createState() => _HostFormScreenState();
}

class _HostFormScreenState extends ConsumerState<HostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _hostnameCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '22');
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  AuthMethod _authMethod = AuthMethod.password;
  String? _selectedKeyId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.hostId != null) {
      _loadHost();
    }
  }

  Future<void> _loadHost() async {
    final host = await ref.read(hostByIdProvider(widget.hostId!).future);
    if (host != null && mounted) {
      setState(() {
        _nameCtrl.text = host.name;
        _hostnameCtrl.text = host.hostname;
        _portCtrl.text = host.port.toString();
        _usernameCtrl.text = host.username;
        _passwordCtrl.text = host.password ?? '';
        _groupCtrl.text = host.group ?? '';
        _tagsCtrl.text = host.tags.join(', ');
        _authMethod = host.authMethod;
        _selectedKeyId = host.keyId;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hostnameCtrl.dispose();
    _portCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _groupCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final tags = _tagsCtrl.text.isEmpty
        ? <String>[]
        : _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    final host = HostEntity(
      id: widget.hostId ?? '',
      name: _nameCtrl.text,
      hostname: _hostnameCtrl.text,
      port: int.tryParse(_portCtrl.text) ?? 22,
      username: _usernameCtrl.text,
      authMethod: _authMethod,
      password: _authMethod == AuthMethod.password ? _passwordCtrl.text : null,
      keyId: _authMethod == AuthMethod.key ? _selectedKeyId : null,
      group: _groupCtrl.text.isEmpty ? null : _groupCtrl.text,
      tags: tags,
    );

    final notifier = ref.read(hostsNotifierProvider.notifier);
    if (widget.hostId == null) {
      await notifier.addHost(host);
    } else {
      await notifier.updateHost(host);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hostId == null ? '添加主机' : '编辑主机'),
        actions: [
          if (widget.hostId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                await ref.read(hostsNotifierProvider.notifier).deleteHost(widget.hostId!);
                if (mounted) context.pop();
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: '名称'),
              validator: (v) => (v == null || v.isEmpty) ? '请输入名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hostnameCtrl,
              decoration: const InputDecoration(labelText: '主机名 / IP'),
              validator: (v) => (v == null || v.isEmpty) ? '请输入主机名' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(labelText: '用户名'),
                    validator: (v) => (v == null || v.isEmpty) ? '请输入用户名' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _portCtrl,
                    decoration: const InputDecoration(labelText: '端口'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<AuthMethod>(
              segments: AuthMethod.values.map((m) =>
                ButtonSegment(value: m, label: Text(m.displayName)),
              ).toList(),
              selected: {_authMethod},
              onSelectionChanged: (v) => setState(() => _authMethod = v.first),
            ),
            const SizedBox(height: 12),
            if (_authMethod == AuthMethod.password)
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _groupCtrl,
              decoration: const InputDecoration(labelText: '分组（可选）'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(labelText: '标签（逗号分隔，可选）'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.hostId == null ? '添加' : '保存'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Verify build**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 7: Commit**

```bash
git add lib/features/hosts/ lib/shared/
git commit -m "feat: implement host management UI with list, search, add/edit forms"
```

---

## Task 9: Key Repository & Providers

**Files:**
- Create: `lib/data/repositories/ssh_key_repository_impl.dart`
- Create: `lib/features/keys/providers/keys_provider.dart`
- Test: `test/data/repositories/ssh_key_repository_impl_test.dart`

- [ ] **Step 1: Write failing test for SSHKeyRepositoryImpl**

Create `test/data/repositories/ssh_key_repository_impl_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/data/database/app_database.dart';
import 'package:nexterm/data/repositories/ssh_key_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

void main() {
  late AppDatabase db;
  late SSHKeyRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SSHKeyRepositoryImpl(db.sshKeysDao);
  });

  tearDown(() => db.close());

  SSHKeyEntity _makeKey({String id = 'k1'}) {
    return SSHKeyEntity(
      id: id,
      name: 'Test Key',
      type: KeyType.ed25519,
      privateKey: 'private-key-data',
      publicKey: 'ssh-ed25519 AAAA...',
      fingerprint: 'SHA256:abc123',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('insert and getAll returns key', () async {
    await repo.insert(_makeKey());
    final keys = await repo.getAll();
    expect(keys, hasLength(1));
    expect(keys.first.name, equals('Test Key'));
    expect(keys.first.type, equals(KeyType.ed25519));
  });

  test('getById returns matching key', () async {
    await repo.insert(_makeKey());
    final key = await repo.getById('k1');
    expect(key, isNotNull);
    expect(key!.fingerprint, equals('SHA256:abc123'));
  });

  test('delete removes key', () async {
    await repo.insert(_makeKey());
    await repo.delete('k1');
    final keys = await repo.getAll();
    expect(keys, isEmpty);
  });

  test('update modifies key', () async {
    await repo.insert(_makeKey());
    final updated = _makeKey().copyWith(name: 'Renamed Key');
    await repo.update(updated);
    final key = await repo.getById('k1');
    expect(key!.name, equals('Renamed Key'));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/data/repositories/ssh_key_repository_impl_test.dart
```

Expected: FAIL — `ssh_key_repository_impl.dart` does not exist.

- [ ] **Step 3: Implement SSHKeyRepositoryImpl**

Create `lib/data/repositories/ssh_key_repository_impl.dart`:

```dart
import 'package:nexterm/data/database/daos/ssh_keys_dao.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/domain/repositories/ssh_key_repository.dart';

class SSHKeyRepositoryImpl implements SSHKeyRepository {
  final SshKeysDao _dao;

  SSHKeyRepositoryImpl(this._dao);

  @override
  Future<List<SSHKeyEntity>> getAll() => _dao.getAll();

  @override
  Future<SSHKeyEntity?> getById(String id) => _dao.getById(id);

  @override
  Future<void> insert(SSHKeyEntity key) => _dao.insertKey(key);

  @override
  Future<void> update(SSHKeyEntity key) => _dao.updateKey(key);

  @override
  Future<void> delete(String id) => _dao.deleteKey(id);

  @override
  Stream<List<SSHKeyEntity>> watchAll() => _dao.watchAll();
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/data/repositories/ssh_key_repository_impl_test.dart -v
```

Expected: All 4 tests PASS.

- [ ] **Step 5: Create keys provider**

Create `lib/features/keys/providers/keys_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/repositories/ssh_key_repository_impl.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/domain/repositories/ssh_key_repository.dart';
import 'package:nexterm/main.dart';
import 'package:uuid/uuid.dart';
import 'package:dartssh2/dartssh2.dart';

final sshKeyRepositoryProvider = Provider<SSHKeyRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SSHKeyRepositoryImpl(db.sshKeysDao);
});

final keysStreamProvider = StreamProvider<List<SSHKeyEntity>>((ref) {
  final repo = ref.watch(sshKeyRepositoryProvider);
  return repo.watchAll();
});

class KeysNotifier extends StateNotifier<AsyncValue<void>> {
  final SSHKeyRepository _repo;

  KeysNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<SSHKeyEntity> generateKey({
    required String name,
    required KeyType type,
    String? passphrase,
  }) async {
    final keyPair = switch (type) {
      KeyType.ed25519 => SSHKeyPair.ed25519(),
      KeyType.rsa2048 => SSHKeyPair.rsa(2048),
      KeyType.rsa4096 => SSHKeyPair.rsa(4096),
      KeyType.ecdsa256 => SSHKeyPair.ecdsa(256),
      KeyType.ecdsa384 => SSHKeyPair.ecdsa(384),
      KeyType.ecdsa521 => SSHKeyPair.ecdsa(521),
    };

    final entity = SSHKeyEntity(
      id: const Uuid().v4(),
      name: name,
      type: type,
      privateKey: keyPair.toOpenSSHString(),
      publicKey: keyPair.toPublicKey().toString(),
      fingerprint: keyPair.toPublicKey().fingerprint,
      passphrase: passphrase,
      createdAt: DateTime.now(),
    );

    await _repo.insert(entity);
    return entity;
  }

  Future<void> deleteKey(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }

  Future<void> updateKey(SSHKeyEntity key) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.update(key));
  }
}

final keysNotifierProvider = StateNotifierProvider<KeysNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(sshKeyRepositoryProvider);
  return KeysNotifier(repo);
});
```

- [ ] **Step 6: Commit**

```bash
git add lib/data/repositories/ssh_key_repository_impl.dart lib/features/keys/providers/ test/data/repositories/ssh_key_repository_impl_test.dart
git commit -m "feat: add SSH key repository and providers with key generation"
```

---

## Task 10: Key Management UI

**Files:**
- Modify: `lib/features/keys/ui/keys_screen.dart`
- Modify: `lib/features/keys/ui/key_generate_screen.dart`
- Create: `lib/features/keys/ui/widgets/key_list_tile.dart`

- [ ] **Step 1: Create key list tile**

Create `lib/features/keys/ui/widgets/key_list_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';

class KeyListTile extends StatelessWidget {
  final SSHKeyEntity sshKey;
  final VoidCallback onDelete;

  const KeyListTile({super.key, required this.sshKey, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.vpn_key, color: theme.colorScheme.primary),
        title: Text(sshKey.name),
        subtitle: Text(
          '${sshKey.type.displayName} · ${sshKey.fingerprint}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'copy':
                Clipboard.setData(ClipboardData(text: sshKey.publicKey));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('公钥已复制到剪贴板')),
                );
              case 'delete':
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('删除密钥'),
                    content: Text('确定要删除 "${sshKey.name}" 吗？'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                      TextButton(
                        onPressed: () { Navigator.pop(ctx); onDelete(); },
                        child: const Text('删除', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'copy', child: Text('复制公钥')),
            const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Implement keys screen**

Replace `lib/features/keys/ui/keys_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/features/keys/ui/widgets/key_list_tile.dart';

class KeysScreen extends ConsumerWidget {
  const KeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keysAsync = ref.watch(keysStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('密钥'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.go('/keys/generate')),
        ],
      ),
      body: keysAsync.when(
        data: (keys) {
          if (keys.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vpn_key_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('暂无密钥', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => context.go('/keys/generate'),
                    icon: const Icon(Icons.add),
                    label: const Text('生成密钥'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: keys.length,
            itemBuilder: (context, index) => KeyListTile(
              sshKey: keys[index],
              onDelete: () => ref.read(keysNotifierProvider.notifier).deleteKey(keys[index].id),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('加载失败: $err')),
      ),
    );
  }
}
```

- [ ] **Step 3: Implement key generate screen**

Replace `lib/features/keys/ui/key_generate_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';

class KeyGenerateScreen extends ConsumerStatefulWidget {
  const KeyGenerateScreen({super.key});

  @override
  ConsumerState<KeyGenerateScreen> createState() => _KeyGenerateScreenState();
}

class _KeyGenerateScreenState extends ConsumerState<KeyGenerateScreen> {
  final _nameCtrl = TextEditingController();
  KeyType _selectedType = KeyType.ed25519;
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _isGenerating = true);

    final entity = await ref.read(keysNotifierProvider.notifier).generateKey(
      name: _nameCtrl.text,
      type: _selectedType,
    );

    if (mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('密钥已生成'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('公钥:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  entity.publicKey,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: entity.publicKey));
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('公钥已复制')));
              },
              child: const Text('复制公钥'),
            ),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('完成')),
          ],
        ),
      );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成密钥')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '密钥名称'),
          ),
          const SizedBox(height: 16),
          Text('密钥类型', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...KeyType.values.map((type) => RadioListTile<KeyType>(
            title: Text(type.displayName),
            subtitle: type == KeyType.ed25519 ? const Text('推荐') : null,
            value: type,
            groupValue: _selectedType,
            onChanged: (v) => setState(() => _selectedType = v!),
          )),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isGenerating ? null : _generate,
            child: _isGenerating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('生成'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Verify build**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/features/keys/
git commit -m "feat: implement key management UI with generation and public key copy"
```

---

## Task 11: SSH Connection Service

**Files:**
- Create: `lib/features/terminal/services/ssh_service.dart`
- Test: `test/features/terminal/services/ssh_service_test.dart`

- [ ] **Step 1: Write failing test for SSHService**

Create `test/features/terminal/services/ssh_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/terminal/services/ssh_service.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/domain/entities/enums.dart';

void main() {
  late SSHService sshService;

  setUp(() {
    sshService = SSHService();
  });

  test('SSHService can be instantiated', () {
    expect(sshService, isNotNull);
  });

  test('buildConnectionConfig creates correct config from host with password', () {
    final host = HostEntity(
      id: 'h1',
      name: 'Test',
      hostname: '192.168.1.1',
      port: 22,
      username: 'admin',
      authMethod: AuthMethod.password,
      password: 'secret',
    );

    final config = sshService.buildConnectionConfig(host: host);
    expect(config.hostname, equals('192.168.1.1'));
    expect(config.port, equals(22));
    expect(config.username, equals('admin'));
    expect(config.password, equals('secret'));
    expect(config.privateKey, isNull);
  });

  test('buildConnectionConfig creates correct config from host with key', () {
    final host = HostEntity(
      id: 'h1',
      name: 'Test',
      hostname: '10.0.0.1',
      port: 2222,
      username: 'deploy',
      authMethod: AuthMethod.key,
      keyId: 'k1',
    );

    final key = SSHKeyEntity(
      id: 'k1',
      name: 'deploy-key',
      type: KeyType.ed25519,
      privateKey: 'private-key-data',
      publicKey: 'public-key-data',
      fingerprint: 'SHA256:xxx',
      createdAt: DateTime.now(),
    );

    final config = sshService.buildConnectionConfig(host: host, key: key);
    expect(config.hostname, equals('10.0.0.1'));
    expect(config.port, equals(2222));
    expect(config.username, equals('deploy'));
    expect(config.privateKey, equals('private-key-data'));
    expect(config.password, isNull);
  });

  test('buildConnectionConfig includes jump hosts', () {
    final host = HostEntity(
      id: 'h1',
      name: 'Target',
      hostname: '10.0.0.50',
      username: 'admin',
      authMethod: AuthMethod.password,
      password: 'pass',
      jumpHosts: ['jump1', 'jump2'],
    );

    final config = sshService.buildConnectionConfig(host: host);
    expect(config.jumpHostIds, equals(['jump1', 'jump2']));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/terminal/services/ssh_service_test.dart
```

Expected: FAIL — `ssh_service.dart` does not exist.

- [ ] **Step 3: Implement SSHService**

Create `lib/features/terminal/services/ssh_service.dart`:

```dart
import 'dart:async';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/entities/ssh_key_entity.dart';
import 'package:nexterm/domain/entities/enums.dart';

class SSHConnectionConfig {
  final String hostname;
  final int port;
  final String username;
  final String? password;
  final String? privateKey;
  final String? passphrase;
  final List<String> jumpHostIds;

  const SSHConnectionConfig({
    required this.hostname,
    required this.port,
    required this.username,
    this.password,
    this.privateKey,
    this.passphrase,
    this.jumpHostIds = const [],
  });
}

class SSHSession {
  final String id;
  final SSHClient client;
  final SSHSession? jumpClient;
  SSHShell? shell;
  ConnectionStatus status;

  SSHSession({
    required this.id,
    required this.client,
    this.jumpClient,
    this.status = ConnectionStatus.connecting,
  });

  Future<void> close() async {
    shell?.close();
    client.close();
    await jumpClient?.close();
    status = ConnectionStatus.disconnected;
  }
}

class SSHService {
  final Map<String, SSHSession> _sessions = {};

  Map<String, SSHSession> get sessions => Map.unmodifiable(_sessions);

  SSHConnectionConfig buildConnectionConfig({
    required HostEntity host,
    SSHKeyEntity? key,
  }) {
    return SSHConnectionConfig(
      hostname: host.hostname,
      port: host.port,
      username: host.username,
      password: host.authMethod == AuthMethod.password ? host.password : null,
      privateKey: host.authMethod == AuthMethod.key ? key?.privateKey : null,
      passphrase: host.authMethod == AuthMethod.key ? key?.passphrase : null,
      jumpHostIds: host.jumpHosts,
    );
  }

  Future<SSHSession> connect(SSHConnectionConfig config, {String? sessionId}) async {
    final id = sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

    final socket = await SSHSocket.connect(config.hostname, config.port);

    final client = SSHClient(
      socket,
      username: config.username,
      onPasswordRequest: config.password != null ? () => config.password! : null,
      identities: config.privateKey != null
          ? SSHKeyPair.fromPem(config.privateKey!, config.passphrase)
          : null,
    );

    final session = SSHSession(id: id, client: client);

    final shell = await client.shell(
      pty: SSHPtyConfig(
        type: 'xterm-256color',
        width: 80,
        height: 24,
      ),
    );

    session.shell = shell;
    session.status = ConnectionStatus.connected;
    _sessions[id] = session;

    return session;
  }

  Future<void> disconnect(String sessionId) async {
    final session = _sessions.remove(sessionId);
    await session?.close();
  }

  Future<void> disconnectAll() async {
    for (final session in _sessions.values) {
      await session.close();
    }
    _sessions.clear();
  }

  void resizePty(String sessionId, int width, int height) {
    final session = _sessions[sessionId];
    session?.shell?.resizeTerminal(width, height);
  }

  void write(String sessionId, Uint8List data) {
    final session = _sessions[sessionId];
    session?.shell?.write(data);
  }

  Stream<Uint8List>? stdout(String sessionId) {
    return _sessions[sessionId]?.shell?.stdout;
  }

  Stream<Uint8List>? stderr(String sessionId) {
    return _sessions[sessionId]?.shell?.stderr;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/terminal/services/ssh_service_test.dart -v
```

Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/terminal/services/ssh_service.dart test/features/terminal/services/
git commit -m "feat: add SSH connection service with dartssh2 integration"
```

---

## Task 12: Terminal Tab Manager

**Files:**
- Create: `lib/features/terminal/ui/tab_manager.dart`
- Test: `test/features/terminal/tab_manager_test.dart`

- [ ] **Step 1: Write failing test for TabManager**

Create `test/features/terminal/tab_manager_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:nexterm/domain/entities/enums.dart';

void main() {
  late TabManager manager;

  setUp(() {
    manager = TabManager();
  });

  test('starts with empty tabs', () {
    expect(manager.tabs, isEmpty);
    expect(manager.activeTabIndex, equals(-1));
  });

  test('addTab creates a new tab and sets it active', () {
    final tab = manager.addTab(hostId: 'h1', title: 'admin@prod');
    expect(manager.tabs, hasLength(1));
    expect(manager.activeTabIndex, equals(0));
    expect(tab.title, equals('admin@prod'));
    expect(tab.hostId, equals('h1'));
    expect(tab.status, equals(ConnectionStatus.disconnected));
  });

  test('addTab with multiple tabs sets newest active', () {
    manager.addTab(hostId: 'h1', title: 'tab1');
    manager.addTab(hostId: 'h2', title: 'tab2');
    expect(manager.tabs, hasLength(2));
    expect(manager.activeTabIndex, equals(1));
  });

  test('removeTab removes tab and adjusts active index', () {
    final tab1 = manager.addTab(hostId: 'h1', title: 'tab1');
    manager.addTab(hostId: 'h2', title: 'tab2');
    manager.setActiveTab(0);
    manager.removeTab(tab1.id);
    expect(manager.tabs, hasLength(1));
    expect(manager.activeTabIndex, equals(0));
  });

  test('removeTab on last tab sets index to -1', () {
    final tab = manager.addTab(hostId: 'h1', title: 'tab1');
    manager.removeTab(tab.id);
    expect(manager.tabs, isEmpty);
    expect(manager.activeTabIndex, equals(-1));
  });

  test('setActiveTab changes active index', () {
    manager.addTab(hostId: 'h1', title: 'tab1');
    manager.addTab(hostId: 'h2', title: 'tab2');
    manager.setActiveTab(0);
    expect(manager.activeTabIndex, equals(0));
  });

  test('updateTabStatus changes tab status', () {
    final tab = manager.addTab(hostId: 'h1', title: 'tab1');
    manager.updateTabStatus(tab.id, ConnectionStatus.connected);
    expect(manager.tabs.first.status, equals(ConnectionStatus.connected));
  });

  test('reorderTabs moves tab', () {
    manager.addTab(hostId: 'h1', title: 'A');
    manager.addTab(hostId: 'h2', title: 'B');
    manager.addTab(hostId: 'h3', title: 'C');
    manager.reorderTabs(0, 2);
    expect(manager.tabs.map((t) => t.title).toList(), equals(['B', 'C', 'A']));
  });

  test('activeTab returns current tab', () {
    manager.addTab(hostId: 'h1', title: 'tab1');
    expect(manager.activeTab, isNotNull);
    expect(manager.activeTab!.title, equals('tab1'));
  });

  test('activeTab returns null when no tabs', () {
    expect(manager.activeTab, isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/terminal/tab_manager_test.dart
```

Expected: FAIL — `tab_manager.dart` does not exist.

- [ ] **Step 3: Implement TabManager**

Create `lib/features/terminal/ui/tab_manager.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:uuid/uuid.dart';

class TerminalTab {
  final String id;
  final String hostId;
  String title;
  ConnectionStatus status;
  String? sessionId;

  TerminalTab({
    required this.id,
    required this.hostId,
    required this.title,
    this.status = ConnectionStatus.disconnected,
    this.sessionId,
  });
}

class TabManager extends ChangeNotifier {
  final List<TerminalTab> _tabs = [];
  int _activeTabIndex = -1;

  List<TerminalTab> get tabs => List.unmodifiable(_tabs);
  int get activeTabIndex => _activeTabIndex;

  TerminalTab? get activeTab {
    if (_activeTabIndex < 0 || _activeTabIndex >= _tabs.length) return null;
    return _tabs[_activeTabIndex];
  }

  TerminalTab addTab({required String hostId, required String title}) {
    final tab = TerminalTab(
      id: const Uuid().v4(),
      hostId: hostId,
      title: title,
    );
    _tabs.add(tab);
    _activeTabIndex = _tabs.length - 1;
    notifyListeners();
    return tab;
  }

  void removeTab(String tabId) {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index == -1) return;

    _tabs.removeAt(index);

    if (_tabs.isEmpty) {
      _activeTabIndex = -1;
    } else if (_activeTabIndex >= _tabs.length) {
      _activeTabIndex = _tabs.length - 1;
    } else if (_activeTabIndex > index) {
      _activeTabIndex--;
    }
    notifyListeners();
  }

  void setActiveTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  void updateTabStatus(String tabId, ConnectionStatus status) {
    final tab = _tabs.firstWhere((t) => t.id == tabId, orElse: () => throw StateError('Tab not found'));
    tab.status = status;
    notifyListeners();
  }

  void updateTabTitle(String tabId, String title) {
    final tab = _tabs.firstWhere((t) => t.id == tabId, orElse: () => throw StateError('Tab not found'));
    tab.title = title;
    notifyListeners();
  }

  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _tabs.length) return;
    if (newIndex < 0 || newIndex >= _tabs.length) return;

    final tab = _tabs.removeAt(oldIndex);
    _tabs.insert(newIndex, tab);

    if (_activeTabIndex == oldIndex) {
      _activeTabIndex = newIndex;
    } else if (oldIndex < _activeTabIndex && newIndex >= _activeTabIndex) {
      _activeTabIndex--;
    } else if (oldIndex > _activeTabIndex && newIndex <= _activeTabIndex) {
      _activeTabIndex++;
    }
    notifyListeners();
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/terminal/tab_manager_test.dart -v
```

Expected: All 10 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/terminal/ui/tab_manager.dart test/features/terminal/tab_manager_test.dart
git commit -m "feat: add terminal tab manager with reorder and status tracking"
```

---

## Task 13: Terminal Widget & xterm.dart Integration

**Files:**
- Create: `lib/features/terminal/ui/widgets/terminal_view.dart`
- Create: `lib/features/terminal/ui/widgets/terminal_tab_bar.dart`
- Create: `lib/features/terminal/providers/terminal_provider.dart`
- Modify: `lib/features/terminal/ui/terminal_screen.dart`

- [ ] **Step 1: Create terminal provider**

Create `lib/features/terminal/providers/terminal_provider.dart`:

```dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';
import 'package:nexterm/features/terminal/services/ssh_service.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:nexterm/features/hosts/providers/hosts_provider.dart';
import 'package:nexterm/features/keys/providers/keys_provider.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/core/theme/terminal_themes.dart';
import 'package:nexterm/core/theme/theme_provider.dart';

final sshServiceProvider = Provider<SSHService>((ref) {
  final service = SSHService();
  ref.onDispose(() => service.disconnectAll());
  return service;
});

final tabManagerProvider = ChangeNotifierProvider<TabManager>((ref) {
  return TabManager();
});

final terminalControllersProvider = StateProvider<Map<String, Terminal>>((ref) => {});

class TerminalActions {
  final Ref _ref;

  TerminalActions(this._ref);

  Terminal _createTerminal() {
    final themeState = _ref.read(themeProvider);
    final termTheme = TerminalThemes.getTheme(themeState.terminalThemeName);
    return Terminal(maxLines: 10000, theme: termTheme);
  }

  Future<void> connectHost(String hostId) async {
    final host = await _ref.read(hostByIdProvider(hostId).future);
    if (host == null) return;

    final tabManager = _ref.read(tabManagerProvider);
    final tab = tabManager.addTab(
      hostId: hostId,
      title: '${host.username}@${host.name}',
    );

    final terminal = _createTerminal();
    _ref.read(terminalControllersProvider.notifier).update((state) => {...state, tab.id: terminal});

    tabManager.updateTabStatus(tab.id, ConnectionStatus.connecting);

    try {
      final sshService = _ref.read(sshServiceProvider);
      final keyEntity = host.keyId != null
          ? await _ref.read(sshKeyRepositoryProvider).getById(host.keyId!)
          : null;
      final config = sshService.buildConnectionConfig(host: host, key: keyEntity);
      final session = await sshService.connect(config, sessionId: tab.id);

      tab.sessionId = session.id;
      tabManager.updateTabStatus(tab.id, ConnectionStatus.connected);

      session.shell?.stdout.listen((data) {
        terminal.write(String.fromCharCodes(data));
      });

      session.shell?.stderr.listen((data) {
        terminal.write(String.fromCharCodes(data));
      });

      terminal.onOutput = (data) {
        sshService.write(session.id, Uint8List.fromList(data.codeUnits));
      };

      session.shell?.done.then((_) {
        tabManager.updateTabStatus(tab.id, ConnectionStatus.disconnected);
      });

      await _ref.read(hostsNotifierProvider.notifier).updateLastConnected(hostId);
    } catch (e) {
      tabManager.updateTabStatus(tab.id, ConnectionStatus.error);
      terminal.write('\r\n连接失败: $e\r\n');
    }
  }

  Future<void> disconnectTab(String tabId) async {
    final tabManager = _ref.read(tabManagerProvider);
    final sshService = _ref.read(sshServiceProvider);

    await sshService.disconnect(tabId);
    tabManager.removeTab(tabId);

    _ref.read(terminalControllersProvider.notifier).update((state) {
      final newState = {...state};
      newState.remove(tabId);
      return newState;
    });
  }

  void resizePty(String tabId, int width, int height) {
    _ref.read(sshServiceProvider).resizePty(tabId, width, height);
  }
}

final terminalActionsProvider = Provider<TerminalActions>((ref) {
  return TerminalActions(ref);
});
```

- [ ] **Step 2: Create terminal tab bar widget**

Create `lib/features/terminal/ui/widgets/terminal_tab_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:nexterm/features/terminal/ui/tab_manager.dart';
import 'package:nexterm/domain/entities/enums.dart';
import 'package:nexterm/shared/widgets/status_indicator.dart';

class TerminalTabBar extends StatelessWidget {
  final List<TerminalTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<String> onTabClosed;
  final VoidCallback onAddTab;

  const TerminalTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onTabClosed,
    required this.onAddTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181825) : const Color(0xFFE8E8E8);
    final activeBg = isDark ? const Color(0xFF313244) : Colors.white;

    return Container(
      height: 40,
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final isActive = index == activeIndex;
                return GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive ? activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusIndicator(status: tab.status, size: 6),
                        const SizedBox(width: 6),
                        Text(
                          tab.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onTabClosed(tab.id),
                          child: Icon(Icons.close, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: onAddTab,
            icon: const Icon(Icons.add, size: 18),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create terminal view widget**

Create `lib/features/terminal/ui/widgets/terminal_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

class TerminalViewWidget extends StatelessWidget {
  final Terminal terminal;
  final double fontSize;
  final TerminalTheme? theme;

  const TerminalViewWidget({
    super.key,
    required this.terminal,
    this.fontSize = 14,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return TerminalView(
      terminal,
      textStyle: TerminalStyle(fontSize: fontSize, fontFamily: 'JetBrainsMono'),
      theme: theme,
      padding: const EdgeInsets.all(8),
      autofocus: true,
      hardwareKeyboardOnly: false,
    );
  }
}
```

- [ ] **Step 4: Implement terminal screen**

Replace `lib/features/terminal/ui/terminal_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexterm/features/terminal/providers/terminal_provider.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_tab_bar.dart';
import 'package:nexterm/features/terminal/ui/widgets/terminal_view.dart';
import 'package:nexterm/core/theme/terminal_themes.dart';
import 'package:nexterm/core/theme/theme_provider.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  final String? hostId;
  const TerminalScreen({super.key, this.hostId});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.hostId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(terminalActionsProvider).connectHost(widget.hostId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabManager = ref.watch(tabManagerProvider);
    final terminals = ref.watch(terminalControllersProvider);
    final themeState = ref.watch(themeProvider);
    final termTheme = TerminalThemes.getTheme(themeState.terminalThemeName);
    final activeTab = tabManager.activeTab;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TerminalTabBar(
              tabs: tabManager.tabs,
              activeIndex: tabManager.activeTabIndex,
              onTabSelected: (index) => tabManager.setActiveTab(index),
              onTabClosed: (id) => ref.read(terminalActionsProvider).disconnectTab(id),
              onAddTab: () => context.go('/hosts'),
            ),
            Expanded(
              child: activeTab != null && terminals.containsKey(activeTab.id)
                  ? TerminalViewWidget(
                      terminal: terminals[activeTab.id]!,
                      theme: termTheme,
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.terminal, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text('没有活动终端', style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: () => context.go('/hosts'),
                            icon: const Icon(Icons.dns),
                            label: const Text('选择主机连接'),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Verify build**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add lib/features/terminal/
git commit -m "feat: integrate xterm.dart terminal with tab management and SSH connection"
```

---

## Task 14: Mobile Keyboard Toolbar

**Files:**
- Create: `lib/features/terminal/ui/widgets/keyboard_toolbar.dart`
- Modify: `lib/features/terminal/ui/terminal_screen.dart`

- [ ] **Step 1: Create keyboard toolbar widget**

Create `lib/features/terminal/ui/widgets/keyboard_toolbar.dart`:

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardToolbar extends StatefulWidget {
  final void Function(Uint8List data) onKeyInput;
  final VoidCallback? onSnippetsTap;

  const KeyboardToolbar({
    super.key,
    required this.onKeyInput,
    this.onSnippetsTap,
  });

  @override
  State<KeyboardToolbar> createState() => _KeyboardToolbarState();
}

class _KeyboardToolbarState extends State<KeyboardToolbar> {
  bool _ctrlActive = false;
  bool _altActive = false;

  void _sendKey(String key) {
    if (_ctrlActive) {
      final code = key.toUpperCase().codeUnitAt(0) - 64;
      if (code > 0 && code < 32) {
        widget.onKeyInput(Uint8List.fromList([code]));
      }
      setState(() => _ctrlActive = false);
      return;
    }
    if (_altActive) {
      widget.onKeyInput(Uint8List.fromList([0x1B, ...key.codeUnits]));
      setState(() => _altActive = false);
      return;
    }
    widget.onKeyInput(Uint8List.fromList(key.codeUnits));
  }

  void _sendEscape(String seq) {
    widget.onKeyInput(Uint8List.fromList([0x1B, ...seq.codeUnits]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF313244) : const Color(0xFFE0E0E0);
    final btnColor = isDark ? const Color(0xFF45475A) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFCDD6F4) : const Color(0xFF1A1A1A);
    final accentColor = theme.colorScheme.primary;

    Widget toolbarBtn(String label, VoidCallback onTap, {bool isActive = false, bool isAccent = false}) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isAccent ? accentColor : (isActive ? accentColor.withAlpha(80) : btnColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              color: isAccent ? (isDark ? bgColor : Colors.white) : (isActive ? accentColor : textColor),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF45475A) : const Color(0xFFCCCCCC))),
      ),
      child: Row(
        children: [
          toolbarBtn('Tab', () => _sendKey('\t')),
          const SizedBox(width: 4),
          toolbarBtn('Ctrl', () => setState(() { _ctrlActive = !_ctrlActive; _altActive = false; }), isActive: _ctrlActive),
          const SizedBox(width: 4),
          toolbarBtn('Alt', () => setState(() { _altActive = !_altActive; _ctrlActive = false; }), isActive: _altActive),
          const SizedBox(width: 4),
          toolbarBtn('Esc', () => widget.onKeyInput(Uint8List.fromList([0x1B]))),
          const SizedBox(width: 4),
          toolbarBtn('↑', () => _sendEscape('[A')),
          const SizedBox(width: 4),
          toolbarBtn('↓', () => _sendEscape('[B')),
          const SizedBox(width: 4),
          toolbarBtn('←', () => _sendEscape('[D')),
          const SizedBox(width: 4),
          toolbarBtn('→', () => _sendEscape('[C')),
          const Spacer(),
          toolbarBtn('⚡', () => widget.onSnippetsTap?.call(), isAccent: true),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add keyboard toolbar to terminal screen**

In `lib/features/terminal/ui/terminal_screen.dart`, update the `Column` children within the `Scaffold.body` to add the toolbar between the terminal and the bottom:

Replace the `Expanded` widget section in the `build` method, specifically after the terminal view and before the closing `],` of the Column:

Find this in `terminal_screen.dart`:
```dart
            Expanded(
              child: activeTab != null && terminals.containsKey(activeTab.id)
                  ? TerminalViewWidget(
                      terminal: terminals[activeTab.id]!,
                      theme: termTheme,
                    )
                  : Center(
```

Replace with:
```dart
            Expanded(
              child: activeTab != null && terminals.containsKey(activeTab.id)
                  ? TerminalViewWidget(
                      terminal: terminals[activeTab.id]!,
                      theme: termTheme,
                    )
                  : Center(
```

Add after the `Expanded` widget closing parenthesis `)` and comma, before `],`:

```dart
            if (activeTab != null)
              KeyboardToolbar(
                onKeyInput: (data) {
                  final sshService = ref.read(sshServiceProvider);
                  sshService.write(activeTab.id, data);
                },
              ),
```

Add import at top:
```dart
import 'package:nexterm/features/terminal/ui/widgets/keyboard_toolbar.dart';
```

- [ ] **Step 3: Verify build**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/terminal/ui/
git commit -m "feat: add mobile keyboard toolbar with Ctrl/Alt/Esc/arrows and snippets button"
```

---

## Task 15: Reconnection Service

**Files:**
- Create: `lib/features/terminal/services/reconnect_service.dart`
- Test: `test/features/terminal/services/reconnect_service_test.dart`

- [ ] **Step 1: Write failing test for ReconnectService**

Create `test/features/terminal/services/reconnect_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/terminal/services/reconnect_service.dart';

void main() {
  test('calculates exponential backoff correctly', () {
    expect(ReconnectService.calculateDelay(0), equals(const Duration(seconds: 1)));
    expect(ReconnectService.calculateDelay(1), equals(const Duration(seconds: 2)));
    expect(ReconnectService.calculateDelay(2), equals(const Duration(seconds: 4)));
    expect(ReconnectService.calculateDelay(3), equals(const Duration(seconds: 8)));
    expect(ReconnectService.calculateDelay(4), equals(const Duration(seconds: 16)));
    expect(ReconnectService.calculateDelay(5), equals(const Duration(seconds: 30)));
    expect(ReconnectService.calculateDelay(10), equals(const Duration(seconds: 30)));
  });

  test('max retries defaults to 10', () {
    final service = ReconnectService(maxRetries: 10);
    expect(service.maxRetries, equals(10));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/terminal/services/reconnect_service_test.dart
```

Expected: FAIL — `reconnect_service.dart` does not exist.

- [ ] **Step 3: Implement ReconnectService**

Create `lib/features/terminal/services/reconnect_service.dart`:

```dart
import 'dart:async';
import 'dart:math';

class ReconnectService {
  static const Duration _maxDelay = Duration(seconds: 30);
  static const Duration _baseDelay = Duration(seconds: 1);

  final int maxRetries;
  final Map<String, int> _retryCounts = {};
  final Map<String, Timer?> _timers = {};
  final Map<String, bool> _cancelled = {};

  ReconnectService({this.maxRetries = 10});

  static Duration calculateDelay(int attempt) {
    final seconds = _baseDelay.inSeconds * pow(2, attempt);
    return Duration(seconds: min(seconds.toInt(), _maxDelay.inSeconds));
  }

  Future<void> scheduleReconnect({
    required String sessionId,
    required Future<bool> Function() reconnectFn,
    void Function(int attempt, Duration delay)? onRetrying,
    void Function()? onGaveUp,
    void Function()? onReconnected,
  }) async {
    _cancelled[sessionId] = false;
    _retryCounts[sessionId] = 0;

    while ((_retryCounts[sessionId] ?? 0) < maxRetries) {
      if (_cancelled[sessionId] == true) return;

      final attempt = _retryCounts[sessionId]!;
      final delay = calculateDelay(attempt);
      onRetrying?.call(attempt, delay);

      await Future.delayed(delay);

      if (_cancelled[sessionId] == true) return;

      try {
        final success = await reconnectFn();
        if (success) {
          _retryCounts.remove(sessionId);
          _cancelled.remove(sessionId);
          onReconnected?.call();
          return;
        }
      } catch (_) {
        // Retry on next attempt
      }

      _retryCounts[sessionId] = attempt + 1;
    }

    _retryCounts.remove(sessionId);
    _cancelled.remove(sessionId);
    onGaveUp?.call();
  }

  void cancelReconnect(String sessionId) {
    _cancelled[sessionId] = true;
    _timers[sessionId]?.cancel();
    _timers.remove(sessionId);
    _retryCounts.remove(sessionId);
  }

  void cancelAll() {
    for (final id in _cancelled.keys.toList()) {
      cancelReconnect(id);
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/terminal/services/reconnect_service_test.dart -v
```

Expected: All 2 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/terminal/services/reconnect_service.dart test/features/terminal/services/reconnect_service_test.dart
git commit -m "feat: add exponential backoff reconnection service"
```

---

## Summary

Phase 1 delivers a working SSH terminal client with:

- **15 tasks**, each independently implementable and testable
- **Host management**: CRUD, groups, tags, favorites, search
- **Key management**: generate Ed25519/RSA/ECDSA, import, copy public key
- **SSH terminal**: dartssh2 + xterm.dart, multi-tab, password/key auth
- **Mobile UX**: keyboard toolbar (Ctrl/Alt/Esc/arrows), status indicators
- **Infrastructure**: Drift DB, Riverpod state, GoRouter, light/dark themes, AES-256-GCM crypto
- **Reconnection**: exponential backoff with configurable max retries

After Phase 1 is complete, proceed to **Phase 2: Snippets + Port Forwarding**.
