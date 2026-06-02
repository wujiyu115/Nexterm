# Sonar 项目原理分析

> 项目地址：https://github.com/RasKrebs/sonar

Sonar 是一个 Go 编写的 CLI 工具，用来查看本机所有监听中的 TCP 端口，并关联出对应的进程信息和 Docker 容器信息。

## 整体架构

```
main.go → cmd (cobra命令) → ports (扫描/丰富) + docker (容器信息) + display (输出渲染)
```

核心只依赖一个第三方库：`spf13/cobra`（命令行框架），其余全部靠调用操作系统原生命令实现，零 CGO、零网络库依赖。

### 目录结构

```
sonar/
├── main.go                  # 入口，调用 cmd.Execute()
├── internal/
│   ├── cmd/                 # cobra 命令定义（list, kill, logs, graph 等）
│   ├── ports/               # 端口扫描、进程丰富、健康检查、依赖图
│   ├── docker/              # Docker 容器信息采集与统计
│   ├── display/             # 表格/JSON 输出渲染
│   ├── config/              # YAML 配置文件解析
│   ├── notify/              # 桌面通知（macOS/Linux/Windows）
│   ├── profile/             # 端口 profile 持久化
│   ├── selfupdate/          # 自更新机制
│   └── tray/                # macOS 菜单栏 tray app 启动器
├── tray/
│   └── SonarTray.swift      # 原生 Swift 菜单栏应用
└── scripts/                 # 安装脚本
```

## 核心工作流程（以 `sonar list` 为例）

### 第一步：端口扫描

文件：`internal/ports/scan.go`

根据操作系统调用不同的系统命令：

| 平台 | 命令 |
|------|------|
| macOS | `lsof -iTCP -sTCP:LISTEN -n -P` |
| Linux | `ss -tlnp` |
| Windows | `netstat -ano` |

解析命令输出，提取每个监听端口的端口号、PID、进程名、绑定地址、IP 版本，组装成 `ListeningPort` 结构体数组。用 `port:bindAddr` 做去重。

### 第二步：Docker 丰富

文件：`internal/docker/docker.go`

执行 `docker ps --format` 获取所有运行中容器的名称、镜像、端口映射、Compose service/project。构建 `hostPort → container` 的映射表，将匹配的端口标记为 `PortTypeDocker`，填入容器名、镜像、Compose 信息、容器内端口。

### 第三步：进程丰富

文件：`internal/ports/enrich.go`

- 收集所有 PID，通过一次 `ps -o pid=,command=` 调用（Windows 用 PowerShell `Get-CimInstance`）批量获取完整命令行
- 分类端口类型：`<1024` 为 system，`>=1024` 为 user，已标记 Docker 的保持不变
- 检测桌面应用：macOS 看路径是否包含 `.app/`，Windows 看是否在 `\Windows\`、`\AppData\` 等路径
- 收集父进程命令行、工作目录、服务管理器标签，为 `DisplayName()` 提供信号

### 第四步（可选）：统计信息

仅在 `--stats` 时触发：

- **Docker 容器**：直接连接 `/var/run/docker.sock` Unix socket，发送 HTTP/1.0 请求到 Docker Engine API（`/containers/{id}/stats`、`/containers/{id}/json`），获取 CPU、内存、PID 数、状态、启动时间。所有容器并发请求。
- **原生进程**：一次 `ps` 调用批量获取 CPU、RSS、线程数、状态、启动时间
- **连接数**：macOS/Linux 用 `lsof`/`ss` 计数，Windows 用 `netstat`

### 第五步：渲染输出

文件：`internal/display/`

支持表格（彩色对齐）和 JSON 两种输出格式。表格支持自定义列、排序、过滤。

## 其他功能原理

| 功能 | 命令 | 原理 |
|------|------|------|
| 杀进程 | `sonar kill <port>` | 原生进程发 `SIGTERM`/`SIGKILL`，Docker 容器调用 `docker stop` |
| 查看日志 | `sonar logs <port>` | Docker 走 `docker logs -f`，原生进程用 `lsof` 查找打开的日志文件然后 `tail` |
| 依赖图 | `sonar graph` | 用 `lsof -i` / `ss -tnp` / `netstat -ano` 找 ESTABLISHED 连接，筛选出"本机监听端口 A 的进程连向本机监听端口 B"的关系 |
| 等待端口 | `sonar wait <port>` | 循环 `net.DialTimeout` TCP 探测，可选 HTTP GET 检查 200-399 状态码 |
| 端口映射 | `sonar map <src> <dst>` | 本地 TCP 代理（`net.Listen` + `io.Copy` 双向转发） |
| 实时监控 | `sonar watch` | 定时轮询 Scan，diff 前后结果，高亮新增/消失的端口 |
| 进入容器 | `sonar attach <port>` | Docker 容器走 `docker exec -it sh`，原生进程走 TCP 连接 |
| 端口快照 | `sonar profile` | 将当前端口列表序列化为 YAML 存到 `~/.config/sonar/profiles/` |
| 远程扫描 | `sonar list --host` | SSH 执行远端的 `ss -tlnp` 并解析输出 |
| 菜单栏应用 | `sonar tray` | 原生 Swift 写的 macOS 菜单栏应用，定时调用 sonar CLI 获取数据 |
| 查找空闲端口 | `sonar next` | 从指定起始端口开始尝试 `net.Listen`，找到可用端口 |

## 数据模型

核心结构体 `ListeningPort`（`internal/ports/model.go`）：

```go
type ListeningPort struct {
    Port        int       // 监听端口号
    PID         int       // 进程 ID
    Process     string    // 短进程名（如 "node"）
    Command     string    // 完整命令行
    User        string    // 所属用户
    BindAddress string    // 绑定地址
    Type        PortType  // system / user / docker

    // 进程统计
    CPUPercent  float64
    MemoryRSS   int64
    ThreadCount int
    Uptime      string

    // Docker 字段
    DockerContainer      string
    DockerImage          string
    DockerComposeService string
    DockerComposeProject string
    DockerContainerPort  int
}
```

## 设计亮点

1. **零依赖扫描** — 不依赖任何 Go 网络库去探测端口，而是直接解析 OS 原生命令（`lsof`/`ss`/`netstat`）的输出，速度快且信息完整

2. **批量系统调用** — 收集所有 PID 后一次性调 `ps`，而不是每个进程调一次，减少系统调用开销

3. **Docker Engine API 直连** — 统计信息不走 `docker` CLI，而是直接连 Unix socket 发 HTTP/1.0 请求，省掉 CLI 启动开销，且并发获取所有容器数据

4. **智能进程命名** — 通过父进程命令行、工作目录、systemd/launchd 标签、interpreter 感知等多个信号，推断出人类可读的进程名（优先级：Compose service > 容器名 > 服务管理器标签 > 解析后的命令行 > 进程名）

5. **桌面应用过滤** — 自动隐藏 Figma、Discord、Spotify 等不相关的桌面应用端口，开发者只看到开发相关的端口

6. **跨平台适配** — 通过 `_darwin.go`、`_linux.go`、`_windows.go` 后缀文件实现平台特定逻辑，编译时自动选择
