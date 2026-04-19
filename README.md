# Nexterm

**全功能跨平台 SSH 终端客户端**

Nexterm 是一款基于 Flutter 构建的现代化 SSH 终端客户端，支持 iOS 和 Android 平台，内置云端同步、端对端加密、SFTP 文件管理以及端口转发等专业级功能。

---

## 功能亮点

| 功能 | 描述 |
|------|------|
| **多标签 SSH 终端** | 同时开启多个 SSH 会话，通过标签页自由切换，告别反复登录的烦恼 |
| **跳板机链式连接** | 支持多级跳板机（Jump Host）链路，一键穿透内网访问目标服务器 |
| **SSH 密钥管理** | 集中管理 RSA/ED25519 私钥，支持密钥生成与加密存储 |
| **代码片段（Snippets）** | 将常用命令保存为可复用片段，支持变量占位符替换 |
| **端口转发** | 支持本地、远程、动态三种端口转发模式，并可设置随连接自动启动 |
| **SFTP 文件管理** | 内置文件浏览器，支持上传、下载、权限修改（chmod）以及在线代码编辑 |
| **端对端加密云同步** | 数据在设备端加密后上传，服务器仅存储密文，云端无法访问您的配置 |
| **生物识别解锁** | 支持 Face ID / Touch ID 快速解锁应用 |
| **主题与个性化** | 多套终端配色主题，可按喜好自定义显示风格 |
| **加密备份与恢复** | 支持导出加密备份文件，并通过恢复密钥在新设备还原数据 |

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
termius/
├── nexterm/          # Flutter 移动端应用
│   ├── lib/
│   │   ├── core/     # 加密、路由、主题等基础设施
│   │   ├── data/     # 数据库、DAO、Repository 实现
│   │   ├── domain/   # 实体定义与 Repository 接口
│   │   ├── features/ # 按功能划分的 UI + Provider + Service
│   │   └── shared/   # 全局共用 Widget
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

详细说明见 [nexterm/README.md](nexterm/README.md)。

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

详细说明见 [server/README.md](server/README.md)。

---

## 截图

> _截图即将上线，敬请期待。_

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
