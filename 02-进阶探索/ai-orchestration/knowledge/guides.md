# OpenClaw 使用指南

> **来源**：OpenClaw/openclaw GitHub 仓库
> **文档**：docs/start/openclaw.md, docs/start/getting-started.md
> **更新日期**：2026-03-09

---

## 前置条件

在开始使用 OpenClaw 之前，确保满足以下条件：

- ✅ 已安装和配置 OpenClaw
- ✅ 已完成入门引导（参见 [Getting Started](/start/getting-started)）
- ✅ 拥有第二个手机号码（SIM/eSIM/预付费）用于助手

---

## 安全第一：重要警告

⚠️ **你正在将 Agent 置于可以：**
- 在你的机器上运行命令（取决于你的 Pi 工具设置）
- 读取/写入工作区中的文件
- 通过 WhatsApp/Telegram/Discord/Mattermost 发送消息

**开始保守**：
1. ✅ 始终设置 `channels.whatsapp.allowFrom`
2. ✅ 使用专用 WhatsApp 号码作为助手
3. ✅ 禁用心跳直到你信任设置：`agents.defaults.heartbeat.every: "0m"`

---

## 两手机设置（推荐）

### 推荐架构

```
你的手机（个人）          第二手机（助手）
    WhatsApp                   WhatsApp
  +1-555-YOU      →       +1-555-ASSIST
                                  ↓
                          你的 Mac (openclaw)
                            Pi agent
```

**为什么推荐两手机？**
- 如果将你的个人 WhatsApp 链接到 OpenClaw，发给你的每条消息都变成"Agent 输入"
- 这通常不是你想要的

---

## 5 分钟快速开始

### 步骤 1：配对 WhatsApp Web

```bash
openclaw channels login
```

这会显示 QR 码，用助手手机扫描。

### 步骤 2：启动 Gateway

```bash
openclaw gateway --port 18789
```

保持运行状态。

### 步骤 3：配置基本设置

在 `~/.openclaw/openclaw.json` 中放入最小配置：

```json5
{
  channels: {
    whatsapp: {
      allowFrom: ["+15555550123"]
    },
  },
}
```

### 步骤 4：开始使用

现在从你的允许列表中的手机向助手号码发送消息。

**仪表板访问**：
- 入站完成后，我们会自动打开仪表板并打印一个干净的（非令牌化的）链接
- 如果提示身份验证，将 `gateway.auth.token` 中的令牌粘贴到 Control UI 设置中
- 稍后重新打开：`openclaw dashboard`

---

## 配置 Agent 工作空间

### 默认工作空间

OpenClaw 从其工作空间目录读取操作指令和"内存"。

**默认路径**：`~/.openclaw/workspace`

**自动创建的文件**：
- `AGENTS.md` - Agent 行为指令
- `SOUL.md` - Persona 和性格定义
- `TOOLS.md` - 工具使用指南
- `IDENTITY.md` - 身份标识
- `USER.md` - 用户信息
- `HEARTBEAT.md` - 心跳任务指令
- `BOOTSTRAP.md` - 仅在全新工作空间创建
- `MEMORY.md` - 可选，存在时被加载

**建议**：将此文件夹设为 git 仓库（最好是私有的），以便备份你的 `AGENTS.md` 和内存文件。如果安装了 git，全新工作空间会自动初始化。

### 设置工作空间

```bash
openclaw setup
```

### 自定义工作空间路径

```json5
{
  agent: {
    workspace: "~/.openclaw/workspace",
  },
}
```

### 跳过引导文件创建

如果你已经从仓库提供自己的工作空间文件，可以完全禁用引导文件创建：

```json5
{
  agent: {
    skipBootstrap: true,
  },
}
```

---

## 完整配置示例

### 将配置转换为"助手"

以下是一个完整的助手配置示例：

```json5
{
  // 日志配置
  logging: {
    level: "info",
  },

  // Agent 配置
  agent: {
    model: "anthropic/claude-opus-4-6",
    workspace: "~/.openclaw/workspace",
    thinkingDefault: "high",
    timeoutSeconds: 1800,
    // 初始设置为 0；稍后启用
    heartbeat: {
      every: "0m",
    },
  },

  // 渠道配置
  channels: {
    whatsapp: {
      allowFrom: ["+15555550123"],
      groups: {
        "*": {
          requireMention: true,
        },
      },
    },
  },

  // 路由配置
  routing: {
    groupChat: {
      mentionPatterns: ["@openclaw", "openclaw"],
    },
  },

  // 会话配置
  session: {
    scope: "per-sender",
    resetTriggers: ["/new", "/reset"],
    reset: {
      mode: "daily",
      atHour: 4,
      idleMinutes: 10080,
    },
  },
}
```

---

## 会话和内存管理

### 会话文件位置

- **会话文件**：`~/.openclaw/agents/<agentId>/sessions/{{SessionId}}.jsonl`
- **会话元数据**（令牌使用、最后路由等）：`~/.openclaw/agents/<agentId>/sessions/sessions.json`
  - 遗留路径：`~/.openclaw/sessions/sessions.json`

### 会话控制命令

| 命令 | 说明 |
|------|------|
| `/new` 或 `/reset` | 为该聊天启动新会话 |
| `/compact [instructions]` | 压缩会话上下文并报告剩余上下文预算 |

**说明**：
- `/new` 或 `/reset` 可通过 `resetTriggers` 配置
- 如果单独发送，Agent 会回复简短的问候以确认重置

---

## 心跳系统（主动模式）

### 默认行为

- **默认间隔**：每 30 分钟
- **提示词**：`Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.`

### 心跳配置

```json5
{
  agent: {
    heartbeat: {
      every: "30m",        // 设置为 "0m" 禁用
      directPolicy: "allow", // 或 "block" 以抑制直接目标投递
      ackMaxChars: 1000,    // HEARTBEAT_OK 最大字符数
    },
  },
}
```

### 心跳行为

| 条件 | 行为 |
|------|------|
| `HEARTBEAT.md` 存在且为空 | 跳过心跳运行以节省 API 调用 |
| `HEARTBEAT.md` 缺失 | 心跳仍运行，由模型决定做什么 |
| 回复 `HEARTBEAT_OK` | 抑制该心跳的出站投递 |
| 间隔设置为 `"0m"` | 禁用心跳 |

### 心跳最佳实践

**开始时**：设置 `agents.defaults.heartbeat.every: "0m"` 禁用心跳

**信任后**：逐步启用，例如：
```json5
{
  agent: {
    heartbeat: {
      every: "1h",  // 每小时一次
    },
  },
}
```

---

## 媒体处理

### 入站媒体

入站附件（图片/音频/文档）可以通过模板传递给命令：

| 模板变量 | 说明 |
|----------|------|
| `{{MediaPath}}` | 本地临时文件路径 |
| `{{MediaUrl}}` | 伪 URL |
| `{{Transcript}}` | 音频转录（如果启用） |

### 出站媒体

Agent 可以通过包含媒体来发送附件：

```
Here's the screenshot.
MEDIA:https://example.com/screenshot.png
```

**规则**：
- `MEDIA:<path-or-url>` 必须在单独一行
- 行内不能有空格
- OpenClaw 会提取这些内容并将其作为媒体与文本一起发送

---

## 运维清单

### 状态检查

```bash
# 本地状态（凭据、会话、队列事件）
openclaw status

# 完整诊断（只读、可粘贴）
openclaw status --all

# 添加 Gateway 健康探测（Telegram + Discord）
openclaw status --deep

# Gateway 健康快照（WS）
openclaw health --json
```

### 日志位置

日志位于 `/tmp/openclaw/`（默认：`openclaw-YYYY-MM-DD.log`）

---

## 常见任务

### 启动 Gateway

```bash
# 基本启动
openclaw gateway

# 指定端口
openclaw gateway --port 18789

# 后台运行
nohup openclaw gateway --port 18789 > /tmp/openclaw-gateway.log 2>&1 &
```

### 停止 Gateway

```bash
# 查找进程
ps aux | grep openclaw

# 终止进程
pkill -f openclaw-gateway
```

### 配置 WhatsApp

```bash
# 登录
openclaw channels login

# 配对
openclaw channels pair whatsapp
```

### 查看仪表板

```bash
# 打开仪表板
openclaw dashboard
```

---

## 故障排除

### 问题：Gateway 无法启动

**检查**：
1. 端口是否被占用：`lsof -i :18789`
2. 日志：`tail -f /tmp/openclaw/openclaw-*.log`
3. 配置：`openclaw config show`

### 问题：WhatsApp 无法连接

**检查**：
1. 网络连接
2. WhatsApp Web 是否正常工作
3. QR 码是否过期

### 问题：Agent 不响应

**检查**：
1. Gateway 是否运行：`openclaw status`
2. API 凭据是否有效
3. 会话是否被重置：尝试发送 `/new`

---

## 下一步

### 相关文档

| 主题 | 文档 |
|------|------|
| WebChat | [WebChat](/web/webchat) |
| Gateway 运维 | [Gateway runbook](/gateway) |
| Cron + 唤醒 | [Cron jobs](/automation/cron-jobs) |
| 安全 | [Security](/gateway/security) |

### 平台特定指南

| 平台 | 文档 |
|------|------|
| macOS 菜单栏配套应用 | [OpenClaw macOS app](/platforms/macos) |
| iOS node 应用 | [iOS app](/platforms/ios) |
| Android node 应用 | [Android app](/platforms/android) |
| Windows 状态 | [Windows (WSL2)](/platforms/windows) |
| Linux 应用 | [Linux app](/platforms/linux) |

---

## 最佳实践

### 1. 安全配置

- ✅ 始终使用 `allowFrom` 限制消息来源
- ✅ 使用专用手机号码作为助手
- ✅ 禁用心跳直到你信任设置
- ✅ 定期审查工作空间文件

### 2. 会话管理

- ✅ 定期使用 `/compact` 压缩长会话
- ✅ 设置合理的会话重置策略
- ✅ 监控令牌使用情况

### 3. 工作空间维护

- ✅ 将工作空间设为 git 仓库
- ✅ 定期提交重要更改
- ✅ 备份 `AGENTS.md` 和内存文件

### 4. 监控和日志

- ✅ 定期检查 `openclaw status`
- ✅ 审查 `/tmp/openclaw/` 中的日志
- ✅ 设置适当的日志级别

---

## 配置参考

### 完整配置选项

```json5
{
  // 日志配置
  logging: {
    level: "info" | "debug" | "warn" | "error",
  },

  // Agent 配置
  agent: {
    model: "anthropic/claude-opus-4-6",
    workspace: "~/.openclaw/workspace",
    thinkingDefault: "low" | "medium" | "high",
    timeoutSeconds: 1800,
    heartbeat: {
      every: "30m",
      directPolicy: "allow" | "block",
      ackMaxChars: 1000,
    },
    skipBootstrap: false,
  },

  // 渠道配置
  channels: {
    whatsapp: {
      allowFrom: ["+15555550123"],
      groups: {
        "*": {
          requireMention: true,
        },
      },
    },
  },

  // 路由配置
  routing: {
    groupChat: {
      mentionPatterns: ["@openclaw", "openclaw"],
    },
  },

  // 会话配置
  session: {
    scope: "per-sender" | "global" | "per-channel",
    resetTriggers: ["/new", "/reset"],
    reset: {
      mode: "daily" | "manual" | "idle",
      atHour: 4,
      idleMinutes: 10080,
    },
  },

  // Gateway 配置
  gateway: {
    mode: "local" | "remote",
    port: 18789,
  },
}
```

---

## 常见用例

### 1. 个人助理

配置一个可以通过 WhatsApp 访问的个人助理：
- 设置专用 WhatsApp 号码
- 配置 `allowFrom` 限制访问
- 在工作空间中定义个人偏好

### 2. 群聊助手

在群聊中添加 OpenClaw 作为助手：
- 设置 `requireMention: true`
- 配置 `mentionPatterns`
- 定义群聊特定行为

### 3. 自动化任务

使用心跳系统执行自动化任务：
- 在 `HEARTBEAT.md` 中定义任务
- 设置合理的间隔
- 配置 `directPolicy` 控制通知

### 4. 多渠道集成

统一管理多个消息渠道：
- 配置多个渠道
- 使用统一的会话作用域
- 定义渠道特定行为
