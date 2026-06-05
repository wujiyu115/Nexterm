# Nexterm

**全功能跨平台 SSH 终端客户端**

Nexterm 是一款基于 Flutter 构建的现代化 SSH 终端客户端，支持 iOS 和 Android 平台，内置云端同步、端对端加密、SFTP 文件管理以及端口转发等专业级功能。

---

## 功能亮点

### 终端

| 功能 | 描述 |
|------|------|
| **多标签 SSH 终端** | 同时开启多个 SSH 会话，通过标签页自由切换 |
| **跳板机链式连接** | 支持多级跳板机（Jump Host）链路，一键穿透内网访问目标服务器 |
| **自定义字体** | 内置 JetBrains Mono、Source Code Pro、Fira Code、Ubuntu Mono 四款等宽字体，可自由切换 |
| **10 套统一主题** | Nexterm、Dracula、Nord、Solarized Dark、Gruvbox、Catppuccin Mocha（暗色）；Solarized Light、Catppuccin Latte、GitHub Light、Rosé Pine Dawn（亮色）——选一个即同时切换终端配色与 App 界面风格 |
| **字体大小调节** | 在设置中调整或在终端内双指缩放实时改变字号 |
| **可配置回滚行数** | 自定义终端缓冲区大小（100 ~ 1,000,000 行） |
| **光标样式** | 块状、下划线、竖线三种光标样式可选 |
| **自定义键盘工具栏** | 可拖拽排序、控制显示组数的软键盘快捷键面板 |
| **功能面板** | 代码片段快速执行、命令历史搜索、快捷键帮助一键触达 |
| **终端内文件上传** | 从终端直接上传文件到远程服务器，支持路径复制与粘贴 |
| **二级折叠菜单** | 终端菜单按功能分组（文件、工具、设置），支持原地展开/收缩 |
| **断线自动重连** | SSH 连接断开后自动尝试重连，无需手动操作 |
| **Bell 通知** | 终端 Bell 信号触发系统通知（App 在后台时），不错过任何命令完成提醒 |
| **触觉反馈** | 按键时的触觉振动反馈（可关闭） |

### 主机管理

| 功能 | 描述 |
|------|------|
| **主机分组与标签** | 通过分组和标签整理主机，支持搜索过滤 |
| **收藏** | 常用主机标记收藏，快速访问 |
| **批量操作** | 全选、批量移动分组、批量删除 |
| **启动命令** | 为主机配置连接后自动执行的命令或代码片段 |
| **密钥管理跳转** | 添加主机时可直接跳转到密钥管理页面添加密钥 |
| **导入 SSH Config** | 从 `~/.ssh/config` 文件一键导入主机列表 |

### 安全与密钥

| 功能 | 描述 |
|------|------|
| **SSH 密钥管理** | 集中管理 ED25519/RSA 密钥，支持生成、导入与加密存储 |
| **生物识别解锁** | 支持 Face ID / Touch ID 快速解锁应用 |
| **自动锁定** | 可设置 1 / 5 / 10 / 30 分钟自动锁定 |
| **剪贴板自动清除** | 离开应用时自动清除剪贴板中的敏感内容 |

### 代码片段

| 功能 | 描述 |
|------|------|
| **可复用命令片段** | 将常用命令保存为片段，支持分组与标签管理 |
| **变量占位符** | 在片段中定义变量，执行时填入具体值 |

### 端口转发

| 功能 | 描述 |
|------|------|
| **本地转发** | 将本地端口映射到远程地址，通过 SSH 隧道访问远程服务 |
| **远程转发** | 将本地服务暴露给远程服务器 |
| **动态转发** | 创建 SOCKS5 代理，通过 SSH 服务器转发全部流量 |
| **自动启动** | 可设置端口转发随 SSH 连接自动启动 |
| **端口检测** | 自动检测远程服务器新监听端口，支持搜索与快速转发 |
| **Web 预览** | 在 App 内直接预览已转发端口的 Web 服务，无需切换浏览器 |

### SFTP / SMB / WebDAV 文件管理

| 功能 | 描述 |
|------|------|
| **多协议支持** | SFTP、SMB/CIFS、WebDAV 三种远程文件协议 |
| **文件浏览器** | 远程文件目录浏览，支持排序、隐藏文件显示 |
| **上传与下载** | 文件上传下载，支持传输进度显示 |
| **在线编辑** | 内置代码编辑器，直接编辑远程文件 |
| **视频流式播放** | 内置视频播放器（基于 media_kit/mpv），支持边下边播、拖拽进度 |
| **左滑删除** | 文件列表和连接列表支持左滑删除操作 |
| **权限管理** | 修改文件权限（chmod） |
| **复制、重命名、新建文件夹** | 常用文件操作一应俱全 |
| **SFTP 初始目录** | 可为每个主机配置 SFTP 连接时进入的默认目录 |
| **SMB 自动重连** | 网络中断后自动重连，支持 StreamSink/Connection reset 错误恢复 |

### Git 远程仓库管理

| 功能 | 描述 |
|------|------|
| **工作树状态** | 查看远程仓库的 staged/unstaged/untracked 文件变更 |
| **分支管理** | 浏览本地与远程分支，支持搜索过滤、滑动删除 |
| **分支图** | 可视化分支合并历史，支持懒加载与加载更多 |
| **提交日志** | 查看分支提交历史，点击查看提交详情与变更文件列表 |
| **Diff 查看** | 统一 Diff 视图，支持行级高亮与字符级内联差异对比 |
| **标签管理** | 浏览标签列表，支持 checkout 与删除 |
| **Git 仓库收藏** | 保存常用仓库路径，从 SFTP 或保险库快速打开 |

### 云同步

| 功能 | 描述 |
|------|------|
| **端对端加密同步** | 数据在设备端加密后上传，服务器仅存储密文 |
| **多设备管理** | 管理已授权的同步设备 |
| **加密备份与恢复** | 导出加密备份文件，在新设备还原数据 |

### 其他

| 功能 | 描述 |
|------|------|
| **多语言支持** | 中文 / English，可跟随系统语言 |
| **语音输入** | 终端内语音转文字输入，支持系统 ASR、火山引擎（豆包大模型 2.0 流式识别）、阿里云三种引擎，可独立选择语音识别语言。识别完成自动输出到终端 |
| **导出数据** | 将所有主机、密钥、片段导出为 JSON 文件 |

---

## 技术栈

| 层次 | 技术 |
|------|------|
| **移动客户端** | Flutter 3.29+ / Dart 3.7+ |
| **状态管理** | Riverpod 2 + riverpod_generator |
| **路由** | go_router |
| **本地数据库** | Drift (SQLite) |
| **SSH 协议** | dartssh2 |
| **终端渲染** | xterm.dart |
| **加密** | pointycastle (AES-256-GCM, PBKDF2) |
| **后端** | FastAPI (Python 3.12) |
| **数据库** | PostgreSQL |
| **认证** | JWT (PyJWT + bcrypt) |

---

## 项目结构

```
Nexterm/
├── nexterm/          # Flutter 移动端应用
│   ├── lib/
│   │   ├── core/     # 加密、路由、主题、国际化等基础设施
│   │   ├── data/     # 数据库、DAO、Repository 实现
│   │   ├── domain/   # 实体定义与 Repository 接口
│   │   ├── features/ # 按功能划分的模块
│   │   │   ├── forwarding/  # 端口转发
│   │   │   ├── git/         # Git 远程仓库管理
│   │   │   ├── hosts/       # 主机管理
│   │   │   ├── keys/        # SSH 密钥管理
│   │   │   ├── settings/    # 应用设置
│   │   │   ├── sftp/        # SFTP 文件管理
│   │   │   ├── smb/         # SMB 连接
│   │   │   ├── snippets/    # 代码片段
│   │   │   ├── sync/        # 云同步
│   │   │   ├── terminal/    # 终端
│   │   │   ├── vaults/      # 保险库首页
│   │   │   └── webdav/      # WebDAV 连接
│   │   └── shared/   # 全局共用 Widget
│   ├── assets/fonts/  # 内置等宽字体
│   └── test/         # 单元测试与 Widget 测试
├── server/           # FastAPI 云同步后端
│   ├── app/
│   │   ├── api/      # 路由：auth / sync / devices
│   │   ├── core/     # 配置、数据库连接、安全工具
│   │   ├── models/   # SQLAlchemy ORM 模型
│   │   ├── schemas/  # Pydantic 请求/响应模型
│   │   └── services/ # 业务逻辑层
│   └── tests/        # pytest 测试套件
└── docs/             # 架构设计文档
    └── architecture/
```

---

## 快速上手

### 移动端（Flutter）

```bash
cd nexterm

# 安装依赖
flutter pub get

# 运行代码生成（Drift DAO、Riverpod Provider）
dart run build_runner build --delete-conflicting-outputs

# 启动应用（连接已有模拟器或真机）
flutter run
```

### 云同步后端（Python / FastAPI）

```bash
cd server

# 创建虚拟环境
python -m venv venv && source venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env   # 按需修改 DATABASE_URL、JWT_SECRET 等

# 启动服务（开发模式，自动重载）
uvicorn app.main:app --reload --port 8000
```

---

## 架构文档

- [系统架构总览](docs/architecture/overview.md)
- [SSH 连接生命周期](docs/architecture/ssh-connection-flow.md)
- [端对端加密设计](docs/architecture/e2e-encryption.md)
- [云同步协议](docs/architecture/sync-protocol.md)
- [SFTP 文件管理器](docs/architecture/sftp-file-manager.md)

---

## License

_待补充。_
