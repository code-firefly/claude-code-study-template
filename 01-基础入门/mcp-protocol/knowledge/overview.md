# MCP 协议概述

> **来源**：MCP 官方文档和 SDK README
> **更新日期**：2026-03-07

---

## 什么是 MCP？

**Model Context Protocol (MCP)** 是一种开放标准，允许应用程序以标准化的方式为 LLM（大语言模型）提供上下文。它将提供上下文的关注点与实际的 LLM 交互分离开来。

### 核心价值

| 特性 | 说明 |
|------|------|
| **标准化** | 统一的协议，不同的 AI 应用可以使用相同的服务 |
| **解耦** | 上下文提供与 LLM 交互分离 |
| **可扩展** | 支持工具、资源、提示等多种上下文类型 |
| **跨平台** | 支持多种传输方式（stdio、HTTP 等） |

---

## MCP 的组成

### 1. MCP Server（服务器）
- **定义**：提供上下文（工具、资源、提示）的应用程序
- **功能**：
  - 暴露工具（Tools）供 LLM 调用
  - 提供资源（Resources）供 LLM 读取
  - 定义提示模板（Prompts）供 LLM 使用
- **实现**：使用 MCP SDK 构建（TypeScript、Python 等）

### 2. MCP Client（客户端）
- **定义**：连接到 MCP Server 并使用其上下文的应用程序
- **功能**：
  - 发现和连接服务器
  - 列出可用的工具/资源/提示
  - 调用工具、读取资源、使用提示
- **示例**：Claude Desktop、AI 编程工具等

### 3. Transports（传输层）
- **定义**：Server 和 Client 之间的通信机制
- **类型**：
  - **stdio**：标准输入/输出（适合本地开发）
  - **Streamable HTTP**：基于 HTTP 的流式传输
  - **SSE**：Server-Sent Events
- **作用**：透明的数据传输，与 MCP 协议逻辑解耦

---

## MCP 核心概念

### 三种上下文类型

| 类型 | URI 格式 | 用途 | 示例 |
|------|----------|------|------|
| **工具 (Tools)** | `tool://<name>` | 可执行的函数 | 数据库查询、API 调用 |
| **资源 (Resources)** | `resource://<path>` | 静态或动态数据 | 文件、日志、配置 |
| **提示 (Prompts)** | `prompt://<name>` | 可复用的提示模板 | 代码审查、文档生成 |

### 工具 (Tools)
- LLM 可以**主动调用**的函数
- 带有输入 schema（使用 JSON Schema）
- 返回执行结果（文本、图片、数据等）
- 示例：读取文件、搜索数据库、执行 CLI 命令

### 资源 (Resources)
- LLM 可以**读取**的数据源
- 可以是静态（文件）或动态（API 响应）
- 支持订阅（实时更新）
- 示例：日志文件、配置、API 数据

### 提示 (Prompts)
- 预定义的**提示模板**
- 可以接受参数进行定制
- 提高提示的重用性和一致性
- 示例：代码审查提示、文档生成模板

---

## MCP 工作流程

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   LLM       │◄────────�│ MCP Client  │◄────────┤ MCP Server  │
│  (Claude)   │  请求/  │             │  传输/  │             │
│             │  响应   │             │  协议   │             │
└─────────────┘         └─────────────┘         └─────────────┘
                              │
                              ▼
                        ┌─────────────┐
                        │  Transports │
                        │ (stdio/HTTP)│
                        └─────────────┘
```

### 典型交互流程

1. **连接**：Client 连接到 Server（通过 stdio 或 HTTP）
2. **初始化**：交换能力信息（initialize）
3. **发现**：Client 请求可用的工具/资源/提示列表
4. **使用**：
   - LLM 请求调用工具 → Client 转发 → Server 执行 → 返回结果
   - LLM 请求读取资源 → Client 转发 → Server 提供数据
   - LLM 使用提示 → Client 获取模板 → 填充参数 → 发送给 LLM

---

## MCP SDK 生态系统

### TypeScript SDK
- **仓库**：modelcontextprotocol/typescript-sdk
- **包**：
  - `@modelcontextprotocol/server` - 构建服务器
  - `@modelcontextprotocol/client` - 构建客户端
  - `@modelcontextprotocol/express` - Express 集成
  - `@modelcontextprotocol/hono` - Hono 集成
  - `@modelcontextprotocol/node` - Node.js HTTP 集成

### Python SDK
- **仓库**：modelcontextprotocol/python-sdk
- **用途**：Python 环境中构建 MCP Server

### 示例服务器
- **仓库**：modelcontextprotocol/servers
- **包含**：常用工具的 MCP Server 实现

---

## MCP vs 传统集成

| 对比项 | 传统方式 | MCP 方式 |
|--------|----------|----------|
| **协议** | 各自定义 | 统一标准 |
| **集成** | 点对点 | 一对多 |
| **维护** | 分散 | 集中 |
| **扩展** | 困难 | 简单 |
| **可重用** | 低 | 高 |

---

## 使用场景

### 适合使用 MCP 的场景

- 需要为多个 AI 应用提供相同的数据/功能
- 希望构建可重用的 AI 工具集成
- 需要标准化的 AI 应用架构
- 跨多个 AI 平台提供服务

### 典型应用

- **数据访问**：数据库、API、文件系统
- **开发工具**：Git、包管理器、CI/CD
- **企业系统**：CRM、ERP、内部工具
- **云服务**：AWS、Azure、GCP 集成
