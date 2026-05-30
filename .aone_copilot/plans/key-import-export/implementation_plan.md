### key-import-export ###
为密钥管理模块添加文件导入、文件导出和粘贴导入三种密钥管理功能，使用户可以从文件或剪贴板导入已有的 SSH 密钥，也可以将密钥导出为文件。


# 密钥导入/导出/粘贴功能

为密钥管理模块补充文件导入、文件导出、粘贴密钥三大功能，使用户可以方便地管理已有的 SSH 密钥。

## Proposed Changes

### Keys Provider 层 — 新增导入/导出业务逻辑

#### [MODIFY] [keys_provider.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/keys/providers/keys_provider.dart)

在 `KeysNotifier` 中新增以下方法：

- **`importKeyFromPem()`**：接收私钥 PEM 文本和名称，解析出公钥和指纹，创建 `SSHKeyEntity` 并存入数据库
- **`exportKeyToFile()`**：将私钥/公钥写入文件（使用 `share_plus` 或 `file_picker` 的保存功能）

新增辅助函数：
- **`_parsePrivateKeyPem()`**：解析 OpenSSH 格式的私钥 PEM，提取密钥类型、公钥、指纹等信息
- **`_detectKeyType()`**：根据 PEM 内容中的算法标识判断密钥类型（ed25519/rsa/ecdsa）

```diff
+ /// Parses an OpenSSH private key PEM and extracts key metadata.
+ /// Returns [keyType, publicKeyString, fingerprint] or throws on invalid input.
+ List<dynamic> _parsePrivateKeyPem(String pem, String comment) { ... }
+
+ /// Imports a key from PEM text (file content or pasted text).
+ Future<SSHKeyEntity?> importKey({
+   required String name,
+   required String privateKeyPem,
+   String? passphrase,
+ }) async { ... }
+
+ /// Exports a key's private/public key to a file via share sheet.
+ Future<void> exportKey(SSHKeyEntity key, {bool publicOnly = false}) async { ... }
```

---

### Keys UI 层 — 新增导入页面

#### [NEW] [key_import_screen.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/keys/ui/key_import_screen.dart)

新建密钥导入页面，包含两种导入方式：

1. **文件导入**：使用 `file_picker` 选择本地 `.pem` / `id_rsa` / `id_ed25519` 等私钥文件
2. **粘贴导入**：提供多行文本输入框，用户可粘贴 PEM 格式的私钥内容

页面结构：
- 密钥名称输入框
- Tab 切换：「从文件导入」/「粘贴密钥」
- 文件导入 Tab：文件选择按钮 + 已选文件名展示
- 粘贴导入 Tab：多行 TextFormField，hint 为 `-----BEGIN OPENSSH PRIVATE KEY-----`
- 密码短语输入框（可选，用于加密的私钥）
- 导入按钮

---

### Keys UI 层 — 修改密钥列表页

#### [MODIFY] [keys_screen.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/keys/ui/keys_screen.dart)

- AppBar actions 中新增「导入密钥」按钮（`Icons.file_upload_outlined`），点击跳转到 `key_import_screen`
- 空状态页面增加「导入密钥」按钮

```diff
  actions: [
+   IconButton(
+     icon: const Icon(Icons.file_upload_outlined),
+     tooltip: '导入密钥',
+     onPressed: () => context.push('/keys/import'),
+   ),
    IconButton(
      icon: const Icon(Icons.add),
      tooltip: '生成密钥',
      onPressed: () => context.push('/keys/generate'),
    ),
  ],
```

---

### Keys UI 层 — 修改密钥列表项菜单

#### [MODIFY] [key_list_tile.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/features/keys/ui/widgets/key_list_tile.dart)

在 PopupMenuButton 中新增导出选项：

- **导出私钥**：通过 `share_plus` 分享私钥 PEM 文件
- **导出公钥**：通过 `share_plus` 分享公钥文件

```diff
  enum _KeyAction {
    copyPublicKey,
+   exportPrivateKey,
+   exportPublicKey,
    delete,
  }
```

新增菜单项和对应的处理逻辑，使用 `share_plus` 的 `Share.shareXFiles` 将密钥内容写入临时文件后分享。

---

### 路由层 — 注册导入页面路由

#### [MODIFY] [app_router.dart](file:///Users/yitouxiaomaolv/git/Nexterm/nexterm/lib/core/router/app_router.dart)

在 `/keys` 路由下新增 `import` 子路由：

```diff
  GoRoute(
    path: '/keys',
    builder: (context, state) => const KeysScreen(),
    routes: [
      GoRoute(path: 'generate', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const KeyGenerateScreen()),
+     GoRoute(path: 'import', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const KeyImportScreen()),
    ],
  ),
```

---

## Verification Plan

### Automated Tests

- 运行 `flutter analyze` 确保无编译错误
- 运行现有测试 `flutter test` 确保不破坏已有功能

### Manual Verification

- 在 iOS 模拟器或真机上验证：
  1. 从密钥列表页点击「导入密钥」进入导入页面
  2. 通过文件选择器选择一个 OpenSSH 私钥文件，成功导入
  3. 通过粘贴方式输入私钥 PEM 文本，成功导入
  4. 导入后密钥列表正确显示新密钥的名称、类型、指纹
  5. 在密钥列表项菜单中点击「导出私钥」/「导出公钥」，成功通过系统分享面板导出文件


updateAtTime: 2026/4/19 19:55:19

planId: 4830ad31-638f-4878-a631-9211990ae00d