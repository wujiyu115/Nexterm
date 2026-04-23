### integrate-vaults-navigation ###
将密钥(Keychain)、端口转发(Port Forwarding)、主机(Hosts)、代码片段(Snippets)等功能整合到 Vaults 页面中，重构底部导航栏为 Vaults/Connections/Profile 三个 tab，并在 Vaults 内实现子页面导航（点击入口进入子页面，子页面有返回按钮）。


# 将密钥、端口转发、主机等功能集成到 Vaults 页面

## 背景描述
当前应用底部导航栏有 6 个独立 tab（Hosts、Terminal、Keys、Snippets、Forwarding、Settings），需要将其重构为 3 个 tab（Vaults、Connections、Profile），其中 Vaults 作为一个聚合入口页面，包含 Hosts、Port Forwarding、Snippets、Keychain、Known Hosts、Logs 等子功能入口。点击某个入口后进入对应的子页面，子页面顶部有返回按钮可以回到 Vaults 列表。

## User Review Required

> [!IMPORTANT]
> **底部导航栏变更**：底部导航从 6 个 tab（Hosts/Terminal/Keys/Snippets/Forwarding/Settings）变为 3 个 tab（Vaults/Connections/Profile）。
> - **Vaults** = 原来的 Hosts + Keys + Snippets + Forwarding + Known Hosts + Logs
> - **Connections** = 原来的 Terminal
> - **Profile** = 原来的 Settings

> [!WARNING]
> Known Hosts 和 Logs 功能目前项目中没有对应的独立 Screen 实现，本次只添加占位入口（空页面），后续再补充具体功能。

---

## Proposed Changes

### Vaults 页面组件

#### [NEW] [vaults_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/vaults/ui/vaults_screen.dart)

创建 Vaults 主页面，展示功能入口列表。页面结构：
- 顶部显示 "Personal Vault" 标题（带下拉箭头图标）
- 列表项：Hosts、Port Forwarding、Snippets、Keychain、Known Hosts、Logs
- 每个列表项带图标、标题、右箭头，点击后通过 `Navigator.push` 进入子页面

```dart
// 列表入口定义
final _vaultItems = [
  _VaultItem(icon: Icons.dns_outlined, title: 'Hosts', route: '/vaults/hosts'),
  _VaultItem(icon: Icons.swap_horiz_outlined, title: 'Port Forwarding', route: '/vaults/forwarding'),
  _VaultItem(icon: Icons.bolt_outlined, title: 'Snippets', route: '/vaults/snippets'),
  _VaultItem(icon: Icons.vpn_key_outlined, title: 'Keychain', route: '/vaults/keys'),
  _VaultItem(icon: Icons.wifi_tethering_outlined, title: 'Known Hosts', route: '/vaults/known-hosts'),
  _VaultItem(icon: Icons.receipt_long_outlined, title: 'Logs', route: '/vaults/logs'),
];
```

#### [NEW] [known_hosts_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/vaults/ui/known_hosts_screen.dart)

Known Hosts 占位页面，展示空状态提示。

#### [NEW] [logs_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/vaults/ui/logs_screen.dart)

Logs 占位页面，展示空状态提示。

---

### 子页面返回导航改造

#### [MODIFY] [hosts_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/hosts/ui/hosts_screen.dart)

为非选择模式下的 AppBar 添加返回按钮（leading），点击后返回 Vaults 页面。AppBar title 改为大标题 "Hosts" 样式。

```diff
- AppBar(
-   title: Text(l.hosts_title),
+ AppBar(
+   leading: IconButton(
+     icon: const Icon(Icons.chevron_left),
+     onPressed: () => Navigator.of(context).pop(),
+   ),
+   title: Text(l.nav_vaults),
```

#### [MODIFY] [keys_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/keys/ui/keys_screen.dart)

为 AppBar 添加返回按钮，点击后返回 Vaults。

#### [MODIFY] [forwarding_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/forwarding/ui/forwarding_screen.dart)

为 AppBar 添加返回按钮，点击后返回 Vaults。

#### [MODIFY] [snippets_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/snippets/ui/snippets_screen.dart)

为 AppBar 添加返回按钮，点击后返回 Vaults。

---

### 路由重构

#### [MODIFY] [app_router.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/core/router/app_router.dart)

将路由从 6 branch 重构为 3 branch：

```dart
branches: [
  // Vaults branch
  StatefulShellBranch(routes: [
    GoRoute(
      path: '/vaults',
      builder: (context, state) => const VaultsScreen(),
      routes: [
        // Hosts 子路由
        GoRoute(path: 'hosts', builder: ..., routes: [add, edit/:id]),
        // Keys 子路由
        GoRoute(path: 'keys', builder: ..., routes: [generate, import]),
        // Snippets 子路由
        GoRoute(path: 'snippets', builder: ..., routes: [add, edit/:id]),
        // Forwarding 子路由
        GoRoute(path: 'forwarding', builder: ..., routes: [add, edit/:id]),
        // Known Hosts 子路由
        GoRoute(path: 'known-hosts', builder: ...),
        // Logs 子路由
        GoRoute(path: 'logs', builder: ...),
      ],
    ),
  ]),
  // Connections branch (原 Terminal)
  StatefulShellBranch(routes: [
    GoRoute(path: '/connections', builder: (context, state) => const TerminalScreen()),
  ]),
  // Profile branch (原 Settings)
  StatefulShellBranch(routes: [
    GoRoute(path: '/profile', builder: (context, state) => const SettingsScreen()),
  ]),
]
```

- `initialLocation` 从 `/hosts` 改为 `/vaults`
- 原有的 `/terminal/connect/:hostId` 路由路径保持不变

---

### 底部导航栏改造

#### [MODIFY] [app_scaffold.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/shared/widgets/app_scaffold.dart)

将底部导航栏从 6 个项缩减为 3 个：
- **Vaults**（icon: `Icons.lock_outlined` / `Icons.lock`）
- **Connections**（icon: `Icons.terminal_outlined` / `Icons.terminal`）
- **Profile**（icon: `Icons.person_outline` / `Icons.person`）

```diff
- destinations: [
-   NavigationDestination(icon: ..., label: l.nav_hosts),
-   NavigationDestination(icon: ..., label: l.nav_terminal),
-   NavigationDestination(icon: ..., label: l.nav_keys),
-   NavigationDestination(icon: ..., label: l.nav_snippets),
-   NavigationDestination(icon: ..., label: l.nav_forwarding),
-   NavigationDestination(icon: ..., label: l.nav_settings),
- ]
+ destinations: [
+   NavigationDestination(icon: Icon(Icons.lock_outlined), selectedIcon: Icon(Icons.lock), label: l.nav_vaults),
+   NavigationDestination(icon: Icon(Icons.terminal_outlined), selectedIcon: Icon(Icons.terminal), label: l.nav_connections),
+   NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: l.nav_profile),
+ ]
```

隐藏底部栏的逻辑也需调整：`hasActiveTerminal` 判断改为 `navigationShell.currentIndex == 1`。

---

### 国际化

#### [MODIFY] [app_en.arb](file:///home/ejoy/git/Nexterm/nexterm/lib/l10n/app_en.arb)

新增国际化 key：
```json
"nav_vaults": "Vaults",
"nav_connections": "Connections",
"nav_profile": "Profile",
"vaults_title": "Personal Vault",
"vaults_hosts": "Hosts",
"vaults_portForwarding": "Port Forwarding",
"vaults_snippets": "Snippets",
"vaults_keychain": "Keychain",
"vaults_knownHosts": "Known Hosts",
"vaults_logs": "Logs",
"knownHosts_title": "Known Hosts",
"knownHosts_empty": "No known hosts yet",
"logs_title": "Logs",
"logs_empty": "No logs yet"
```

#### [MODIFY] [app_zh.arb](file:///home/ejoy/git/Nexterm/nexterm/lib/l10n/app_zh.arb)

新增中文翻译：
```json
"nav_vaults": "保险库",
"nav_connections": "连接",
"nav_profile": "我的",
"vaults_title": "个人保险库",
"vaults_hosts": "主机",
"vaults_portForwarding": "端口转发",
"vaults_snippets": "代码片段",
"vaults_keychain": "密钥",
"vaults_knownHosts": "已知主机",
"vaults_logs": "日志",
"knownHosts_title": "已知主机",
"knownHosts_empty": "暂无已知主机",
"logs_title": "日志",
"logs_empty": "暂无日志"
```

#### [MODIFY] [app_localizations.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/l10n/app_localizations.dart)

添加新 key 的抽象 getter 定义。

#### [MODIFY] [app_localizations_en.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/l10n/app_localizations_en.dart)

实现新 key 的英文翻译。

#### [MODIFY] [app_localizations_zh.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/l10n/app_localizations_zh.dart)

实现新 key 的中文翻译。

---

### 各子页面路由引用更新

#### [MODIFY] [hosts_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/hosts/ui/hosts_screen.dart)

路由 push 路径更新：`/hosts/add` → `/vaults/hosts/add`，`/hosts/edit/:id` → `/vaults/hosts/edit/:id`。

#### [MODIFY] [keys_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/keys/ui/keys_screen.dart)

路由 push 路径更新：`/keys/generate` → `/vaults/keys/generate`，`/keys/import` → `/vaults/keys/import`。

#### [MODIFY] [forwarding_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/forwarding/ui/forwarding_screen.dart)

路由 push 路径更新：`/forwarding/add` → `/vaults/forwarding/add`，`/forwarding/edit/:id` → `/vaults/forwarding/edit/:id`。

#### [MODIFY] [snippets_screen.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/snippets/ui/snippets_screen.dart)

路由 push 路径更新：`/snippets/add` → `/vaults/snippets/add`，`/snippets/edit/:id` → `/vaults/snippets/edit/:id`。

#### [MODIFY] [host_context_menu.dart](file:///home/ejoy/git/Nexterm/nexterm/lib/features/hosts/ui/widgets/host_context_menu.dart)

检查是否有路由引用需要更新。

---

## Verification Plan

### Automated Tests
- 运行 `flutter analyze` 确认无编译错误
- 运行 `flutter test` 确认现有测试通过

### Manual Verification
- 启动应用，确认底部导航栏只有 Vaults / Connections / Profile 三个 tab
- 点击 Vaults tab，确认显示 6 个入口项列表
- 依次点击 Hosts / Port Forwarding / Snippets / Keychain 入口，确认进入对应子页面
- 确认子页面顶部有返回按钮，点击可返回 Vaults 列表
- 确认 Known Hosts / Logs 入口进入占位空页面
- 确认从 Hosts 页面连接 SSH、编辑主机等功能正常
- 确认 Connections tab（终端）功能正常
- 确认 Profile tab（设置）功能正常


updateAtTime: 2026/4/23 11:37:14

planId: 1f1854fd-f914-45e0-a86c-c98eb0c75d55