### key-import-export ###

# 密钥导入/导出/粘贴功能 — 任务清单

## Provider 层

- [x] 在 `keys_provider.dart` 中新增 `_parsePrivateKeyPem()` 辅助函数，解析 OpenSSH PEM 格式私钥，提取密钥类型、公钥字符串、指纹
- [x] 在 `keys_provider.dart` 中新增 `_detectKeyType()` 辅助函数，根据 PEM 内容判断密钥类型
- [x] 在 `KeysNotifier` 中新增 `importKey()` 方法，接收名称、PEM 文本、可选密码短语，调用解析函数后存入数据库
- [x] 在 `KeysNotifier` 中新增 `exportKey()` 方法，将密钥内容写入临时文件并通过 `share_plus` 分享

## UI 层 — 导入页面

- [x] 新建 `key_import_screen.dart`，实现密钥导入页面框架（名称输入、Tab 切换、密码短语输入、导入按钮）
- [x] 实现「从文件导入」Tab：使用 `file_picker` 选择私钥文件并读取内容
- [x] 实现「粘贴密钥」Tab：多行文本输入框，支持粘贴 PEM 格式私钥

## UI 层 — 修改现有页面

- [x] 修改 `keys_screen.dart`：AppBar 新增「导入密钥」按钮，空状态页增加「导入密钥」入口
- [x] 修改 `key_list_tile.dart`：PopupMenu 新增「导出私钥」和「导出公钥」菜单项及处理逻辑

## 路由层

- [x] 修改 `app_router.dart`：在 `/keys` 路由下注册 `/keys/import` 子路由

## 验证

- [x] 运行 `flutter analyze` 确保无编译错误
- [x] 运行 `flutter test` 确保现有测试通过
- [ ] 手动验证文件导入、粘贴导入、导出功能在模拟器/真机上正常工作


updateAtTime: 2026/4/19 19:55:19

planId: 4830ad31-638f-4878-a631-9211990ae00d