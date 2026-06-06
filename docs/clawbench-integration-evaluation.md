# ClawBench 功能集成评估方案

> 基于 ClawBench 深度调研 + Nexterm 现有架构分析

---

## 项目对比概览

| 维度 | Nexterm | ClawBench |
|------|---------|-----------|
| 定位 | 全功能跨平台 SSH 终端客户端 | 移动端 AI 编程工作台 |
| 技术栈 | Flutter/Dart + FastAPI/Python | Go + Vue 3 |
| 终端 | xterm.dart（本地 SSH） | PTY + WebSocket + xterm.js（本地 shell） |
| AI 能力 | 无 | 9+ AI CLI 后端透传 |
| 语音 | STT（3 个供应商） | TTS（5 个引擎） |
| 定时任务 | 无 | Cron 调度 |
| 文件管理 | SFTP / SMB / WebDAV | 预览为主，不直接编辑 |

**互补性结论**：两个项目在终端领域有交集，但能力互补。Nexterm 强在远程连接管理（SSH/SFTP/端口转发），ClawBench 强在 AI 智能体和语音交互。

---

## 可集成功能评估

### 功能 1：AI 终端助手（推荐优先级：⭐⭐⭐⭐⭐）

**ClawBench 的做法**：将 AI CLI 工具透传为 HTTP/SSE 接口，在 Web 终端中与 AI 交互。

**Nexterm 集成方案**：

在终端会话中嵌入 AI 辅助面板，用户可以：
- 用自然语言描述需求，AI 生成 Shell 命令
- 选中终端输出，让 AI 解释错误或优化命令
- AI 根据当前 SSH 会话上下文（OS 类型、已安装工具）给出适配的建议

```
┌──────────────────────────┐
│  SSH Terminal             │
│  $ systemctl status nginx │
│  ● nginx.service - ...    │
│  Active: failed           │
├──────────────────────────┤
│  🤖 AI: nginx 启动失败，   │
│  检查日志：                 │
│  journalctl -u nginx -n 50│
│  [插入到终端] [复制]        │
└──────────────────────────┘
```

**技术实现**：
- 新建 `features/ai_assistant/` 模块
- 接入方式：直接调用 LLM API（OpenAI / Anthropic / DeepSeek 等），不走 ClawBench 的 CLI 透传路线（Nexterm 是移动端原生 App，无法运行 CLI 工具）
- 复用现有 `SttProvider` 架构，设计类似的 `LlmProvider` 插件接口
- 上下文注入：从 SSH 会话获取 OS 信息（`uname -a`）、shell 类型、最近命令历史
- UI：在终端底部或侧边栏添加可收起的 AI 面板

**工作量**：中等（2-3 周）
**风险**：低，独立模块不影响现有功能

---

### 功能 2：TTS 语音播报（推荐优先级：⭐⭐⭐⭐）

**ClawBench 的做法**：5 个 TTS 引擎（Edge TTS / MiniMax / Piper / Kokoro / MOSS-TTS-Nano），AI 回复自动总结后朗读。

**Nexterm 集成方案**：

Nexterm 已有完善的 STT 语音输入系统，加入 TTS 形成语音交互闭环：
- 终端输出关键事件语音播报（命令执行完毕、错误告警、连接断开）
- AI 助手回复语音朗读（配合功能 1）
- 系统监控告警语音通知（CPU/内存超阈值）

**技术实现**：
- 新建 `features/terminal/services/tts/` 目录，复用 STT 的插件架构
- `TtsProvider` 接口 + 实现：
  - `SystemTtsProvider`：使用 Flutter 的 `flutter_tts` 包（系统原生）
  - `EdgeTtsProvider`：借鉴 ClawBench，调用 Edge TTS 免费接口
  - `RemoteApiTtsProvider`：对接 MiniMax 等云端服务
- 设置页复用现有 STT 设置区块的 UI 模式

**工作量**：小（1 周）
**风险**：极低，`flutter_tts` 是成熟的 Flutter 包

---

### 功能 3：定时任务调度（推荐优先级：⭐⭐⭐⭐）

**ClawBench 的做法**：Cron 表达式定时执行 AI 任务。

**Nexterm 集成方案**：

对 SSH 终端客户端来说，定时任务场景非常自然：
- 定时执行远程命令（数据库备份、日志清理、健康检查）
- 定时连接检活（批量 ping 所有主机）
- 执行结果推送通知 + 历史记录

```
┌─ 定时任务管理 ─────────────────┐
│                                │
│  📋 每日备份                    │
│  主机: prod-db-01              │
│  命令: /opt/backup.sh          │
│  Cron: 0 2 * * *              │
│  状态: ✅ 上次成功 06:02:01     │
│                                │
│  📋 健康检查                    │
│  主机: [web-01, web-02, web-03]│
│  命令: systemctl is-active app │
│  Cron: */5 * * * *            │
│  状态: ⚠️ web-02 异常          │
│                                │
│  [+ 新建任务]                   │
└────────────────────────────────┘
```

**技术实现**：
- 新建 `features/scheduler/` 模块
- 数据层：Drift 表 `scheduled_tasks`（cron 表达式、关联主机 ID、命令、启用状态、上次结果）
- 服务层：`SchedulerService` 使用 `cron` Dart 包解析表达式，`Timer` 驱动执行
- 前台执行：App 在前台时本地调度
- 后台/服务端执行：通过 FastAPI 后端代理执行（复用 cloud sync 的服务端架构），或使用 Flutter 的 `workmanager` 包后台执行
- 结果通知：复用现有 `NotificationService`

**工作量**：中等（2 周）
**风险**：中等，后台执行在 iOS 上受限，需考虑平台差异

---

### 功能 4：命令/输出智能总结（推荐优先级：⭐⭐⭐）

**ClawBench 的做法**：AI 回复自动总结，支持 12+ 总结后端。

**Nexterm 集成方案**：

- 长输出自动摘要（`docker logs`、`journalctl` 等大量输出时生成摘要）
- 错误日志智能分析（自动提取关键错误、给出修复建议）
- 监控数据趋势描述（将 CPU/内存数据转为自然语言描述）

**技术实现**：
- 依赖功能 1 的 `LlmProvider` 基础设施
- 在终端输出缓冲区满/命令执行完毕时触发
- 摘要结果显示在终端上方浮层或通知中

**工作量**：小（基于功能 1 实现后，额外 3-5 天）
**风险**：低，但需注意 token 消耗成本

---

### 功能 5：文件预览内联 AI 交互（推荐优先级：⭐⭐⭐）

**ClawBench 的做法**：Markdown/代码预览中选中文本即可向 AI 提问或请求修改。

**Nexterm 集成方案**：

在 SFTP 文件浏览器的代码预览中：
- 选中代码片段，弹出 AI 操作菜单（解释 / 优化 / 查找问题）
- AI 生成修改建议，用户确认后通过 SFTP 写回

**技术实现**：
- 扩展现有 SFTP 模块的代码编辑器组件
- 添加文本选择回调 → AI 面板
- 修改后通过已有的 SFTP 写入通道保存

**工作量**：中等（1-2 周，基于功能 1）
**风险**：低

---

### 功能 6：多 Agent 调度（推荐优先级：⭐⭐）

**ClawBench 的做法**：不同任务匹配不同 AI 智能体，自动发现已安装的 CLI 工具。

**Nexterm 集成方案**：

对 Nexterm 场景略重，但可以简化为：
- 不同类型的任务使用不同 LLM（运维问题用擅长运维的模型，代码问题用编程模型）
- 用户可配置多个 LLM 供应商，按场景自动选择

**工作量**：小（基于功能 1 的 Provider 架构天然支持）
**风险**：低，但用户认知成本较高

---

## 集成优先级总览

```
Phase 1（核心价值，建议立即启动）
├── AI 终端助手        ⭐⭐⭐⭐⭐  2-3 周  投入产出比最高
└── TTS 语音播报       ⭐⭐⭐⭐   1 周    与现有 STT 形成闭环

Phase 2（增强体验，Phase 1 完成后）
├── 定时任务调度        ⭐⭐⭐⭐   2 周    SSH 客户端的自然需求
└── 命令智能总结        ⭐⭐⭐    3-5 天  复用 AI 基础设施

Phase 3（锦上添花）
├── 文件预览 AI 交互    ⭐⭐⭐    1-2 周  提升 SFTP 体验
└── 多 Agent 调度       ⭐⭐     架构已支持  按需开启
```

---

## 不建议集成的功能

| ClawBench 功能 | 不集成的原因 |
|---------------|------------|
| CLI 透传架构 | Nexterm 是移动原生 App，无法在设备上运行 AI CLI 工具。应直接调用 LLM API |
| Web 终端 (PTY + xterm.js) | Nexterm 已有 xterm.dart 终端实现，且通过 SSH 连接远程而非本地 shell |
| 零适配透传哲学 | 设计理念不匹配。Nexterm 需要的是轻量 API 集成，而非透传本地 CLI |
| 设置向导 (23 供应商 567 模型) | 过重。Nexterm 只需支持 3-5 个主流 LLM 供应商即可 |
| DuckDB RAG 向量存储 | 移动端资源受限，不适合运行向量数据库 |

---

## 架构建议

```
nexterm/lib/features/
├── ai_assistant/              ← 新增
│   ├── data/
│   │   └── providers/
│   │       ├── llm_provider.dart          (抽象接口)
│   │       ├── openai_provider.dart
│   │       ├── anthropic_provider.dart
│   │       └── deepseek_provider.dart
│   ├── domain/
│   │   └── entities/
│   │       ├── ai_message.dart
│   │       └── ai_config.dart
│   ├── services/
│   │   ├── ai_context_service.dart        (从 SSH 会话提取上下文)
│   │   └── command_suggestion_service.dart
│   └── ui/
│       ├── widgets/
│       │   ├── ai_panel.dart
│       │   └── command_suggestion_card.dart
│       └── pages/
│           └── ai_settings_page.dart
├── tts/                       ← 新增
│   ├── services/
│   │   ├── tts_provider.dart              (抽象接口，复用 STT 模式)
│   │   ├── system_tts_provider.dart
│   │   └── edge_tts_provider.dart
│   └── ui/
│       └── widgets/
│           └── tts_settings_section.dart
└── scheduler/                 ← 新增
    ├── data/
    │   ├── tables/
    │   │   └── scheduled_tasks_table.dart
    │   └── daos/
    │       └── scheduled_tasks_dao.dart
    ├── services/
    │   └── scheduler_service.dart
    └── ui/
        ├── pages/
        │   └── scheduler_page.dart
        └── widgets/
            └── task_card.dart
```

核心设计原则：复用 Nexterm 已有的模块化架构（Riverpod + Drift + 分层结构），每个新功能独立成 feature 模块，不侵入现有代码。

---

*评估基于 ClawBench 调研报告 (docs/clawbench-research.md) 和 Nexterm 源码分析。*
