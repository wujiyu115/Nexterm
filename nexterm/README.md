# Nexterm — Flutter 客户端

Nexterm 移动端是基于 Flutter 构建的跨平台 SSH 终端应用，支持 iOS 和 Android。采用清洁架构（Clean Architecture）分层，通过 Riverpod 2 管理状态，Drift 提供本地数据库支持。

---

## 前置条件

| 工具 | 最低版本 |
|------|---------|
| Flutter | 3.29.0 |
| Dart SDK | 3.7.0 |
| Xcode（iOS 构建）| 15+ |
| Android Studio / SDK | API 21+ |

---

## 快速开始

```bash
# 1. 进入应用目录
cd nexterm

# 2. 安装依赖
flutter pub get

# 3. 代码生成（Drift DAO + Riverpod Provider + Mockito mock）
dart run build_runner build --delete-conflicting-outputs

# 4. 运行应用
flutter run
```

> 代码生成产物（`*.g.dart`）已提交到仓库，日常开发无需重新执行步骤 3，除非修改了带注解的文件。

---

## 项目架构

```
lib/
├── main.dart               # 应用入口，初始化 ProviderScope
├── app.dart                # MaterialApp + GoRouter 配置
├── core/
│   ├── crypto/             # AES-256-GCM 加密服务（CryptoService）
│   ├── router/             # go_router 路由定义（AppRouter）
│   └── theme/              # 应用主题与终端配色方案
├── data/
│   ├── database/
│   │   ├── app_database.dart   # Drift 数据库根类
│   │   ├── tables/             # 表定义（hosts, ssh_keys, snippets, port_forwards, settings）
│   │   └── daos/               # 数据访问对象
│   └── repositories/       # Repository 实现（直接操作 DAO）
├── domain/
│   ├── entities/           # 纯 Dart 实体（HostEntity, SSHKeyEntity 等）
│   └── repositories/       # Repository 抽象接口
├── features/               # 功能模块（见下节）
└── shared/
    └── widgets/            # 全局共用 Widget（AppScaffold, StatusIndicator）
```

### 分层说明

- **core** — 不依赖任何业务逻辑的基础设施（加密、路由、主题）。
- **data** — 具体的数据读写实现；依赖 `domain` 接口，不依赖 `features`。
- **domain** — 实体与 Repository 接口；纯 Dart，无 Flutter 依赖。
- **features** — 每个功能模块各自包含 `ui/`、`providers/`、`services/` 三个子层。

---

## 功能模块

| 模块 | 路径 | 说明 |
|------|------|------|
| **terminal** | `features/terminal/` | SSH 会话管理、多标签、PTY 渲染、自动重连 |
| **hosts** | `features/hosts/` | 主机的增删改查、跳板机配置、最近连接记录 |
| **keys** | `features/keys/` | SSH 密钥管理，支持 RSA/ED25519 生成与导入 |
| **snippets** | `features/snippets/` | 可复用命令片段，支持 `{{variable}}` 变量占位符 |
| **forwarding** | `features/forwarding/` | 本地 / 远程 / 动态端口转发，支持随连接自启动 |
| **sftp** | `features/sftp/` | 远程文件浏览、上传下载、chmod、在线代码编辑 |
| **sync** | `features/sync/` | 端对端加密云同步、JWT 认证、设备管理 |
| **settings** | `features/settings/` | 主题切换、主密码、生物识别、加密备份与恢复 |

---

## 关键依赖

| 包名 | 版本 | 用途 |
|------|------|------|
| `flutter_riverpod` | ^2.6.1 | 状态管理 |
| `riverpod_annotation` | ^2.6.1 | Riverpod 代码生成注解 |
| `go_router` | ^14.8.1 | 声明式路由 |
| `drift` | ^2.23.1 | 类型安全 SQLite ORM |
| `dartssh2` | ^2.14.0 | SSH2 协议实现（含 SFTP） |
| `xterm` | ^4.0.0 | 终端模拟器 Widget |
| `pointycastle` | ^3.9.1 | AES-256-GCM 加密 + PBKDF2 |
| `dio` | ^5.7.0 | HTTP 客户端（云同步 API） |
| `flutter_secure_storage` | ^9.2.4 | 系统钥匙串 / Keystore 存储 |
| `local_auth` | ^3.0.1 | Face ID / Touch ID 生物识别 |
| `flutter_highlight` | ^0.7.0 | 代码语法高亮（SFTP 编辑器） |

---

## 测试

```bash
# 运行所有测试
flutter test

# 运行指定测试文件
flutter test test/core/crypto/crypto_service_test.dart

# 生成覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 测试结构

```
test/
├── core/crypto/            # CryptoService 单元测试
├── data/repositories/      # Repository 实现测试（使用 in-memory Drift）
├── features/
│   ├── terminal/services/  # SSHService、ReconnectService 测试
│   ├── sync/services/      # SyncService 加解密测试
│   ├── sftp/               # SftpService、TransferProvider 测试
│   ├── forwarding/         # PortForwardService 测试
│   ├── snippets/           # VariableParser 测试
│   └── settings/           # SettingsProvider、SshConfigParser 测试
└── widget_test.dart        # 应用根 Widget 冒烟测试
```

---

## 构建

### iOS

```bash
# 调试包
flutter build ios --debug

# 发布包（需配置签名证书）
flutter build ios --release
```

### Android

```bash
# APK（调试）
flutter build apk --debug

# AAB（发布，上传 Google Play）
flutter build appbundle --release
```

---

## 代码生成说明

本项目使用以下代码生成工具：

- **drift_dev** — 根据表定义生成 DAO 实现（`*.g.dart`）。
- **riverpod_generator** — 根据 `@riverpod` 注解生成 Provider（`*.g.dart`）。
- **mockito** — 根据 `@GenerateMocks` 注解生成测试 Mock。

修改任何带注解的文件后，需重新执行：

```bash
dart run build_runner build --delete-conflicting-outputs
```
