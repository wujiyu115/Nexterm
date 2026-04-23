### integrate-vaults-navigation ###

# 任务清单

## 1. 国际化更新
- [x] 1.1 在 `app_en.arb` 中添加 nav_vaults、nav_connections、nav_profile、vaults_*、knownHosts_*、logs_* 等新 key
- [x] 1.2 在 `app_zh.arb` 中添加对应的中文翻译
- [x] 1.3 在 `app_localizations.dart` 中添加新 key 的抽象 getter 定义
- [x] 1.4 在 `app_localizations_en.dart` 中实现英文翻译
- [x] 1.5 在 `app_localizations_zh.dart` 中实现中文翻译

## 2. 创建 Vaults 功能模块
- [x] 2.1 创建 `features/vaults/ui/vaults_screen.dart` — Vaults 主页面，展示功能入口列表（Hosts/Port Forwarding/Snippets/Keychain/Known Hosts/Logs）
- [x] 2.2 创建 `features/vaults/ui/known_hosts_screen.dart` — Known Hosts 占位页面
- [x] 2.3 创建 `features/vaults/ui/logs_screen.dart` — Logs 占位页面

## 3. 重构路由配置
- [x] 3.1 修改 `app_router.dart`：将 6 branch 重构为 3 branch（Vaults/Connections/Profile），初始路径改为 `/vaults`，将 Hosts/Keys/Snippets/Forwarding/KnownHosts/Logs 作为 Vaults 的子路由

## 4. 修改底部导航栏
- [x] 4.1 修改 `app_scaffold.dart`：将 6 个 NavigationDestination 改为 3 个（Vaults/Connections/Profile），调整 hasActiveTerminal 判断逻辑

## 5. 各子页面改造 — 添加返回按钮和路由路径更新
- [x] 5.1 修改 `hosts_screen.dart`：AppBar 添加返回 Vaults 的按钮，更新路由路径（`/hosts/add` → `/vaults/hosts/add` 等）
- [x] 5.2 修改 `keys_screen.dart`：AppBar 添加返回按钮，更新路由路径（`/keys/*` → `/vaults/keys/*`）
- [x] 5.3 修改 `forwarding_screen.dart`：AppBar 添加返回按钮，更新路由路径（`/forwarding/*` → `/vaults/forwarding/*`）
- [x] 5.4 修改 `snippets_screen.dart`：AppBar 添加返回按钮，更新路由路径（`/snippets/*` → `/vaults/snippets/*`）

## 6. 其他路由引用更新
- [x] 6.1 检查并更新 `hosts_screen.dart` 中所有 `context.push` 路径引用
- [x] 6.2 检查并更新 `host_context_menu.dart` 中的路由引用（无需修改，不含路由引用）
- [x] 6.3 检查并更新 `keys_screen.dart` 中 _buildEmptyState 的路由引用
- [x] 6.4 检查并更新其他文件中对旧路由路径的引用（全局搜索确认无遗漏）

## 7. 验证
- [x] 7.1 运行 `flutter analyze` 检查编译错误（通过，仅有5个预存info级别提示）
- [x] 7.2 运行 `flutter test` 检查测试是否通过（150/150全部通过）


updateAtTime: 2026/4/23 11:37:14

planId: 1f1854fd-f914-45e0-a86c-c98eb0c75d55