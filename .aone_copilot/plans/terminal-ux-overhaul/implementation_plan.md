### terminal-ux-overhaul ###
对 Nexterm 进行三大模块的 UX 改造：1) 主机列表长按上下文菜单；2) 终端快捷键工具栏重构（分组+滑动+自定义排序+恢复默认）；3) ABC/功能键模式切换与命令历史面板。

# 终端 UX 全面改造

本次改造涉及三大模块：主机列表交互、终端键盘工具栏重构、功能键面板与命令历史。

## Proposed Changes

---

### 模块一：主机长按上下文菜单

将当前的"长按直接编辑"改为"长按弹出上下文菜单"，菜单项包含：连接、SFTP连接、复制、移动到组、编辑、选中(多选)、删除。

#### [MODIFY] [host_list_tile.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/hosts/ui/widgets/host_list_tile.dart)

- 移除 `onLongPress: onEdit`
- 新增 `onLongPress` 触发 `showModalBottomSheet` 或 `showCupertinoModalPopup` 弹出上下文菜单
- 菜单项：
  1. **连接** (Connect) — 调用 `onTap` 逻辑
  2. **SFTP 连接** (Connect via SFTP) — 路由到 SFTP 页面
  3. **复制** (Duplicate) — 复制当前主机配置创建新主机
  4. **移动到组** (Move to group) — 弹出分组选择对话框
  5. **编辑** (Edit) — 路由到编辑页面
  6. **选中** (Select) — 进入多选模式
  7. **删除** (Delete) — 确认后删除，红色高亮

#### [MODIFY] [hosts_screen.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/hosts/ui/hosts_screen.dart)

- 新增多选模式状态 `_isSelectionMode` 和 `_selectedIds`
- 新增批量操作栏（多选模式下显示：全选、删除、移动到组）
- 新增 `_duplicateHost()` 方法：复制主机配置
- 新增 `_moveToGroup()` 方法：弹出分组选择对话框
- 新增 `_showContextMenu()` 方法：构建上下文菜单

#### [NEW] [host_context_menu.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/hosts/ui/widgets/host_context_menu.dart)

- 独立的上下文菜单组件
- 使用 `showCupertinoModalPopup` 实现 iOS 风格弹出菜单
- 每个菜单项带图标和文字，删除项红色高亮

#### [MODIFY] [hosts_provider.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/hosts/providers/hosts_provider.dart)

- 新增 `duplicateHost(String hostId)` 方法
- 新增 `moveToGroup(String hostId, String? group)` 方法
- 新增 `moveMultipleToGroup(List<String> ids, String? group)` 方法

---

### 模块二：终端快捷键工具栏重构

将固定的单行工具栏改造为：可左右滑动、按组分类、支持自定义排序和恢复默认值。

#### [NEW] [toolbar_key_definition.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/models/toolbar_key_definition.dart)

- 定义 `ToolbarKeyDef` 数据类：`id`, `label`, `groupId`, `bytes` (发送的字节序列)
- 定义 `ToolbarKeyGroup` 数据类：`id`, `name`, `keys` (组内按键列表)
- 定义默认按键分组（参考 Termius 截图）：
  - 基础功能组：shift+tab, ?, /, |
  - 终端控制组：esc, tab, ctrl, alt
  - 信号组：^C, ^I, ^S, ^Z
  - 符号组1：/, |, ~, -
  - 导航组：home, pgUp, pgDn, end
  - 标点组：=, :, ;, !
  - 符号组2：*, $, %, ^
  - 括号组1：<, >, (, )
  - 括号组2：{, }, [, ]
  - 编辑组：paste, del, ins, @
  - F键组1：F1, F2, F3, F4
  - F键组2：F5, F6, F7, F8
  - F键组3：F9, F10, F11, F12
  - 高级控制组：^_, ^L, Alt-r, ^X^X
  - 搜索组：^R, ^G, ^N, ^P
  - 方向键组：←, ↑, ↓, →

#### [NEW] [toolbar_config_provider.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/providers/toolbar_config_provider.dart)

- 使用 `AppSettings` 表持久化用户自定义的工具栏配置
- 存储格式：JSON 序列化的分组顺序和启用/禁用状态
- 提供 `restoreDefaults()` 方法恢复默认配置
- 提供 `reorderGroup()` 方法调整分组顺序
- 提供 `removeGroup()` / `addGroup()` 方法

#### [MODIFY] [keyboard_toolbar.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/ui/widgets/keyboard_toolbar.dart)

- 重构为可滑动的分组工具栏
- 使用 `SingleChildScrollView` + `Row` 实现水平滚动
- 每组按键之间用分隔符分隔
- 第一行显示当前活动组的按键（可滑动）
- 保留 Ctrl/Alt 修饰键的 toggle 逻辑

#### [NEW] [toolbar_customize_screen.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/ui/toolbar_customize_screen.dart)

- 自定义键盘配置页面（如截图中的 "Customize Keyboard"）
- 顶部预览栏：显示当前工具栏效果
- 列表：每个分组一行，显示组内按键，左侧红色删除按钮，右侧拖拽排序手柄
- 顶部 "+" 按钮：添加新的按键组
- 右上角 "..." 菜单：Restore Defaults 恢复默认
- 使用 `ReorderableListView` 实现拖拽排序

---

### 模块三：ABC/功能键模式切换 + 命令历史面板

在终端界面添加 ABC/功能键切换按钮，功能键模式下隐藏系统键盘，显示自定义面板（含多个 tab）。

#### [MODIFY] [terminal_screen.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/ui/terminal_screen.dart)

- 新增 `_keyboardMode` 状态：`abc` (系统键盘+快捷键栏) / `function` (自定义面板)
- ABC 模式：显示系统键盘 + 快捷键工具栏（现有行为）
- 功能键模式：隐藏系统键盘，显示自定义功能面板
- 在 tab bar 右侧或工具栏末尾添加 ABC/功能键切换按钮

#### [NEW] [function_panel.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/ui/widgets/function_panel.dart)

- 功能键模式下的主面板容器
- 底部 TabBar 包含 4 个 tab：
  1. **代码** `{}` — 常用代码片段/Snippets 快捷执行
  2. **历史** `⏱` — 命令历史记录列表（带搜索）
  3. **帮助** `?` — 常用快捷键参考卡片
  4. **键盘** `⌨` — 切回系统键盘（即切换到 ABC 模式）

#### [NEW] [command_history_panel.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/ui/widgets/command_history_panel.dart)

- 命令历史面板
- 顶部搜索栏
- 列表显示历史命令，点击即发送到终端
- 数据来源：
  1. **本地记录**（优先）：拦截 `terminal.onOutput` 中用户输入的命令
  2. **远程 history**：通过 SSH 执行 `history` 命令获取

#### [NEW] [command_history_service.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/services/command_history_service.dart)

- 本地命令历史记录服务
- 拦截用户在终端中按下 Enter 时的输入内容
- 存储到内存列表（按会话隔离）
- 提供 `fetchRemoteHistory(sessionId)` 方法：通过 SSH 执行 `HISTFILE=~/.bash_history && history 100` 获取远程历史
- 提供 `search(query)` 方法：模糊搜索历史命令
- 提供 `getAll(sessionId)` 方法：获取某会话的所有历史

#### [NEW] [command_history_provider.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/providers/command_history_provider.dart)

- Riverpod Provider 封装命令历史服务
- 提供按会话 ID 查询的接口

#### [MODIFY] [terminal_provider.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/providers/terminal_provider.dart)

- 在 `terminal.onOutput` 回调中拦截用户输入，记录到 `CommandHistoryService`
- 检测 `\r` 或 `\n` 作为命令提交的信号

#### [MODIFY] [terminal_view.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/terminal/ui/widgets/terminal_view.dart)

- 支持在功能键模式下关闭系统软键盘（`hardwareKeyboardOnly: true`）
- 通过外部状态控制键盘模式

---

### 路由与导航

#### [MODIFY] [app_router.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/core/router/app_router.dart)

- 新增路由：`/terminal/customize-keyboard` → `ToolbarCustomizeScreen`

---

## Verification Plan

### Automated Tests
- 运行 `flutter analyze` 确保无 lint 错误
- 运行现有测试确保无回归

### Manual Verification
1. **主机长按菜单**：长按主机 → 弹出菜单 → 逐一测试每个菜单项
2. **快捷键工具栏**：左右滑动 → 进入自定义页面 → 拖拽排序 → 恢复默认
3. **ABC/功能键切换**：点击切换按钮 → 系统键盘隐藏 → 功能面板显示 → 切换 tab
4. **命令历史**：输入几条命令 → 切换到历史 tab → 搜索 → 点击发送 → 拉取远程 history

updateAtTime: 2026/4/21 23:24:53

planId: 617929ab-2995-46db-9297-80fa699853b3