### terminal-ux-overhaul ###
# 终端 UX 全面改造 - 任务清单

## 模块一：主机长按上下文菜单

- [x] 1.1 在 `hosts_provider.dart` 中新增 `duplicateHost`、`moveToGroup`、`moveMultipleToGroup` 方法
- [x] 1.2 创建 `host_context_menu.dart` 上下文菜单组件（iOS 风格弹出菜单，7 个菜单项）
- [x] 1.3 修改 `host_list_tile.dart`：长按触发上下文菜单（替代直接编辑）
- [x] 1.4 修改 `hosts_screen.dart`：新增多选模式状态、批量操作栏、分组选择对话框
- [ ] 1.5 验证主机长按菜单所有功能项（连接、SFTP、复制、移动到组、编辑、选中、删除）

## 模块二：终端快捷键工具栏重构

- [x] 2.1 创建 `toolbar_key_definition.dart`：定义按键和分组的数据模型 + 默认分组配置
- [x] 2.2 创建 `toolbar_config_provider.dart`：工具栏配置持久化（AppSettings 存储 + 恢复默认）
- [x] 2.3 重构 `keyboard_toolbar.dart`：改为可滑动分组工具栏（SingleChildScrollView + 分组分隔）
- [x] 2.4 创建 `toolbar_customize_screen.dart`：自定义键盘配置页面（预览栏 + 拖拽排序 + 删除/添加组 + 恢复默认）
- [x] 2.5 修改 `app_router.dart`：新增 `/terminal/customize-keyboard` 路由
- [ ] 2.6 验证工具栏滑动、自定义排序、恢复默认功能

## 模块三：ABC/功能键模式切换 + 命令历史

- [x] 3.1 创建 `command_history_service.dart`：本地命令记录 + 远程 history 拉取 + 搜索
- [x] 3.2 创建 `command_history_provider.dart`：Riverpod Provider 封装
- [x] 3.3 修改 `terminal_provider.dart`：在 onOutput 中拦截用户输入记录到历史服务
- [x] 3.4 创建 `command_history_panel.dart`：命令历史面板（搜索栏 + 列表 + 点击发送）
- [x] 3.5 创建 `function_panel.dart`：功能面板容器（底部 4 个 tab：代码/历史/帮助/键盘）
- [x] 3.6 修改 `terminal_screen.dart`：新增 ABC/功能键切换按钮和模式状态
- [x] 3.7 修改 `terminal_view.dart`：支持功能键模式下关闭系统软键盘
- [ ] 3.8 验证 ABC/功能键切换、命令历史搜索和发送、远程 history 拉取

## 收尾

- [x] 4.1 运行 `flutter analyze` 确保无 lint 错误
- [ ] 4.2 提交并推送所有改动

updateAtTime: 2026/4/21 23:24:53

planId: 617929ab-2995-46db-9297-80fa699853b3