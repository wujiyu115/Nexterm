# Nexterm — 全功能跨平台 SSH 终端客户端设计文档

## 概述

Nexterm 是一款基于 Flutter 的跨平台（iOS + Android）SSH 终端客户端，对标 Termius 的全功能体验，面向个人开发者和运维人员。核心差异点：端到端加密云同步，无团队协作功能，聚焦个人用户的安全与效率。

## 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Flutter (iOS + Android) |
| 语言 | Dart |
| SSH/SFTP | dartssh2 |
| 终端渲染 | xterm.dart |
| 状态管理 | Riverpod |
| 路由 | GoRouter |
| 本地数据库 | Drift (SQLite ORM) |
| 安全存储 | flutter_secure_storage (iOS Keychain / Android Keystore) |
| 后端 | Python FastAPI + PostgreSQL |
| 加密 | AES-256-GCM + Argon2id 密钥派生 |
| HTTP 客户端 | Dio |

## 项目结构

```
nexterm/
├── lib/
│   ├── core/               # 加密引擎、主题系统、DI、网络基础
│   │   ├── crypto/          # AES-256-GCM 加密/解密、Argon2id 密钥派生
│   │   ├── theme/           # 浅色/深色主题定义、终端配色方案
│   │   ├── network/         # Dio 配置、拦截器、JWT 管理
│   │   └── di/              # Riverpod providers 根配置
│   ├── data/                # 数据层
│   │   ├── database/        # Drift 数据库定义、表、DAO
│   │   ├── repositories/    # Repository 实现
│   │   └── api/             # REST API 客户端
│   ├── domain/              # 领域层（纯 Dart）
│   │   ├── entities/        # Host, Key, Snippet, PortForward, SyncRecord 等
│   │   ├── repositories/    # Repository 接口
│   │   └── usecases/        # Use Case 业务逻辑
│   ├── features/            # 功能模块
│   │   ├── terminal/        # SSH 终端 + 多标签 + 分屏
│   │   ├── hosts/           # 主机管理（分组、标签、搜索）
│   │   ├── sftp/            # 文件管理器 + 内置编辑器
│   │   ├── snippets/        # 代码片段管理
│   │   ├── keys/            # SSH 密钥管理
│   │   ├── forwarding/      # 端口转发
│   │   ├── sync/            # 云同步 + 账户管理
│   │   └── settings/        # 设置页面
│   └── shared/              # 共享 UI 组件、工具函数
│       ├── widgets/         # 通用 Widget（搜索栏、卡片、状态指示器）
│       └── utils/           # 日期格式化、文件大小格式化等
├── server/                  # FastAPI 后端
│   ├── app/
│   │   ├── api/             # REST 路由
│   │   ├── models/          # SQLAlchemy 模型
│   │   ├── schemas/         # Pydantic 验证
│   │   ├── services/        # 业务逻辑
│   │   └── core/            # 配置、JWT 认证、中间件
│   ├── migrations/          # Alembic 数据库迁移
│   └── tests/
├── test/                    # Flutter 单元/Widget 测试
└── integration_test/        # 集成测试
```

## 模块设计

### 1. 终端模块 (features/terminal/)

#### SSH 连接管理

SSHService 封装 dartssh2，提供连接生命周期管理：

- **认证方式**: 密码、密钥（RSA/Ed25519/ECDSA）、键盘交互认证
- **跳板机**: 支持多级 Jump Host 链式连接，依次建立隧道
- **断线重连**: 监听网络状态（connectivity_plus），断线后指数退避重试（1s → 2s → 4s → 最大 30s），重连成功后提示用户执行 `tmux attach` 或 `screen -r` 恢复会话

#### 终端渲染

基于 xterm.dart 定制：

- xterm-256color 终端类型，完整 VT100/xterm 转义序列
- 可配置等宽字体、字号（8-24pt）、行高
- 内置终端配色方案：Catppuccin、Dracula、Monokai、Solarized Dark、Solarized Light、自定义
- 文本选择、复制粘贴
- 滚动回看缓冲区（可配置行数，默认 10000 行）
- Unicode / CJK 宽字符支持
- 光标样式可选：方块 / 下划线 / 竖线

#### 多标签系统

TabManager 使用 Riverpod StateNotifier 管理：

- `tabs: List<TerminalTab>` — 每个 tab 包含 id、title（auto: user@host）、SSHSession、TerminalController、连接状态
- 顶部标签栏，显示连接状态指示器（绿/黄/灰）
- 左右滑动切换标签
- 支持分屏（左右/上下），适合横屏和平板
- 关闭标签时断开对应 SSH 连接

#### 移动端键盘增强

- 快捷键工具栏：键盘上方常驻 Tab、Ctrl、Alt、Esc、方向键（↑↓←→）、⚡ Snippets 按钮
- 手势系统：双指捏合缩放字号、左右滑切换标签、长按选择文本、下拉呼出 Snippets、三指点击粘贴
- 可选震动反馈

### 2. 主机管理模块 (features/hosts/)

#### Host 数据模型

```
Host
├── id: String (UUID)
├── name: String
├── hostname: String
├── port: int (默认 22)
├── username: String
├── authMethod: AuthMethod (password | key | keyboardInteractive)
├── password: String? (加密存储)
├── keyId: String? (关联密钥)
├── group: String? (分组文件夹路径)
├── tags: List<String>
├── isFavorite: bool
├── jumpHosts: List<String> (跳板机 Host ID 链)
├── startupSnippetId: String? (连接后自动执行)
├── terminalSettings: TerminalSettings? (每主机覆盖)
├── lastConnected: DateTime?
└── sortOrder: int
```

#### 功能

- **分组文件夹**: 支持嵌套分组，拖拽排序
- **标签系统**: 多标签筛选，彩色标签
- **快速搜索**: 按名称、IP、标签模糊搜索，实时过滤
- **收藏置顶**: 星标收藏，收藏区在列表顶部
- **批量操作**: 长按进入多选模式，批量删除/移动/打标签
- **快速连接**: 不保存直接输入 user@host:port 连接
- **导入 SSH Config**: 解析 `~/.ssh/config` 格式导入主机
- **连接状态**: ● 在线(绿) ○ 离线(灰) ● 连接中(黄)
- **右滑快捷操作**: 连接 / 编辑 / SFTP

### 3. SFTP 文件管理器 (features/sftp/)

#### 界面布局

双栏设计：左侧本地文件系统，右侧远程文件系统。可切换为单栏模式。

#### 功能

- **文件传输**: 上传、下载，支持文件夹递归传输
- **传输队列**: 底部进度条，支持暂停/恢复/取消，断点续传
- **批量操作**: 多选文件批量上传/下载/删除/移动
- **文件预览**: 文本文件直接预览，图片缩略图
- **新建/重命名/删除**: 文件和文件夹的基本操作
- **权限管理**: 查看/修改文件权限（chmod），查看 owner/group
- **压缩解压**: UI 封装远程 tar/zip 命令执行
- **路径导航**: 面包屑导航栏，支持手动输入路径跳转
- **排序**: 按名称/大小/修改时间/类型排序
- **隐藏文件**: 切换显示 dotfiles

#### 内置代码编辑器

- 语法高亮：基于 flutter_highlight，支持 yaml, json, nginx, python, shell, javascript, go, rust, sql, dockerfile, markdown, xml, toml, ini 等
- 自动根据文件扩展名识别语言
- 行号显示
- 搜索替换
- 直接保存到远程（SFTP write）

### 4. Snippets 代码片段 (features/snippets/)

#### Snippet 数据模型

```
Snippet
├── id: String (UUID)
├── name: String
├── command: String (支持多行)
├── variables: List<SnippetVariable>
│   ├── name: String
│   ├── defaultValue: String?
│   └── description: String?
├── group: String?
├── tags: List<String>
├── isFavorite: bool
└── sortOrder: int
```

#### 功能

- **模板变量**: `${var}` 语法，执行前弹出表单填写变量值
- **多行命令**: 支持多行脚本，按顺序逐行发送到终端
- **快速执行**: 终端内下拉或 ⚡ 按钮呼出面板，搜索后一键发送到当前终端
- **分组管理**: 文件夹分组，拖拽排序
- **标签搜索**: 按名称/标签/命令内容模糊搜索
- **导入导出**: JSON 格式

### 5. 端口转发 (features/forwarding/)

#### PortForward 数据模型

```
PortForward
├── id: String (UUID)
├── name: String
├── type: ForwardType (local | remote | dynamic)
├── hostId: String (关联主机)
├── localPort: int
├── remoteHost: String? (local/remote 类型)
├── remotePort: int? (local/remote 类型)
├── bindAddress: String (默认 127.0.0.1)
├── autoStart: bool (连接主机时自动启动)
└── status: ForwardStatus (active | inactive | error)
```

#### 功能

- **三种转发类型**: Local（本地端口转发到远程）、Remote（远程端口转发到本地）、Dynamic（SOCKS5 代理）
- **一键启停**: 实时状态显示
- **自动启动**: 绑定到主机，SSH 连接建立时自动启动关联的端口转发
- **错误反馈**: 端口占用、连接失败等状态提示

### 6. 密钥管理 (features/keys/)

#### SSHKey 数据模型

```
SSHKey
├── id: String (UUID)
├── name: String
├── type: KeyType (ed25519 | rsa2048 | rsa4096 | ecdsa256 | ecdsa384 | ecdsa521)
├── privateKey: String (加密存储)
├── publicKey: String
├── fingerprint: String (SHA256)
├── passphrase: String? (加密存储)
└── createdAt: DateTime
```

#### 功能

- **生成密钥**: Ed25519（推荐默认）、RSA (2048/4096)、ECDSA (256/384/521)
- **导入密钥**: PEM 和 OpenSSH 格式，支持带密码短语的密钥
- **公钥导出**: 查看/复制/分享公钥，方便添加到服务器 authorized_keys
- **关联显示**: 列表中显示哪些主机使用了该密钥
- **安全存储**: 私钥 AES-256-GCM 加密后存 Drift，解密密钥存系统安全存储

### 7. 云同步 (features/sync/)

#### 端到端加密流程

1. 用户设置主密码
2. Argon2id 派生加密密钥（主密码 + 随机 salt，参数：memory=64MB, iterations=3, parallelism=4）
3. AES-256-GCM 加密本地数据，每条记录独立 IV
4. 加密后的密文上传到服务器
5. 新设备登录后输入主密码 → 派生同一密钥 → 解密下载的数据

服务器永远不接触明文数据。

#### 同步协议

增量同步，基于时间戳：

```
SyncRecord
├── id: String (UUID，全局唯一)
├── type: SyncType (host | key | snippet | forward | setting)
├── encryptedPayload: Bytes (AES-256-GCM 密文)
├── iv: Bytes (初始化向量)
├── updatedAt: DateTime
├── isDeleted: bool (软删除)
└── version: int (乐观锁)
```

同步流程：
1. 客户端请求 `GET /sync?since=<last_sync_timestamp>`
2. 服务器返回该时间戳之后所有变更的密文记录
3. 客户端本地解密 → 合并 → 冲突用 updatedAt 较大的 wins
4. 客户端上传本地变更 `POST /sync`（批量密文记录）
5. 更新 last_sync_timestamp

#### 主密码管理

| 场景 | 行为 |
|------|------|
| 首次设置 | 创建主密码 → 派生密钥 → 加密已知明文作为验证块 |
| 登录验证 | 输入主密码 → 派生密钥 → 解密验证块 → 成功则正确 |
| 修改密码 | 旧密码解密所有数据 → 新密码重新加密 → 全量上传 |
| 忘记密码 | 无法恢复。注册时提示导出恢复密钥 |
| 恢复密钥 | 一次性生成的随机密钥，可解密主密钥，用户需安全保存 |
| 生物识别 | 主密码解锁一次后，Face ID / 指纹缓存会话密钥 |

#### 离线优先

- 所有操作本地优先执行，不依赖网络
- 网络恢复后后台自动同步
- 无法自动解决的冲突暂存，提示用户手动选择

### 8. 后端 API (server/)

#### 技术栈

- FastAPI + SQLAlchemy + Alembic
- PostgreSQL
- JWT 认证（access token + refresh token）

#### API 路由

```
认证:
POST   /auth/register          邮箱 + 密码哈希注册
POST   /auth/login              登录获取 JWT
POST   /auth/refresh            刷新 token
DELETE /auth/account            删除账户及所有数据

同步:
GET    /sync?since=<ts>         拉取增量变更
POST   /sync                    推送本地变更（批量）
GET    /sync/full               全量拉取（新设备首次同步）

设备:
GET    /devices                 已登录设备列表
DELETE /devices/:id             远程注销设备
```

服务器只存储加密后的密文 blob + 元数据，不存储任何明文用户数据。

### 9. 主题与设置 (features/settings/)

#### 主题系统

双主题支持，跟随系统或手动切换：

**浅色主题色板:**
- 背景 #f5f5f5 / 卡片 #ffffff / 主文字 #1a1a1a / 次文字 #666666
- 主题色 #6c5ce7 / 在线 #00b894 / 错误 #e17055

**深色主题色板:**
- 背景 #1e1e2e / 卡片 #313244 / 主文字 #cdd6f4 / 次文字 #a6adc8
- 主题色 #cba6f7 / 在线 #a6e3a1 / 错误 #f38ba8

#### 设置结构

```
设置
├── 通用: 主题、语言（中/英）、启动页
├── 终端: 字体、字号、配色方案、光标样式、缓冲区行数、震动反馈
├── 安全: 主密码、生物识别、自动锁定时间、恢复密钥导出、剪贴板自动清除
├── 同步: 账户信息、同步状态、设备管理、手动同步、登出
├── 数据: 导入 SSH Config、导出加密 JSON、清除本地数据
└── 关于: 版本号、开源许可、反馈
```

## 安全设计总结

| 层 | 措施 |
|----|------|
| 传输层 | 全程 HTTPS + SSH 加密通道 |
| 存储层 | 敏感数据（密码、私钥）AES-256-GCM 加密后存 Drift，解密密钥存系统安全存储 |
| 同步层 | 端到端加密，服务器只存密文，Argon2id 密钥派生 |
| 认证层 | JWT (access + refresh)，支持生物识别缓存 |
| 应用层 | 自动锁定、剪贴板超时清除、恢复密钥机制 |
