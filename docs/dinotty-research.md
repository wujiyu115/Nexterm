# Dinotty 深度调研报告

> 调研日期：2026-06-06
> 仓库地址：https://github.com/xichan96/dinotty
> 版本：v0.7.6
> 许可证：MIT

---

## 1. 项目概述

Dinotty 是一个**移动优先（Mobile-First）**的 Web 终端服务器，专为 **Coding Agent**（如 Claude Code、opencode、Codex、OpenClaw）设计。核心目标是让用户在手机上获得与桌面完全一致的终端 Agent 体验——利用碎片时间随时随地编程。

### 核心定位

| 维度 | 描述 |
|------|------|
| 目标用户 | 使用 AI Coding Agent 的开发者 |
| 核心场景 | 移动端远程操控服务器上的终端 Agent |
| 差异化 | 与远程桌面（VNC/RDP）相比，传输效率高 100-1000 倍（纯文本 JSON vs 视频流） |
| 形态 | Web Terminal Server + Tauri Desktop Client |

---

## 2. 技术架构

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────┐
│                    Client (Browser/Tauri)             │
│  Vue 3 + TypeScript + xterm.js 5 + Monaco Editor     │
└──────────────────────┬──────────────────────────────┘
                       │ WebSocket / HTTP REST
┌──────────────────────┴──────────────────────────────┐
│                    Server (Rust)                      │
│  Axum 0.7 + Tokio Runtime + portable-pty + VTE       │
│                                                      │
│  ┌─────────┐ ┌──────────┐ ┌───────────┐ ┌────────┐ │
│  │SessionMgr│ │VT Screen │ │  Proxy    │ │ Plugin │ │
│  │(DashMap) │ │(VTE FSM) │ │(Reverse)  │ │ System │ │
│  └─────────┘ └──────────┘ └───────────┘ └────────┘ │
│  ┌─────────┐ ┌──────────┐ ┌───────────┐ ┌────────┐ │
│  │Workspace│ │ Monitor  │ │   Auth    │ │FileWatch│ │
│  │(File API)│ │(sysinfo) │ │(Token+IP) │ │(notify)│ │
│  └─────────┘ └──────────┘ └───────────┘ └────────┘ │
└─────────────────────────────────────────────────────┘
                       │ PTY
┌──────────────────────┴──────────────────────────────┐
│                    OS Shell (bash/zsh/fish)           │
└─────────────────────────────────────────────────────┘
```

### 2.2 后端技术栈

| 组件 | 技术选型 | 用途 |
|------|----------|------|
| Web 框架 | Axum 0.7 | HTTP/WebSocket 路由 |
| 异步运行时 | Tokio (full features) | 并发 I/O |
| 终端仿真 | VTE 0.13 | ANSI/CSI 解析状态机 |
| PTY 管理 | portable-pty 0.8 | 跨平台伪终端 |
| 并发数据结构 | DashMap 5 | 无锁并发 HashMap |
| 静态文件嵌入 | rust-embed 8 | SPA 打包到二进制 |
| 系统监控 | sysinfo 0.34 | CPU/内存/磁盘/网络 |
| 反向代理 | reqwest 0.12 + tokio-tungstenite | HTTP/WS 转发 |
| 文件监听 | notify 6 | 文件系统变更事件 |
| HTML 改写 | lol_html 2 | 流式 HTML 改写（代理注入） |
| 代码分析 | syn 2 + proc-macro2 | 语法检查 |
| 序列化 | serde + serde_json | JSON 编解码 |
| 压缩/归档 | flate2 + tar + zip | 文件上传/下载 |
| Unicode | unicode-width 0.2 | 宽字符处理 |

### 2.3 前端技术栈

| 组件 | 技术选型 | 用途 |
|------|----------|------|
| 框架 | Vue 3 (Composition API) | UI 组件 |
| 语言 | TypeScript | 类型安全 |
| 构建工具 | Vite 6.3 | 开发/打包 |
| 终端渲染 | xterm.js 5 + WebGL Addon | GPU 加速终端渲染 |
| 代码编辑器 | Monaco Editor 0.55 | 文件编辑 |
| 图表 | Chart.js + vue-chartjs | 系统监控可视化 |
| 图标 | lucide-vue-next | UI 图标 |
| Markdown | marked 18 | Markdown 渲染 |
| 安全 | DOMPurify | XSS 防护 |
| 通知 | vue-toastification | Toast 通知 |

### 2.4 桌面端

| 组件 | 技术选型 | 用途 |
|------|----------|------|
| 框架 | Tauri 2 | 跨平台桌面应用 |
| 功能 | tray-icon, global-shortcut, shell | 系统集成 |
| 架构 | 复用 dinotty-server crate | 代码共享 |

---

## 3. 核心模块分析

### 3.1 虚拟终端仿真器（VT Screen）

**文件**: `src/vt_screen.rs`（600+ 行）

这是 Dinotty 的核心差异化技术。服务端维护了一个完整的虚拟终端仿真器：

```rust
struct Cell {
    ch: char,
    combining: [char; MAX_COMBINING],  // 组合字符支持
    combining_len: u8,
    attrs: CellAttrs,                   // fg/bg/bold/italic/underline 等
}

struct ScreenBuffer {
    cells: Vec<Vec<Cell>>,     // 字符网格
    cursor: CursorState,       // 光标位置与属性
    scroll_top: usize,         // 滚动区域
    scroll_bottom: usize,
    cols: usize,
    rows: usize,
}
```

**设计亮点**：
- 使用 VTE 状态机实时解析 PTY 输出的每个字节
- 服务端维护精确的屏幕状态（结构化字符网格而非原始字节流）
- 滚动历史在服务端以环形缓冲区保留
- 支持 Unicode 组合字符（最多 3 个 combining characters）
- 可随时生成 ANSI 编码的屏幕快照用于断线重连

### 3.2 会话管理（Session Manager）

**文件**: `src/session.rs`

```rust
pub struct Session {
    pub writer: Mutex<Box<dyn Write + Send>>,
    pub master: Mutex<Box<dyn MasterPty + Send>>,
    pub screen: Mutex<VirtualScreen>,
    pub clients: Mutex<Vec<mpsc::UnboundedSender<String>>>,
    pub status: Mutex<SessionStatus>,
    pub cwd_state: Mutex<CwdState>,  // OSC title 嗅探工作目录
}
```

**特性**：
- 基于 DashMap 的无锁并发 Session 映射（pane-id → PTY）
- 多客户端同步：同一 session 支持多个浏览器窗口连接
- 会话持久化：断开连接后 PTY 进程继续运行
- CWD 嗅探：通过解析 OSC title escape sequence 获取当前工作目录
- Tab 同步：专用 `/ws/sync` WebSocket 保持所有客户端的标签页状态一致

### 3.3 WebSocket 通信协议

**文件**: `src/ws.rs`

| 方向 | 消息类型 | 字段 |
|------|----------|------|
| Client → Server | `input` | `data: String` |
| Client → Server | `resize` | `cols: u16, rows: u16` |
| Server → Client | `output` | `data: String` |
| Server → Client | `shell_info` | `shell_type: String` |
| Server → Client | `reconnected` | `cols: u16, rows: u16` |

断线重连流程：
1. PTY 进程在服务端持续运行
2. 服务端分块回放滚动历史
3. 发送当前屏幕快照
4. 客户端恢复到断开前的精确状态

### 3.4 认证系统

**文件**: `src/auth.rs`

安全机制：
- **Token 认证**：Bearer Token（Header 或 Query 参数）
- **IP 白名单**：支持精确 IP、CIDR 子网、通配符匹配
- **暴力破解防护**：5 次失败后锁定 60 秒
- **时间常量比较**：`constant_time_eq()` 防止计时攻击
- **路径豁免**：静态资源和预览页面无需认证

### 3.5 插件系统

**文件**: `src/plugin.rs`

插件系统是 Dinotty 的扩展框架，支持：

- **声明式清单** (`dinotty-plugin.json`)：name、version、main、permissions
- **Vue 组件渲染**：插件可提供 Vue 组件显示为独立标签页
- **丰富的 API**：
  - Vue 3 响应式 API（ref, reactive, computed, watch）
  - 终端控制（send, createTab, onOutput）
  - 持久化存储（get/set/list）
  - 命令面板注册
  - CLI 二进制执行（同步 + 流式 WebSocket）
  - UI 通知与确认对话框
  - 设置监听

**内置插件**：
| 插件 | 功能 |
|------|------|
| CC Switch | 管理多个 Claude Code API Provider，一键切换 |
| JSON Formatter | JSON 格式化/压缩/验证 |
| Command Bookmarks | 命令收藏夹，批量发送到多个终端 |
| Text Diff | 文本差异对比 |

### 3.6 系统监控

**文件**: `src/monitor.rs`

通过 `sysinfo` crate 实时采集：
- CPU 使用率（总体 + 每核）+ 负载均衡
- 内存使用（物理 + Swap）
- 磁盘空间（每个挂载点）
- 网络流量（每个接口）

数据通过 WebSocket (`/ws/monitor`) 推送到前端，保留最近 60 条历史用于图表绘制。

### 3.7 反向代理

**文件**: `src/proxy.rs`

路由 `/preview/:port/*path` 实现本地端口的反向代理，用于：
- 预览 Agent 生成的 Web 应用
- 在手机浏览器中直接查看开发服务器输出
- 支持 HTTP 和 WebSocket 转发

---

## 4. 前端架构分析

### 4.1 组件结构

```
App.vue
├── LoginPage          # Token 认证页
├── TabBar             # 标签栏（终端 + 插件）
├── TerminalPane       # xterm.js 终端面板
├── PreviewPanel       # 文件浏览/Web 预览面板
├── PluginView         # 插件渲染容器
├── MobileKeyboard     # 自定义快捷键盘
├── StatusBar          # 状态栏
├── NotificationPanel  # 通知面板
├── CommandPalette     # 命令面板
├── SettingsPanel      # 设置面板
├── CommandBookmarks   # 命令收藏
└── ServerList         # 多服务器连接管理
```

### 4.2 移动端适配

- **响应式布局**：竖屏上下排列，横屏左右并排
- **触控优化**：触摸滚动、触控友好按钮、触摸拖拽面板缩放
- **自定义快捷键盘**：
  - 模拟 Ctrl/Alt/Esc/Function 键
  - 粘滞修饰键（Sticky Modifier）
  - 支持发送任意转义序列
  - 完整按键布局（F1-F12、方向键、可打印字符）

---

## 5. 部署与运维

### 5.1 部署方式

| 方式 | 说明 |
|------|------|
| Systemd | `deploy/systemd/install.sh` 一键部署为系统服务 |
| Docker | `deploy/docker/` 含 Dockerfile + docker-compose |
| 二进制分发 | 支持 x86_64/aarch64 Linux (musl 静态链接) + macOS |
| Tauri 桌面 | 跨平台桌面客户端 |

### 5.2 构建系统

- `build.sh`：统一构建脚本（native/cross/all/frontend/desktop）
- 前端打包后通过 `rust-embed` 嵌入到 Rust 二进制中，单文件分发
- 支持 `cross` 工具进行交叉编译

### 5.3 配置

| 参数 | 方式 | 默认值 |
|------|------|--------|
| 端口 | `--port` / `DINOTTY_PORT` | 8999 |
| Token | `DINOTTY_TOKEN` 环境变量 | 随机生成 |
| 日志级别 | `RUST_LOG` | info |
| Shell | `SHELL` 环境变量 | 自动检测 |

---

## 6. 设计模式与代码质量

### 6.1 设计模式

| 模式 | 应用场景 |
|------|----------|
| **Actor Model** | 每个 PTY session 通过 `mpsc::unbounded_channel` 广播输出 |
| **State Machine** | VTE parser 实现完整的终端状态机 |
| **Observer** | `broadcast::channel` 用于监控数据和同步消息推送 |
| **Middleware** | Axum middleware 实现认证拦截 |
| **Embed Pattern** | `rust-embed` 将前端资产编译进二进制 |
| **FromRef** | 多个 `FromRef` 实现让各 handler 按需提取 state 子集 |

### 6.2 并发模型

- **DashMap**：无锁并发 HashMap 用于 session 管理
- **Arc + Mutex**：Session 内部状态保护
- **RwLock**：Token 等读多写少的场景
- **Tokio broadcast**：一对多的系统监控数据推送
- **mpsc::unbounded**：PTY 输出到 WebSocket 的单向流

### 6.3 安全实践

- 时间常量字符串比较（防计时攻击）
- 暴力破解速率限制
- IP 白名单 + CIDR 子网匹配
- DOMPurify 前端 XSS 防护
- CORS 策略
- 认证路径豁免设计合理

### 6.4 代码组织

模块划分清晰，职责单一：
- 每个 `.rs` 文件对应一个功能模块
- `lib.rs` 仅做模块声明
- `main.rs` 专注路由绑定和服务启动
- 前端使用 Composables 模式（`useTerminal`, `useTransport`, `useSettings`）

---

## 7. 竞品对比

| 特性 | Dinotty | ttyd | Wetty | code-server | Nexterm |
|------|---------|------|-------|-------------|---------|
| 移动优先 | ✅ 核心设计 | ❌ | ❌ | ❌ | ❌ |
| Coding Agent 优化 | ✅ | ❌ | ❌ | 部分 | ❌ |
| 服务端虚拟终端 | ✅ (VT Screen) | ❌ | ❌ | ❌ | 未知 |
| 断线重连 | ✅ 精确恢复 | ❌ | 有限 | ✅ | ✅ |
| 自定义快捷键盘 | ✅ 完全可配 | ❌ | ❌ | ❌ | ❌ |
| 内建文件浏览器 | ✅ | ❌ | ❌ | ✅ | ✅ |
| 反向代理预览 | ✅ | ❌ | ❌ | ✅ | ❌ |
| 插件系统 | ✅ | ❌ | ❌ | ✅ | ❌ |
| 系统监控 | ✅ | ❌ | ❌ | ❌ | ✅ |
| Tauri 桌面端 | ✅ | ❌ | ❌ | Electron | Electron |
| 技术栈 | Rust+Vue | C | Node.js | Node.js+TS | Go/Rust+Vue/React |
| 带宽消耗 | 极低 (KB/s) | 低 | 低 | 中 | 低 |

### 与 Nexterm 的关系

Dinotty 和 Nexterm 同属终端管理领域但定位不同：
- **Nexterm**：服务器管理平台，侧重多服务器连接管理、SSH、SFTP
- **Dinotty**：移动端 Agent 终端，侧重单机上的 AI Coding Agent 体验

两者在技术上有交叉（如 xterm.js、WebSocket 通信），但场景互补。

---

## 8. 优劣势分析

### 8.1 优势

1. **精准定位**：瞄准 AI Coding Agent 移动使用这一新兴需求
2. **技术深度**：服务端 VT Screen 仿真是真正的技术壁垒
3. **极低带宽**：JSON 文本传输比视频流效率高 100-1000 倍
4. **完整的断线重连**：基于 VT Screen 快照实现精确恢复
5. **单二进制部署**：前端嵌入，零依赖分发
6. **插件扩展**：完整的插件 API 和生态雏形
7. **Rust 性能**：高并发低延迟

### 8.2 潜在不足

1. **生态早期**：项目较新，社区规模待发展
2. **安全性**：Web 终端暴露在公网的安全风险需要用户自行评估
3. **功能覆盖**：部分高级终端特性可能覆盖不全（如 sixel 图像）
4. **文档**：当前以 README 为主，缺乏深入的开发文档
5. **测试覆盖**：`[dev-dependencies]` 为空，测试基础设施不明确

---

## 9. 技术亮点总结

1. **VT Screen 服务端仿真** —— 不是简单的 PTY 字节转发，而是维护完整的终端状态，使断线重连、多客户端同步成为可能
2. **OSC Title CWD 嗅探** —— 通过解析终端转义序列自动获取当前工作目录
3. **rust-embed 单文件分发** —— 前端资产编译进二进制，部署极其简单
4. **指数退避自动重连** —— 1s → 30s 上限，适配弱网环境
5. **lol_html 流式 HTML 改写** —— 反向代理时注入必要的脚本/样式
6. **constant_time_eq** —— 手写时间常量比较函数防止计时攻击

---

## 10. 结论

Dinotty 是一个定位精准、技术实力扎实的开源项目。它抓住了 AI Coding Agent 时代的一个真实痛点——如何在移动设备上获得完整的终端 Agent 体验。通过服务端虚拟终端仿真、极低带宽传输、完善的断线重连机制，它提供了远优于远程桌面的移动终端方案。

对于 Nexterm 项目来说，Dinotty 的以下技术值得参考：
- 服务端 VT Screen 仿真模式（用于断线重连和多设备同步）
- 移动端快捷键盘设计
- 插件系统架构（Vue 组件 + 丰富 API）
- rust-embed 单文件部署模式
