# Terminal Pro — iOS SSH Client Design Spec

> 户外科技融合风格 | 毛玻璃轻度方案 | 深色 + 浅色双模式 | 7 屏完整原型

---

## 1. 设计定位

**风格关键词：** 户外科技融合（Outdoor Tech Fusion）

自然徒步的温度感 + 终端工具的精密感。不是冷硬的纯科技风，也不是软暖的户外休闲风，而是两者的交叉 — 像在山顶帐篷里打开笔记本连 SSH。

**设计原则：**
- 克制的毛玻璃，不喧宾夺主
- 绿色 accent 作为唯一强调色，最多两处高亮
- 自然纹理（等高线、山脊、噪点）作为底蕴，不作为装饰主角
- iOS 原生设计语言（Large Title、分组卡片、底部 Tab Bar）

---

## 2. 配色体系

### 2.1 核心色板

| Token | 深色模式 | 浅色模式 | 用途 |
|-------|----------|----------|------|
| `--accent` | `#5cb85c` | `#5cb85c` | 自然徒步绿，全局唯一强调色 |
| `--accent-dim` | `rgba(92, 184, 92, 0.15)` | 同左 | 标签/徽章/图标容器底色 |
| `--accent-glow` | `rgba(92, 184, 92, 0.3)` | 同左 | 辉光/投影/光斑 |
| `--bg` | `#0d1117` 深林夜色 | `#f5f0e6` 暖土色 | 页面背景 |
| `--bg-elevated` | `#161b22` | `#faf8f3` | 弹起层背景 |
| `--surface` | `rgba(22, 27, 34, 0.78)` | `rgba(255, 255, 255, 0.78)` | 半透明面板 |
| `--surface-solid` | `#1c2128` | `#ffffff` | 不透明面板 |
| `--fg` | `#e6edf3` | `#1a1a1a` | 主文字 |
| `--fg-secondary` | `#8b949e` | `#6b7280` | 次要文字 |
| `--fg-tertiary` | `#484f58` | `#9ca3af` | 占位/禁用文字 |
| `--border` | `rgba(48, 54, 61, 0.6)` | `rgba(0, 0, 0, 0.08)` | 分隔线/边框 |
| `--nav-bg` | `rgba(13, 17, 23, 0.72)` | `rgba(245, 240, 230, 0.72)` | 导航栏毛玻璃底 |
| `--card-bg` | `rgba(22, 27, 34, 0.65)` | `rgba(255, 255, 255, 0.65)` | 卡片毛玻璃底 |
| `--input-bg` | `rgba(30, 36, 44, 0.8)` | `rgba(0, 0, 0, 0.04)` | 输入框/搜索框底 |
| `--glass-border` | `rgba(92, 184, 92, 0.08)` | `rgba(92, 184, 92, 0.12)` | 毛玻璃卡片边框 |

### 2.2 终端配色

| 元素 | 色值 | 说明 |
|------|------|------|
| 终端背景 | 深色 `#0d1117` / 浅色 `#1e1e2e` | 浅色模式终端仍保持暗色 |
| 命令提示符 | `var(--accent)` `#5cb85c` | 绿色箭头 `→` |
| 路径 | `#89b4fa` | 蓝色路径标记 |
| 命令文字 | `#cdd6f4` | 主要输出色 |
| 输出文字 | `#8b949e` | 次要灰色 |
| 光标 | `var(--accent)` | 绿色方块闪烁 |

### 2.3 状态色

| 状态 | 深色 | 浅色 |
|------|------|------|
| 在线 | `#3fb950` | `#5cb85c` |
| 离线 | `#484f58` | `#d1d5db` |
| Tab 未激活 | `#484f58` | `#9ca3af` |

---

## 3. 排版规范

### 3.1 字体栈

| 角色 | 字体栈 |
|------|--------|
| 系统字体 `--font` | `-apple-system, BlinkMacSystemFont, 'SF Pro Text', system-ui, sans-serif` |
| 等宽字体 `--font-mono` | `'SF Mono', 'JetBrains Mono', ui-monospace, Menlo, monospace` |

### 3.2 字号体系

| 层级 | 字号 | 字重 | 字间距 | 使用场景 |
|------|------|------|--------|----------|
| Large Title | 34px | 700 | -0.5px | 导航栏大标题（主机/密钥/片段/转发/设置） |
| Nav Title Small | 17px | 600 | — | 二级页面标题（添加主机） |
| Body Primary | 16px | 600 | — | 主机名/设置项名称 |
| Body | 15px | 400/600 | — | 通用正文/表单标签 |
| Status Bar | 14px | 600 | — | 时间/信号 |
| Section Label | 13px | 600 | 0.5px | 分组标签，大写 |
| Meta | 13px | 400 | — | 主机地址/设置描述 |
| Code | 13px (mono) | 400 | — | 终端内容 |
| Snippet Code | 12px (mono) | 400 | — | 代码片段 |
| Badge/Tag | 11px | 500 | — | 标签/语言标记 |
| Tab Label | 10px | 500 | — | 底部 Tab 文字 |

---

## 4. 圆角体系

| 元素 | 圆角值 | Token |
|------|--------|-------|
| 手机外壳 | 54px | 硬编码（iPhone 15 Pro 比例） |
| Dynamic Island | 20px | 硬编码 |
| 卡片 / 终端容器 | 14px | `--radius` |
| 输入框 / 搜索栏 / 按钮 | 10px | `--radius-sm` |
| 代码块 / 小元素 | 8px | `--radius-xs` |
| 工具栏按钮 / 终端标签 | 6px | 硬编码 |
| 语言标签 | 4px | 硬编码 |
| 状态灯 / Home 指示条 | 50% / 3px | 圆形 |

---

## 5. 毛玻璃效果（轻度方案）

### 5.1 层级定义

| 层级 | 模糊值 | 饱和度 | 应用位置 |
|------|--------|--------|----------|
| 重度磨砂 | `blur(20px)` | `saturate(180%)` | 导航栏、Tab 栏 |
| 中度磨砂 | `blur(12px)` | `saturate(150%)` | 卡片、主题切换按钮、终端工具栏 |
| 轻度磨砂 | `blur(8px)` | — | 搜索框 |

### 5.2 玻璃边框

- 卡片边框：`0.5px solid var(--glass-border)`
- 深色模式：绿色 8% 透明度
- 浅色模式：绿色 12% 透明度
- 导航/Tab 分隔线：`0.5px solid var(--border)`

---

## 6. 纹理与装饰层

### 6.1 地形等高线（Topographic Contours）

```
位置：手机壳全屏覆盖
元素：SVG 椭圆组（3组等高线环 + 2组横贯线条 + 1组底部等高线环）
描边：accent 绿色，0.8px 宽度
透明度：深色 3.5% / 浅色 6%
效果：像地形图底纹，增加户外质感
```

等高线分布：
- 右上区域（cx:280 cy:160）：4 层嵌套椭圆，旋转 -12°
- 左中区域（cx:80 cy:380）：4 层嵌套椭圆，旋转 8°
- 右下区域（cx:320 cy:580）：3 层嵌套椭圆，旋转 -18°
- 中部横贯线（y:250/260）：贝塞尔曲线模拟地势变化
- 底部横贯线（y:650/665）：同上
- 底部等高线（cx:200 cy:780）：2 层椭圆，旋转 5°

### 6.2 胶片噪点（Film Grain）

```
实现：SVG feTurbulence 滤镜
参数：fractalNoise, baseFrequency 0.9, 4 octaves
大小：128px × 128px 平铺
混合模式：overlay
透明度：深色 25% / 浅色 15%
效果：消除数字化的"干净"感，增加有机手感
```

### 6.3 渐变光斑（Ambient Glows）

| 光斑 | 位置 | 尺寸 | 颜色 | 透明度 |
|------|------|------|------|--------|
| 主光斑 | 右上角偏移 | 300×300px | accent 绿 | 30% |
| 辅光斑 | 左下区域 | 240×240px | accent 绿 12% | 100% |
| 冷调光斑 | 右中区域 | 180×180px | 蓝色 6% | 100% |

### 6.4 山脊剪影（Terrain Ridge）

```
位置：Tab Bar 上方，120px 高度
层数：2 层叠加
前层：accent 绿，50% 透明度
后层：accent 绿，30% 透明度
绘制：SVG polygon + 贝塞尔曲线模拟不规则山脊线
透明度叠加：深色 4% / 浅色 6%
效果：像远处山脊的剪影，呼应户外主题
```

---

## 7. 组件效果

### 7.1 卡片（Card）

```css
/* 基础 */
background: var(--card-bg);          /* 半透明 */
backdrop-filter: blur(12px) saturate(150%);
border: 0.5px solid var(--glass-border);
border-radius: 14px;
padding: 14px 16px;

/* 光泽层 ::before */
background: linear-gradient(135deg,
  rgba(92,184,92,0.08) 0%,
  transparent 40%,
  transparent 60%,
  rgba(92,184,92,0.04) 100%
);
/* 对角线微渐变，模拟玻璃折射 */

/* 按压反馈 */
:active {
  transform: scale(0.98);
  background: var(--accent-dim);
}
```

### 7.2 在线状态灯（Host Status）

```css
/* 在线状态 */
width: 10px; height: 10px;
border-radius: 50%;
background: var(--status-online);
box-shadow: 0 0 8px var(--accent-glow);   /* 辉光 */

/* 脉冲环动画 ::after */
border: 1px solid var(--accent);
animation: pulse-ring 2.5s ease-out infinite;
/* 从 scale(1) opacity(0.3) → scale(1.8) opacity(0) */

/* 离线状态：灰色，无辉光，无脉冲 */
```

### 7.3 分组标签（Section Label）

```css
font-size: 13px;
font-weight: 600;
color: var(--accent);
text-transform: uppercase;
letter-spacing: 0.5px;

/* 发光竖线 ::before */
width: 3px; height: 12px;
background: var(--accent);
border-radius: 2px;
box-shadow: 0 0 6px var(--accent-glow);  /* 竖线辉光 */
```

### 7.4 导航大标题（Nav Title）

```css
font-size: 34px;
font-weight: 700;
letter-spacing: -0.5px;

/* 底部渐隐绿线 ::after */
width: 32px; height: 2px;
background: linear-gradient(90deg, var(--accent), transparent);
/* 从左到右渐变消失 */
```

### 7.5 图标容器光泽（Key/Fwd/Settings Icon）

```css
/* 斜向反光条 ::after */
background: linear-gradient(135deg,
  transparent 40%,
  rgba(92,184,92,0.15) 50%,
  transparent 60%
);
/* 模拟材质表面的光线折射 */
```

### 7.6 终端网格底纹（Terminal Grid）

```css
/* ::before 伪元素 */
background-image:
  linear-gradient(rgba(92,184,92,0.02) 1px, transparent 1px),
  linear-gradient(90deg, rgba(92,184,92,0.02) 1px, transparent 1px);
background-size: 20px 20px;
/* 像示波器/CRT 显示器的扫描线 */
```

### 7.7 光标闪烁（Terminal Cursor）

```css
width: 8px; height: 16px;
background: var(--accent);
animation: blink 1s infinite;
/* 50% 时间可见，50% 时间消失 */
```

### 7.8 开关（Toggle）

```css
width: 44px; height: 26px;
border-radius: 13px;
/* 关闭态：var(--fg-tertiary) */
/* 开启态：var(--accent) */
/* 圆形滑块 22×22px，白色，带投影 */
/* 过渡：transform 0.3s（滑块）+ background 0.3s（轨道） */
```

### 7.9 搜索栏（Search Bar）

```css
background: var(--input-bg);
backdrop-filter: blur(8px);
border: 0.5px solid var(--border);
border-radius: 10px;
/* 搜索图标 16×16 + 占位文字 */
```

### 7.10 主题切换按钮（Theme Toggle）

```css
width: 36px; height: 36px;
border-radius: 50%;
background: var(--card-bg);
backdrop-filter: blur(12px);
border: 0.5px solid var(--border);
/* 深色：太阳图标 / 浅色：月亮图标 */
/* 位置：右上角，z-index 90 */
/* 按压：scale(0.9) */
```

---

## 8. 动画与过渡

| 动画 | 参数 | 应用 |
|------|------|------|
| 通用过渡 | `0.3s cubic-bezier(0.4, 0, 0.2, 1)` | 卡片、背景切换 |
| Tab 切换 | `0.2s ease` | 图标/文字颜色变化 |
| 光标闪烁 | `1s infinite` | 终端光标 |
| 脉冲环 | `2.5s ease-out infinite` | 在线状态灯 |
| 按压缩放 | `scale(0.98)` / `scale(0.9)` | 卡片/主题按钮 |
| 开关滑动 | `transform 0.3s` | Toggle 滑块 |

---

## 9. 屏幕清单

| # | 屏幕 | ID | 主要组件 |
|---|------|----|----------|
| 1 | 主机列表 | `screen-hosts` | 搜索栏 + 分组卡片（收藏/开发/测试）+ 在线状态灯 + 星标 + 右上角添加按钮 |
| 2 | 终端 | `screen-terminal` | 多标签终端 + 命令行输出 + 底部快捷键工具栏（Tab/Ctrl/方向键/Paste/^C/^D） |
| 3 | 密钥管理 | `screen-keys` | SSH 密钥列表（类型/日期/绑定数）+ 已知主机入口 + 右上角添加按钮 |
| 4 | 代码片段 | `screen-snippets` | 搜索栏 + 片段卡片（标题 + 语言标签 + 等宽代码块） |
| 5 | 端口转发 | `screen-forwarding` | 活跃/暂停分组 + 转发规则（方向+端口映射）+ Toggle 开关 + 右上角添加按钮 |
| 6 | 设置 | `screen-settings` | 通用/终端/安全/反馈分组 + 字体大小滑块 + Toggle 开关 + 版本号 |
| 7 | 添加主机 | `screen-add-host` | 表单（别名/地址/端口/用户名）+ 认证切换（密钥/密码）+ 分组/标签/启动命令 + 测试连接按钮 |

---

## 10. 交互行为

| 交互 | 实现 |
|------|------|
| Tab 切换 | 6 个底部 Tab 控制 6 个主屏幕，状态存储 `localStorage` |
| 主题切换 | 右上角按钮切换 `data-theme`，状态存储 `localStorage` |
| 添加主机 | 主机页右上角 `+` 按钮跳转第 7 屏，`取消` 返回 |
| 认证切换 | 密钥/密码按钮组互斥激活 |
| Toggle 开关 | 点击切换 `on` class |
| 卡片按压 | `:active` 缩放 + 背景变绿 |

---

## 11. iOS 原生规范遵循

| 规范 | 实现 |
|------|------|
| 设备尺寸 | 393 × 852px（iPhone 15 Pro） |
| Dynamic Island | 126 × 37px，顶部居中 |
| 状态栏 | 时间 + 信号/WiFi/电池图标 |
| Home 指示条 | 134 × 5px，底部居中，30% 透明度 |
| Large Title | 34px / 700weight，iOS 标准 |
| Tab Bar 高度 | 90px（含 34px 安全区域） |
| 触摸目标 | Tab 项/按钮均 ≥ 44px |

---

## 12. 文件信息

| 属性 | 值 |
|------|-----|
| 文件名 | `terminal-pro-ios.html` |
| 类型 | 单文件自包含 HTML |
| CSS | 内联 `<style>`，约 900 行 |
| JS | 内联 `<script>`，约 56 行 |
| 依赖 | 无外部依赖 |
| 总行数 | ~1508 行 |
