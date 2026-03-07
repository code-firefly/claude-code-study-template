# mcp-protocol 学习笔记

> **学习模式**：快速模式
> **开始日期**：2026-03-07
> **完成日期**：2026-03-07

---

## 学习记录

### 2026-03-07
- ✅ 初始化知识缓存（overview, concepts, guides）
- ✅ 开始快速模式学习
- ✅ 完成 overview.md 阅读，理解 MCP 基本概念和架构
- ✅ 创建书签：当前项目作为 MCP Server 的可行性
- ✅ 完成 concepts.md 阅读，深入理解 MCP 核心概念与架构
- ✅ 完成 guides.md 阅读，学习 MCP 最佳实践和部署
- ✅ 整理关键知识点清单
- 🎉 快速模式学习全部完成

---

## 核心概念

### 什么是 MCP？

**Model Context Protocol (MCP)** 是一种开放标准，允许应用程序以标准化的方式为 LLM 提供上下文。它将提供上下文的关注点与实际的 LLM 交互分离开来。

### MCP 的三大组成部分

| 组件 | 定义 | 功能 |
|------|------|------|
| **MCP Server** | 提供上下文的应用程序 | 暴露工具、提供资源、定义提示 |
| **MCP Client** | 使用 Server 上下文的应用 | 发现、连接、调用工具/资源 |
| **Transports** | 通信机制 | stdio、HTTP、SSE 等 |

### 三种上下文类型

| 类型 | URI 格式 | 用途 | 示例 |
|------|----------|------|------|
| **工具** | `tool://<name>` | LLM 可调用的函数 | 数据库查询、API 调用 |
| **资源** | `resource://<path>` | LLM 可读取的数据 | 文件、日志、配置、**动态 MD** |
| **提示** | `prompt://<name>` | 可复用的提示模板 | 代码审查、文档生成 |

### MCP 核心价值

- **标准化**：统一的协议，一次构建多处使用
- **解耦**：上下文提供与 LLM 交互分离
- **可扩展**：支持多种上下文类型和传输方式
- **跨平台**：支持 stdio、HTTP 等多种传输层

---

## 架构理解

### MCP 五层架构

```
┌─────────────────────────────────────────┐
│         应用层              │
│     Claude Desktop, AI IDEs            │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        MCP Client Layer                 │
│    连接管理、协议处理、工具调用          │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        Transport Layer                  │
│      stdio / HTTP / SSE                 │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│        MCP Server Layer                 │
│   工具执行、资源提供、提示管理           │
└─────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│       数据源 / 服务                      │
│  文件系统、数据库、API、外部服务         │
└─────────────────────────────────────────┘
```

### 架构设计原则

| 原则 | 实现 |
|------|------|
| **分层解耦** | 应用-客户端-传输-服务器-数据，五层独立 |
| **协议统一** | 基于 JSON-RPC 2.0 的标准化通信 |
| **传输抽象** | Transports 层抽象，支持多种通信方式 |
| **类型分离** | 工具（执行）、资源（读取）、提示（模板）分离 |

### MCP Server 生命周期

1. **启动阶段**：Server 启动，初始化资源，等待连接
2. **初始化阶段**：交换能力信息，建立 Session
3. **运行阶段**：处理工具调用、提供资源访问、管理提示
4. **关闭阶段**：处理未完成请求，保存状态，释放资源

### 三种交互模式

| 模式 | 特点 | 适用场景 |
|------|------|----------|
| **同步模式** | 请求-响应 | 简单查询、状态获取 |
| **流式模式** | 持续数据流 | 大文件传输、实时生成 |
| **订阅模式** | 实时推送 | 日志监控、数据更新 |

### MCP 协议消息（JSON-RPC 2.0）

**核心方法**：
- `initialize` - 初始化连接
- `tools/list` - 列出可用工具
- `tools/call` - 调用工具
- `resources/list` - 列出可用资源
- `resources/read` - 读取资源
- `prompts/list` - 列出可用提示
- `prompts/get` - 获取提示内容

---

## 最佳实践

### 工具设计原则

| 原则 | 说明 | 示例 |
|------|------|------|
| **单一职责** | 每个工具只做一件事 | `read_file` 而非 `file_operations` |
| **清晰命名** | 使用动词+名词 | `create_user` 而非 `user` |
| **详细描述** | 说明功能和用途 | "创建新用户，需要邮箱和用户名" |
| **明确 Schema** | 定义清晰的输入输出 | 使用 JSON Schema |

### 资源组织策略

| 策略 | 说明 | URI 示例 |
|------|------|----------|
| **按类型** | 资源类型在前 | `resource://file/config` |
| **按层级** | 反映数据层级 | `resource://db/users/123` |
| **按环境** | 区分环境 | `resource://prod/api/status` |

### 错误处理最佳实践

- 返回有意义的错误信息
- 提供解决建议
- 使用适当的错误码
- 记录详细的错误日志

### 安全考虑

| 风险 | 防护措施 |
|------|----------|
| **路径遍历** | 验证和规范化路径 |
| **命令注入** | 使用参数化查询 |
| **敏感数据** | 加密传输和存储 |
| **权限提升** | 实施最小权限原则 |

---

## 配置与设置

### Claude Desktop 配置

在 `~/Library/Application Support/Claude/claude_desktop_config.json` 中添加：

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/server.js"]
    }
  }
}
```

### stdio 传输配置
```json
{
  "command": "node",
  "args": ["server.js"],
  "env": {}
}
```

### HTTP 传输配置
```json
{
  "url": "https://api.example.com/mcp",
  "headers": {
    "Authorization": "Bearer xxx"
  }
}
```

---

## 常见模式

### 1. 分页处理
```typescript
server.setRequestHandler('tools/call', async (request) => {
  const { page = 1, limit = 10 } = request.params.arguments;
  const offset = (page - 1) * limit;
  const results = await fetchPaginated(offset, limit);
  return {
    content: [{ type: 'text', text: JSON.stringify(results) }],
    _meta: { page, limit, hasMore: results.length === limit }
  };
});
```

### 2. 流式响应
```typescript
server.setRequestHandler('tools/call', async (request) => {
  const stream = getDataStream();
  return {
    content: [{ type: 'text', text: stream }],
    _meta: { stream: true }
  };
});
```

### 3. 缓存资源
```typescript
const cache = new Map();
server.setRequestHandler('resources/read', async (request) => {
  const { uri } = request.params;
  if (cache.has(uri)) return { contents: [cache.get(uri)] };
  const data = await fetchResource(uri);
  cache.set(uri, data);
  return { contents: [data] };
});
```

---

## 调试技巧

### 1. 日志记录
```typescript
if (process.env.NODE_ENV === 'development') {
  server.on('request', (request) => {
    console.log('[MCP Request]', request.method, request.params);
  });
}
```

### 2. 验证工具
使用 Zod 进行输入验证

### 3. 测试工具
- MCP Inspector: `npx @modelcontextprotocol/inspect`
- 单元测试框架

---

## 部署建议

### 本地开发
- 使用 stdio 传输
- 热重载支持
- 详细日志

### 生产环境
- 使用 HTTP 传输
- 负载均衡
- 错误监控
- 限流保护

### Docker 部署
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
CMD ["node", "server.js"]
```

---

## 权限与安全

### 权限模型

| 级别 | 说明 | 示例 |
|------|------|------|
| **读取** | 只读访问 | 读取文件、查询数据 |
| **写入** | 修改数据 | 写入文件、更新记录 |
| **执行** | 运行命令 | 执行脚本、调用 API |
| **危险** | 高风险操作 | 删除文件、系统更改 |

### 安全特性

- **显式授权**：危险操作需要用户确认
- **作用域限制**：限制可访问的资源范围
- **审计日志**：记录所有操作
- **传输安全**：支持 TLS/SSL

---

## 常用命令/操作

| 命令/操作 | 用途 | 实践经验 |
|-----------|------|----------|
| `npm install @modelcontextprotocol/server` | 安装 MCP Server SDK | - |
| `npm install @modelcontextprotocol/client` | 安装 MCP Client SDK | - |
| `npx @modelcontextprotocol/inspect` | MCP Inspector 调试工具 | 测试 Server |
| `initialize` | 初始化 MCP 连接 | - |

---

## 关键知识点清单（快速复习）

### 一句话概念

| 概念 | 一句话解释 |
|------|-----------|
| **MCP** | Model Context Protocol - AI 上下文提供的开放标准 |
| **MCP Server** | 提供工具、资源、提示给 AI 的应用 |
| **MCP Client** | 连接并使用 MCP Server 的应用（如 Claude Desktop） |
| **Transports** | Server 与 Client 之间的通信机制（stdio/HTTP） |

### 三种上下文类型速查

| 类型 | 是什么 | URI 格式 | 典型用途 |
|------|--------|----------|----------|
| **工具** | AI 调用的函数 | `tool://<name>` | 执行操作（查询、写入、计算） |
| **资源** | AI 读取的数据 | `resource://<path>` | 获取信息（文件、日志、配置） |
| **提示** | 可复用的提示模板 | `prompt://<name>` | 标准化任务（代码审查、文档生成） |

### 核心协议方法

```
初始化阶段:
  initialize        → 建立连接，交换能力

工具操作:
  tools/list       → 列出可用工具
  tools/call       → 调用工具执行

资源操作:
  resources/list   → 列出可用资源
  resources/read   → 读取资源内容

提示操作:
  prompts/list     → 列出可用提示
  prompts/get      → 获取提示内容
```

### 架构层次（5层）

```
应用层 → Client层 → Transport层 → Server层 → 数据层
 ↓        ↓         ↓            ↓          ↓
用户    AI 应用    通信协议    MCP服务    实际数据
```

### 传输方式选择

| 方式 | 适用场景 | 优点 |
|------|----------|------|
| **stdio** | 本地开发、测试 | 简单、无需配置 |
| **HTTP** | 远程服务、生产环境 | 可扩展、支持负载均衡 |

### 交互模式速查

| 模式 | 特点 | 何时使用 |
|------|------|----------|
| **同步** | 请求-响应 | 简单查询 |
| **流式** | 持续数据流 | 大文件、实时生成 |
| **订阅** | 实时推送 | 日志监控、数据更新 |

### 工具设计四原则

1. **单一职责** - 每个工具只做一件事
2. **清晰命名** - 动词+名词（如 `read_file`）
3. **详细描述** - 说明功能和用途
4. **明确 Schema** - 定义输入输出

### 安全检查清单

- [ ] 路径遍历防护：验证和规范化路径
- [ ] 命令注入防护：使用参数化查询
- [ ] 敏感数据保护：加密传输和存储
- [ ] 权限最小化：只授予必要权限

### 常用命令速查

| 命令 | 功能 |
|------|------|
| `npm install @modelcontextprotocol/server` | 安装 Server SDK |
| `npm install @modelcontextprotocol/client` | 安装 Client SDK |
| `npx @modelcontextprotocol/inspect` | 启动调试工具 |

### Claude Desktop 配置路径

| 平台 | 配置文件路径 |
|------|-------------|
| **macOS** | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| **Windows** | `%APPDATA%\Claude\claude_desktop_config.json` |
| **Linux** | `~/.config/Claude/claude_desktop_config.json` |

---

## 学习心得与总结

### 核心收获

1. **MCP 的分层架构设计非常清晰**，每层职责独立，易于理解和扩展
2. **JSON-RPC 2.0 作为通信协议**，简单且标准化，降低了实现复杂度
3. **三种上下文类型（工具、资源、提示）** 覆盖了 AI 与数据交互的所有场景
4. **多种交互模式（同步、流式、订阅）** 让 MCP 能适应不同的应用需求
5. **动态 Markdown 文件可以作为资源**，这为项目作为 MCP Server 提供了可能

### 实践要点

1. **工具设计要遵循单一职责**：每个工具只做一件事，便于复用和维护
2. **安全是首要考虑**：路径遍历、命令注入等风险需要主动防范
3. **调试工具很重要**：MCP Inspector 可以帮助快速测试 Server
4. **根据环境选择传输方式**：本地用 stdio，生产用 HTTP
5. **错误处理要友好**：提供清晰的错误信息和解决建议

### 重要理解

- **工具 vs 资源**：工具是 LLM 调用的函数（执行操作），资源是 LLM 读取的数据（获取信息）
- **stdio vs HTTP**：stdio 适合本地开发，HTTP 适合远程和微服务
- **动态资源**：内容实时生成的资源（如从数据库生成的 Markdown 报告）
- **Claude Desktop**：官方桌面客户端，通过 MCP 连接自定义 Server

### 待深入探索的主题

- 当前项目作为 MCP Server 的具体实现（书签 1）
- MCP 的实际应用场景和最佳实践
- 如何创建一个生产级的 MCP Server
- Python SDK 的使用和实现

---

## 问题与解决方案

| 问题 | 解决方案 |
|------|----------|
| 动态 Markdown 文件可以作为 MCP 资源吗？ | 可以！资源是按内容类型（静态/动态/可订阅）区分，而非文件格式。Markdown 是文本格式，完全适合作为资源，且 AI 友好。 |
| 如何选择传输方式？ | 本地开发用 stdio，远程/生产环境用 HTTP |
| 工具和资源的区别是什么？ | 工具是 LLM 调用的函数（执行操作），资源是 LLM 读取的数据（获取信息） |
| Claude Desktop 是什么？ | Anthropic 官方桌面应用，支持 MCP 连接，可扩展 Claude 能力 |
| TypeScript 和 Python SDK 选哪个？ | 根据技术栈选择：Node.js/Web 用 TypeScript，数据科学/Python 后端用 Python |
