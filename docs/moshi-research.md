# Moshi 深度调研文档

> **数据来源**：基于 https://getmoshi.app/docs 全部 29 个有效文档页面（sitemap 内 23 页 + 探测发现 6 页）的爬取与分析。
> **调研日期**：2026 年 6 月。

---

## 一、产品定位（What Moshi Is）

**Moshi** 是一款面向 AI 编码 Agent 时代的**移动端终端 App**（iOS / iPadOS 17+ / Android 10+），slogan 用"婴儿监视器"作比喻：

> "What a baby monitor is to a sleeping kid, Moshi is to your AI agents."

### 核心定位三要素

1. **不是云端 IDE**：Moshi 不在云端运行你的代码、不替代任何 Agent CLI。所有 shell、仓库、SSH 配置、mosh server、tmux 会话、Agent 订阅都留在你自己的机器上。
2. **是"移动控制面"**：手机/平板提供一个真实终端，连接到你已有的开发机（Mac、Linux、VPS、homelab）。
3. **为手机而生**：不是把桌面终端缩小硬塞进手机，而是围绕 AI Agent 长任务在手机端的工作流重新设计。

### 支持的 Agent CLI 矩阵

Claude Code、Codex、OpenCode、Gemini、Cursor、Kimi、Qwen Code —— 全部通过统一的 `moshi-hook` 守护进程接入。

---

## 二、文档全景（32 页结构 → 6 大板块）

| 板块 | 页面 | 解决的问题 |
|---|---|---|
| **Start** | introduction / install / first-session | 上手三步 |
| **Connections** | connections / terminal-sessions / tailscale | 连接、传输、内网穿透 |
| **Multiplexer** | tmux / zellij / herdr（外加 multiplexers 概览） | 长会话宿主 |
| **Input** | scrolling / voice / gestures / clipboard / keyboard / cjk-input | 手机输入痛点专项优化 |
| **Settings** | personalization / subscription / security-sync（外加 free-vs-pro、licensing-sharing） | 个性化、商业、安全 |
| **Integrations** | agents-usages / apple-watch / image-paste / hooks / moshi-cli / live-activity / diff-viewer / browser-preview / notifications / files | AI Agent 深度集成 |
| **Help** | troubleshooting / debugging-gateway | 故障排查 |

> 注：sidebar 中列出但 URL 返回 "Doc Not Found" 的页面：`multiplexers / agent-hooks / debugging-gateway / free-vs-pro / licensing-sharing`，推测是 IA 改版后的临时空洞或 redirect 未完成。

---

## 三、核心架构：App + moshi-hook 双组件

Moshi 不是一个孤立的 App，而是一个 **iOS/Android 客户端** + **宿主端守护进程** 的组合：

```
┌─────────────┐                    ┌───────────────────────┐
│   Moshi App │ ◄──SSH/Mosh──────► │  Host (Mac/Linux/VPS) │
│ (iOS/iPad)  │                    │                       │
│             │ ◄──WebSocket──────►│  ┌─────────────────┐  │
│             │   (push/approval)  │  │   moshi-hook    │  │
│             │                    │  │   (daemon)      │  │
│             │ ◄──HTTPS upload──► │  │  - unix socket  │  │
│             │   (images/files)   │  │  - gateway:24543│  │
│             │                    │  │  - WS backend   │  │
└─────────────┘                    │  └────┬────────────┘  │
                                   │       │ hooks         │
                                   │   ┌───▼─────────────┐ │
                                   │   │ Agent CLIs:     │ │
                                   │   │ Claude/Codex/.. │ │
                                   │   └─────────────────┘ │
                                   └───────────────────────┘
```

### moshi-hook 是什么

- 一个 **同时是 CLI 和 daemon** 的二进制；安装后还会同时暴露 `moshi` 这个短别名。
- 通过 **本地 Unix socket** 接收 Agent CLI 的 hook 事件
- 通过 **WebSocket** 与 Moshi 后端通信（推送、审批回路）
- 在 **127.0.0.1:24543** 上跑一个本地网关，App 通过 SSH 隧道转发到这个端口，从而启用 Diff Viewer 和 Browser Preview
- 自动改写 Agent 的配置文件接入 hook（仅写入 Moshi 命名空间，不动用户已有 hook）

### 哪些功能依赖 daemon 运行（`moshi-hook serve`）

| 需要 daemon | 不需要 daemon |
|---|---|
| Inbox 事件接收 | `moshi <dir>` tmux 启动器 |
| Live Activity / 推送 | `moshi diff <dir>` 独立 diff viewer（桌面浏览器） |
| App 内 Diff Viewer | `moshi-hook context` 一次性上下文探测 |
| App 内 Browser Preview | `pair / install / uninstall / status / update / version` |
| 实时多路复用器检测（滑动切窗手势） | |

**简洁判定**：任何「向 App 推流」或「接受 Agent push」的功能 → 必须 `serve`；从 shell 一次性调用 → 不需要。

---

## 四、上手三步流程（Start 板块）

### 1. 安装与准备宿主

**iOS / Android** 端从 App Store / Google Play 安装。

**Mac 宿主**：
```bash
brew tap rjyo/moshi
brew install moshi-hook
brew install mosh tmux
```

**Debian/Ubuntu 宿主**：
```bash
curl -fsSL https://getmoshi.app/install.sh | sh
sudo apt install mosh tmux
```

**防火墙**（如果用 mosh，需要开 UDP 60000–61000）：
```bash
sudo ufw allow 60000:61000/udp
```

### 2. Easy Pair（推荐首选）

在宿主跑：
```bash
moshi-hook host setup
```
终端会打印一个 **Easy Pair QR 码**；在手机 Moshi 引导流程里扫码即可。

**Easy Pair 的密钥模型**：
- Moshi 在**手机本地生成** Ed25519 私钥
- 只把**公钥**通过 setup 会话发到宿主
- 宿主自动写入 `~/.ssh/authorized_keys`
- ⚠️ Easy Pair QR 等同临时访问令牌，被扫到就能拿 SSH 访问权——有时效。

### 3. 第一个会话

点开保存的连接 → 终端打开 → 直接 `tmux new -s work && claude`。
锁屏 / 切 App / 换网络 → 回到 Moshi → 会话仍在。

---

## 五、连接 & 传输层（Connections 板块）

### 连接对象字段

| 字段 | 说明 |
|---|---|
| Name | 可选显示名 |
| Host | IP / DNS / Tailscale 名 |
| Port | SSH 端口（一般 22） |
| Username | 远端用户 |
| Authentication | 密码 / 私钥 |
| Connection type | **Auto / SSH / Mosh** |

**重要**：凭据（密码、私钥、Passphrase、Fingerprint）与连接元数据**分开存储**——后者在 App 普通存储，前者在 iOS secure storage（Keychain）。删连接会同时清理对应凭据。

### 传输三种模式

- **Auto**（默认）：自动协商
- **SSH**：强制 TCP——适合 UDP 被防火墙、mosh 未装、需要 jump host
- **Mosh**：强制 UDP——会暴露 UDP port range、custom mosh-server path 字段

> **Jump host 限制**：仅 SSH 模式支持。Mosh 需要 UDP 直达终端会话，与 jump host 不兼容。

### Tailscale 集成（实际上"没有集成"）

Moshi 显式声明 **没有内置 Tailscale**，也不需要 ——Tailscale 在 iOS 系统层跑，Moshi 把 tailnet 主机当普通 SSH/Mosh 目标。

支持的 Host 写法：
- IPv4：`100.x.y.z`
- IPv6：`fd7a:115c:...`
- MagicDNS 短名 `mac-mini` 或 FQDN

**Mac 休眠问题**：闭盖 Mac 上 mosh over UDP 不会唤醒系统，Moshi 在新建 mosh 连接时会发 wake probe；建议用 Amphetamine / caffeinate 阻止休眠。

---

## 六、多路复用器支持（Multiplexer 板块）

Moshi 支持 **3 个多路复用器** 作为对等公民：tmux / Zellij / Herdr。三者都有：
- SSH 预检测（安装与否）
- 实时检测（当前会话是否在内）—— 通过 daemon gateway
- 会话选择器
- 专属 shortcut panel

### tmux（推荐默认）

- 支持 `moshi <dir>` 简短启动器（仅 tmux 独享）
- `tmux new-session -A -s <basename> -c <dir>`
- 使用 `exec`，没有 wrapper 进程
- 关键调优：**滚动速度是 tmux 的设置而非 App**——`bind -T root WheelUpPane send-keys -X -N 3 scroll-up`（默认 5 行）

### Zellij

- 支持 session picker
- Shortcut panel 带 **Tab 快速跳转行**（1–9 通过 `Ctrl-T <N>`）
- 没有 `moshi DIR` 启动器
- Tab 10+ 受限于 Zellij input mode 时序

### Herdr

- Moshi 开发者自家或合作的 **agent 多路复用器**：内置识别 agent pane 状态（blocked/working/done）
- 通过 `curl -fsSL https://herdr.dev/install.sh | sh` 安装
- 使用 `Ctrl-B` 前缀（与 tmux 同），支持 workspace / tab / pane / goto 概念
- moshi-hook 读取 `$HERDR_ENV` 和 `$HERDR_SESSION` 给 inbox 事件打标签

### 共同的故障模式

所有三者都有同一个**经典 PATH 坑**：Moshi 走 **non-interactive SSH** 检测，不加载 `~/.zshrc` / `~/.bashrc`，所以 `/opt/homebrew/bin`、`~/.cargo/bin`、`~/.local/bin` 都可能缺失。

诊断命令：
```bash
ssh <host> 'echo PATH=$PATH; command -v tmux'
```
修复：用 `~/.zshenv` 或 `~/.ssh/environment` 扩展 non-interactive PATH。

---

## 七、手机端输入设计（Input 板块）—— 最有产品味道的部分

这是 Moshi 区别于"把桌面终端硬塞进手机"的最显著一面。共 6 个子页面、5 个层次的输入设计：

### 1. 终端工具栏（Toolbar）

可见性 / 排序均在 Settings → Input 自定义。包括：Enter、Backspace、Paste、Keyboard toggle、Shortcut panel、Command history、D-pad。

### 2. D-pad

- 方向键 + 左上 / 右上 **两个可配置角落 slot**
- Slot 内容：Hide / Delete / Interrupt / 自定义 shortcut

### 3. 手势体系（Gestures 页面）

**四大手势表面**：
- **Terminal body**：tap / double-tap / triple-tap / swipe / pinch / scroll-past-bottom
- **Terminal header**：soft pull（开 session switcher）/ hard pull（最小化）
- **Toolbar buttons**：tap / double-tap / long-press
- **D-pad corners**：2 个 slot

**默认绑定**：
| 手势 | 默认动作 |
|---|---|
| Double-tap | 粘贴剪贴板 |
| Swipe | 切 tmux window |
| Pinch | 调字号（可改为缩放 tmux pane） |
| Scroll past bottom | 收起键盘 |
| Soft drag down header | session switcher |
| Hard drag down header | 最小化会话 |
| Mic 长按 | push-to-talk |
| Ctrl 双击 | 锁定 Ctrl |
| Shortcuts 双击 | 锁定 shortcut panel |

**自定义 shortcut 可绑到几乎任何手势**——Shortcut builder 同一套。

### 4. 硬件键盘

iPad 键盘下支持：
- `⌘K` 显示 shortcut
- `⌘1-9` 切到编号 session
- `⌘O` session switcher
- `⌘N` 新连接
- `⌘W` 关闭当前 session
- `⌘V` 粘贴
- `Option as Meta`（编辑器 chord 需要）
- 工具栏可在硬件键盘连上时自动隐藏

### 5. 语音输入（Voice & Dictation）

**三个语音引擎**：

| 引擎 | 说明 | 配额 |
|---|---|---|
| **Apple** (iOS 26+) | 设备端 SpeechAnalyzer，最快 | 免费无限 |
| **Whisper** (whisper.cpp) | 本地，需要下模型 | 免费无限 |
| **Cloud** | Moshi 自家云服务，需要 push token | 免费 **3 分钟/月**，Pro **60 分钟/月** |

**Chat mode 概念非常巧妙**：
- **关**：语音直接以 keystrokes 注入终端，搭配 Auto-send 还会按 Enter——适合 shell 命令
- **开**：弹出 composer 面板，可以语音+文字+图片混合编辑后一次性发送——适合给 Agent 写长 prompt

### 6. 剪贴板 & OSC 52

**Paste 进终端**：double-tap / `⌘V` / toolbar 三种方式都行。

**OSC 52 反向写 iOS 剪贴板**——这是 Moshi 默认支持的"远端 → 手机剪贴板"姿势：
```bash
printf '\033]52;c;%s\033\\' "$(echo -n 'hello' | base64)"
```
（tmux 内需要 `set -g set-clipboard on` 才能透传 escape）

**已知坑**：从 Agent 输出 copy 代码块容易得到 **terminal-width 硬换行**——因为 Agent 渲染时就按当前列宽换了。解决方案：
1. 旋转横屏 / 缩字号让终端变宽
2. 让 Agent 渲染后额外用 OSC 52 emit 一份原始块

### 7. 滚动（Scrolling）—— 三层概念

- **可见视图滚动**：drag up/down，新输出仍在底部
- **App 内 scrollback buffer**：在 Settings → Terminal 调大
- **Host 端 scrollback**：**只有 tmux copy mode 才能找到 20 分钟前那条 error**

**Mosh 协议本身不传 scrollback**——重连只恢复当前可见屏，所以"会话保活"和"历史保留"是两个事，后者必须放进 tmux。

### 8. CJK & IME

Moshi 用 iOS 原生 IME，所以任何手机上装过的输入法（韩日中越）都能直接用：

✅ 韩语 2-Set/3-Set、日语 Romaji/Kana、中文拼音/笔画/仓颉/注音
✅ Claude Code / Codex / OpenCode / Gemini / Cursor / Kimi / Qwen 的 prompt 都能输入 CJK
✅ 终端、Chat mode composer、图片粘贴、语音、剪贴板粘贴都支持

**宿主要求**：`export LANG=en_US.UTF-8` 写到 `~/.zshenv` 或 `~/.bashrc` 非交互段。

---

## 八、AI Agent 集成（Integrations 板块）—— 产品壁垒

### 1. Hooks 系统（hooks.md）

`moshi-hook` 是 Agent 集成的总枢纽：
- 支持自动写入 7 个 Agent 的配置：`~/.claude/settings.json`、`~/.codex/hooks.json`、`.opencode/plugins/moshi-hooks.ts`、`~/.gemini/settings.json`、`~/.cursor/hooks.json`、`~/.kimi/config.toml`、`~/.qwen/settings.json`
- 归一化所有 Agent 事件为 5 种 **inbox category**：
  - `approval_required`
  - `task_complete`
  - `session_started`
  - `tool_running`（throttled）
  - `tool_finished`（throttled）

**事件折叠**：同一 session 的新事件**更新**已有行而不堆叠 —— 让 Inbox 表现为"我正在协作的 Agent"而非"今早每一次按键"。

**Legacy endpoint**：`POST /api/v1/agent-events` 给第三方 harness（oh-my-pi 等）兼容，但 **2026 年 6 月 15 日下线**，之后返回 `410 legacy_agent_events_retired`。

### 2. Agents & Usages 面板（agents-usages.md）

**Agents 标签**（"AI Agent 收件箱"）：
- 每个会话一行
- 按 **project（工作目录）+ host 分组**
- **Active / Archived 分离**，衰减规则：
  - 待审批 → 永远 Active，直到回应或超时
  - 完成的 turn → 保留 10 分钟
  - 超过 6 小时 → 自动归档
- Context 剩余量小环（< 15% 时建议让 Agent 总结后再继续）

**Usages 标签**（额度面板）：
- Claude Code：固定 5h / 7d 窗口
- Codex：可变窗口（5h、weekly 等）
- OpenCode：provider 决定
- 每张卡：账号 logo + label + host + 使用率环 + last updated
- 拉到底部刷新；后台默认约每分钟更新

### 3. Apple Watch 配套（apple-watch.md）

不是通知镜像，是**原生 watchOS app**：
- **两个屏幕**：Inbox + Usage（按系统时钟左右图标切换）
- Inbox 行可以**直接审批**，不只是 glance
- **Usage complication** 可上表盘 → 取所有账号里**最高使用率**的那个窗口
- 通知 / Live Activity / Dynamic Island 自动 mirror
- **明确不支持**：开 shell、attach tmux、语音、贴图、scrollback
- 无需单独配对——继承 iPhone 的 iCloud + moshi-hook 凭证

### 4. Image & File Paste（image-paste.md）

这是 Moshi 自称 **"unique to Moshi, no other mobile SSH offers"** 的功能。

模拟 Claude Code / Codex 里的 `Ctrl+V`（注意是 Ctrl 不是 ⌘）行为：
- Tap toolbar attach → 选 Camera / Photo / Files / Clipboard
- Moshi 通过 SCP 把文件**复制到宿主** `~/.moshi/uploads/`
- Agent 拿到的就是一个**本地文件路径**，按打开本地文件的方式处理

**Chat mode 开 / 关行为不同**：
- 开：路径附加到 composer
- 关：路径直接粘到终端光标

**支持任意文件类型**：PDF、log、archive、config、code

### 5. Live Activity（live-activity.md）

- 锁屏 / Dynamic Island 显示当前会话的最新事件（task complete / tool running / approval needed）
- 一次只追踪一个 session
- 自动消失条件：task_complete + grace period / iOS 回收预算 / 用户手动 dismiss
- Settings → Hooks 里有 **Test Live Activity 按钮** 提供 demo

### 6. Diff Viewer（diff-viewer.md）—— Pro 功能

- moshi-hook 内置一个 **mini web app** 渲染 git diff（staged / unstaged / untracked，side-by-side）
- 终端 title 右边的**分支按钮**：
  - muted = 无 git repo
  - orange = 有 git repo
  - orange + badge = 有未提交变更
- 数据完全在 host，**不上传任何东西**
- 命令行也能开：`moshi diff .` —— 用 `127.0.0.1:24543` 端口
- 同一 server 跨 workspace 复用，避免开多个 tab

### 7. Browser Preview（browser-preview.md）—— Pro 功能

- moshi-hook 周期性嗅探宿主上的 **HTTP listener**
- 识别 `next`、`vite`、`storybook` 等 framework
- 终端 title 右边的**靛蓝按钮**：muted = 无服务，indigo = 有
- 通过 **per-session SSH local-forward** 转发——绑 `127.0.0.1`
- 优先 same-port mirror（`host:5173 → device:5173`），冲突时降级随机端口
- 会话关 → 隧道塌；**无任何 ngrok / cloudflared / 公网入口**

### 8. Push & Webhooks（notifications.md）

- 启用推送会得到一个 **API token**
- 通用 webhook：
```bash
curl -X POST https://api.getmoshi.app/api/webhook \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_API_TOKEN","title":"Done","message":"Build finished"}'
```
- **Unified push**：`unified: true` 会扇出到该 license 下所有 opted-in 设备（iPhone + Android 同 license 可一起收）

### 9. Files（files.md）

- pastebin 式上传：拿短 HTTPS URL，自动过期
- 复用 push notification token 鉴权（所以推送必须先开）
- Chat mode 里支持附加任何文件（PDF、log、压缩包...）

### 10. Moshi CLI（moshi-cli.md）

`moshi-hook` 别名 `moshi`。**核心歧义规则**：单个目录参数 → tmux 启动器；其他 → 子命令。

| 命令 | 行为 |
|---|---|
| `moshi .` / `moshi ~/path` | `tmux new-session -A -s <basename> -c <dir>`（exec 替换） |
| `moshi diff <dir>` | 本地 diff viewer + 浏览器开 URL |
| `moshi pair / install / serve / status / logs -f` | 同 `moshi-hook` 子命令 |

---

## 九、商业模型（Free vs Pro）

### Free 是完整可用的（不是阉割版）

| 维度 | Free |
|---|---|
| 活跃会话数 | 不限 |
| 保存的连接 | **2 个** |
| SSH 传输 | ✅ 全功能（含 key / password / jump host） |
| 推送通知 | ✅ |
| 生物识别保护 | ✅ |
| Agent 用量跟踪 | ✅ |
| Inbox 操作 | **5 次试用** |
| 云端语音 | **3 分钟/月** |
| 本地 Whisper + Apple 引擎 | 免费无限 |
| 自定义快捷指令 | **3 个** |
| Apple Watch | 只读 |

### Pro 解锁

| 维度 | Pro |
|---|---|
| 保存连接 | **不限** |
| **Mosh 传输** | ✅ —— 文档明说"the single biggest reason to upgrade" |
| **多路复用器集成** | tmux/Zellij/Herdr 全部 |
| **图片粘贴 / 文件分享** | ✅ |
| **Diff Viewer** | ✅ |
| **Browser Preview** | ✅ |
| 云端语音 | **60 分钟/月**（20×） |
| Inbox 操作 | 无限 |
| Apple Watch 操作 | 审批 / 拒绝 / 回答 |
| Unified push | ✅ |
| 自定义快捷 | 无限 |
| 主题 / 字体 | Dracula / Nord / Solarized / Gruvbox / Catppuccin / GitHub Light / Rosé Pine Dawn + Iosevka/Ioskeley/DejaVu/Noto CJK |

### 计费

- **订阅**（月/年）或 **Lifetime 一次性** 两种 SKU
- iOS：App Store / Apple ID
- Android：Google Play / Google 账号
- **跨平台 license**：通过 Moshi license key 加入；**最多 3 设备** 共享 license-scoped 功能（云端语音配额、共享 host、unified push）
- **三种数据流不互通**：
  - Pro 权益 ← 走 App Store/Play
  - License sharing ← 走 Moshi license key
  - 设置 / 主题 / 连接 ← 走 iCloud（仅 iOS）

---

## 十、安全模型（Security & Sync）

| 数据 | 存储位置 |
|---|---|
| 连接元数据（host / port / username） | App 普通存储 |
| 密码 / 私钥 / passphrase / fingerprint | **iOS Keychain / secure storage** |
| moshi-hook 主机密钥（macOS） | Keychain（默认）/ `--store file` |
| moshi-hook 主机密钥（Linux） | 受限权限文件 |

### 生物识别两档

- **Biometric for keys**：默认使用 key 前要 Face ID/Touch ID
- **Biometric on resume**：回 App 时要求验证

### iCloud 同步

- 设置同步：可选
- **凭据同步：独立开关，且只有开了设置同步才能开**——把"方便"和"风险"做了清晰分级

### moshi-hook 配对的安全姿势

- macOS：默认存 Keychain；headless 场景 `--store file` + `security unlock-keychain` 解锁
- 文档给出的实践清单：用专门 SSH key、只把公钥放需要移动访问的 host、保留 iOS 锁屏密码、不要开凭据同步除非必须

---

## 十一、个性化（Personalization）

**最特别的设计点**：**主题驱动整个 App，不是只有终端**。
- Catppuccin Mocha → 终端 + Settings sheet + Inbox 卡片 + 系统栏全部一致
- Solarized Light → 整个 App + iOS 键盘 + 状态栏全切浅色
- 每个主题有一个 accent color 贯穿（active toolbar pill / focus ring / Pro badge）

### 内置 9 个主题

- **Dark**：Moshi（默认）/ Dracula / Nord / Solarized Dark / Gruvbox / Catppuccin Mocha
- **Light**：Solarized Light / Catppuccin Latte / GitHub Light / Rosé Pine Dawn

Light 主题特别处理：**反转 256-color ramp**，让 htop/btop/Neovim 状态行的浅灰在亮背景上变深灰，避免"看不见"。

### 字体策略

- 默认 **JetBrains Mono**（内置）
- **按需下载**：Iosevka / Ioskeley / DejaVu Sans Mono
- **CJK 字体走 fallback 模型**：选了 Noto Sans Mono CJK JP/SC/TC/KR 只是 CJK 字符的 fallback，ASCII 仍走主字体，避免代码长得像中文字体

### 其他

- Cursor: block / underline / bar，blinking 独立开关
- Glass effect 可关
- App 图标可换（部分 Pro）
- UI 语言可固定（终端输出仍按 host）

---

## 十二、故障排查模式（Troubleshooting + Debugging）

文档里 troubleshooting 页面 **8.2KB**，是覆盖最广的之一。常见模式：

### "非交互 SSH PATH 缺失" 是头号陷阱

mosh-server、tmux、zellij、herdr 都受影响。

诊断：
```bash
ssh <host> 'echo PATH=$PATH; command -v mosh-server'
```

修复路径：
- `~/.zshenv`（zsh，所有 shell 都加载）
- `~/.bashrc` 顶部，在 interactive guard 之前（bash）
- 或 `~/.ssh/environment` 显式扩展
- 或在 Mosh 选项里填**绝对路径**

### Cloudflare 挑战导致 `moshi-hook install` 403

`cdn.getmoshi.app` 偶尔会对 curl 触发 JS challenge。识别：
```
HTTP/2 403
cf-mitigated: challenge
```
解决：用浏览器手动下 tarball → scp 到 host → 手装。

### Mac 闭盖 + Tailscale + Mosh 三连

UDP 不能唤醒系统；TCP keepalive 行为不同。Moshi 自带 wake probe，但建议直接用 Amphetamine/caffeinate 阻止 sleep。

---

## 十三、设计哲学与产品洞察

### 1. "Mobile control surface" 而非 "mobile IDE"

刻意不上云、不替代 Agent CLI。compute / git credentials / Agent process 全部在 host。这把 Moshi 的责任面积压到最小，也让它能搭配任何 Agent 生态而不打架。

### 2. 把"手机做不好的事"分别根治

- 输入慢 → 工具栏 + D-pad + 手势 + 硬件键盘 + 语音 + 5 种方式都能粘贴
- 屏幕小 → 主题统一 / 字体策略 / one-window-per-task 建议
- 通知打扰 → Inbox 事件折叠 / 自动归档 / context 剩余环
- 网络抖 → mosh 全推 / wake probe
- 长任务 → tmux 推荐 / 多路复用器一等公民
- IME 痛 → 全 iOS 原生 IME 透传 + Chat mode 兜底

### 3. 关键 SaaS 决策：daemon 留在 host 上

很多类似工具会让"协调中心"在云端跑，Moshi 反过来：
- 数据隐私：diff / preview / image 全走本地隧道
- 不需要公网入口（与 Tailscale 思路同构）
- 工具自身可被 `brew install moshi-hook` 任意停用

### 4. Inbox 的产品设计写出来都是经过验证的：
- 按 project + host **分组**
- **事件折叠** 而非堆叠
- **Active / Archived** 两栏 + 时间衰减
- Pending approval 顶到最上层
- **6 小时自动归档**——明确给"我没回的也会自己消失"

### 5. Hooks 系统的可观察性

normalize 7 个 Agent 的事件为 5 类，Inbox/Live Activity/Watch 复用同一套——这是 moshi-hook 这个 daemon 真正的产品价值，比任何 SSH client 都重。

### 6. 商业模型的"诚实免费层"

文档原话："Free is not a teaser"。SSH、推送、用量统计、Apple Watch 只读、3 个快捷、3 分钟云语音都给——免费层确实能完整跑通，但 Mosh / 图片粘贴 / Diff / Browser Preview / 多机房 license 这些把 Moshi 变成"daily driver"的能力锁 Pro。

---

## 十四、与竞品的差异化定位

文档里隐含或显式提到的对比：

| 对比对象 | Moshi 的差异 |
|---|---|
| **Termius** | 文档评论原话："其后台会话耗电比 Termius 好得多"；Termius 拖电、机身发热 |
| **mosh on desktop** | Moshi 给了 mosh 在手机端的真实 GUI（reconnect、scrollback 处理、wake probe） |
| **ngrok / cloudflared** | Browser preview 完全本地隧道，零公网入口 |
| **scp + 手动** | Image paste 一键、Agent 直接拿本地路径 |
| **任意 mobile SSH** | 唯一支持 image/file paste 到 Agent prompt |
| **Web SSH/Cloud IDE** | 不上云、不抢占 Agent CLI、host 自由 |

---

## 十五、调研结论

Moshi 的本质是 **"AI Agent 时代的 mobile-first 协作终端"**，而非传统终端模拟器的移动版本。

它的护城河是 **App 体验 × moshi-hook daemon × 7 个 Agent 的统一事件模型** 这三者的耦合 —— 单独看每一面都不难做，但合在一起形成了一个"在咖啡馆审批 Claude Code、在地铁里看 Codex 改的 diff、在床上让 Gemini 跑测试"的完整工作流。

### 适合的人

- 跑 Claude Code / Codex 等长任务 Agent 的开发者
- 有家里 Mac mini / VPS / homelab 的人
- 经常在地铁、咖啡馆、出差路上需要审批 / 监控 Agent 的人
- 重度 tmux 用户

### 不适合的人

- 偶尔 SSH 一下、纯命令行管理的——Free 层 SSH 已经够
- 想在手机本地跑 Agent 推理的——Moshi 明确不上云、不跑代码
- 没有持续在线 host 的——它是 mobile **control** surface，不是计算端

### 值得学习的产品设计点

1. **客户端 + daemon 双组件**，daemon 端做"统一事件协议"是真正的差异化
2. **Inbox 事件折叠 + 时间衰减** 是异步审批场景的范式
3. **Chat mode** 把"语音直接执行"和"语音组草稿"两种心智模型分开
4. **Theme 驱动整 App**（不只是终端配色），让产品看起来像一个完整体而非工具拼装
5. **Free 层诚实**——核心 SSH 不限，靠 Mosh 这个"日常体验质变"的功能拉付费
6. **Easy Pair**：把 SSH 密钥配置这种最劝退的步骤压缩到扫码

---

> **附：完整调研用到的文档清单（29 页有效）**
>
> introduction · install · first-session · connections · terminal-sessions · tailscale · tmux · zellij · herdr · scrolling · voice · gestures · clipboard · keyboard · cjk-input · agents-usages · apple-watch · image-paste · hooks · moshi-cli · live-activity · diff-viewer · browser-preview · notifications · files · personalization · subscription · security-sync · troubleshooting
