# Agent SDK 概述

📚 **来源**: anthropics/anthropic-sdk-typescript GitHub
https://github.com/anthropics/anthropic-sdk-typescript

---

## 什么是 Anthropic TypeScript SDK

Anthropic TypeScript SDK 是用于访问 Claude API 的官方 TypeScript/JavaScript 客户端库。它提供了便捷的方式来集成 Claude 的强大功能到你的应用中。

### 主要特性

- **完整的 TypeScript 支持**: 包含所有请求参数和响应字段的 TypeScript 定义
- **流式响应**: 使用 Server Sent Events (SSE) 支持流式响应
- **工具使用 (Tool Use)**: 支持 function calling 功能
- **MCP 集成**: 提供与 Model Context Protocol 服务器集成的辅助函数
- **消息批处理**: 支持 Message Batches API
- **错误处理**: 完善的错误类型和自动重试机制

## 安装

```bash
npm install @anthropic-ai/sdk
```

## 快速开始

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: process.env['ANTHROPIC_API_KEY'],
});

const message = await client.messages.create({
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello, Claude' }],
  model: 'claude-sonnet-4-5-20250929',
});

console.log(message.content);
```

## SDK 核心概念

### 1. 消息 API (Messages API)

Messages API 是与 Claude 交互的主要方式，支持：
- 单轮和多轮对话
- 流式和非流式响应
- 工具使用
- 多模态内容（文本、图片等）

### 2. 工具使用 (Tool Use)

允许 Claude 调用外部工具和函数，实现 Agent 能力：

```typescript
const weatherTool = betaZodTool({
  name: 'get_weather',
  inputSchema: z.object({
    location: z.string(),
  }),
  description: 'Get the current weather in a given location',
  run: (input) => {
    return `The weather in ${input.location} is foggy and 60°F`;
  },
});

const finalMessage = await anthropic.beta.messages.toolRunner({
  model: 'claude-3-5-sonnet-20241022',
  max_tokens: 1000,
  messages: [{ role: 'user', content: 'What is the weather in San Francisco?' }],
  tools: [weatherTool],
});
```

### 3. 流式响应

对于长时间运行的任务，推荐使用流式 API：

```typescript
const stream = await client.messages.create({
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello, Claude' }],
  model: 'claude-sonnet-4-5-20250929',
  stream: true,
});

for await (const messageStreamEvent of stream) {
  console.log(messageStreamEvent.type);
}
```

### 4. MCP 集成

SDK 提供了 MCP 辅助函数，方便与 MCP 服务器集成：

```typescript
import { mcpTools, mcpMessages, mcpResourceToContent } from '@anthropic-ai/sdk/helpers/beta/mcp';

// 连接 MCP 服务器
const mcpClient = new Client({ name: 'my-client', version: '1.0.0' });
await mcpClient.connect(transport);

// 使用 MCP 工具
const { tools } = await mcpClient.listTools();
const runner = await anthropic.beta.messages.toolRunner({
  model: 'claude-sonnet-4-20250514',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Use the available tools' }],
  tools: mcpTools(tools, mcpClient),
});
```

## 环境要求

### 支持的运行时

- Node.js 20 LTS 或更高版本
- Deno v1.28.0 或更高版本
- Bun 1.0 或更高版本
- Cloudflare Workers
- Vercel Edge Runtime

### TypeScript 要求

TypeScript >= 4.9

## 高级特性

### Beta 功能

SDK 提供了 beta API 功能访问，如代码执行等：

```typescript
const response = await client.beta.messages.create({
  max_tokens: 1024,
  model: 'claude-sonnet-4-5-20250929',
  messages: [{ role: 'user', content: "What's 4242424242 * 4242424242?" }],
  tools: [{ name: 'code_execution', type: 'code_execution_20250522' }],
  betas: ['code-execution-2025-05-22'],
});
```

### 错误处理

```typescript
const message = await client.messages
  .create({
    max_tokens: 1024,
    messages: [{ role: 'user', content: 'Hello, Claude' }],
    model: 'claude-sonnet-4-5-20250929',
  })
  .catch(async (err) => {
    if (err instanceof Anthropic.APIError) {
      console.log(err.status); // 400
      console.log(err.name); // BadRequestError
      console.log(err.headers);
    }
  });
```

### 自动重试

某些错误会自动重试 2 次（默认）：
- 连接错误
- 408 Request Timeout
- 409 Conflict
- 429 Rate Limit
- >=500 Internal Server Error

可配置重试次数：

```typescript
const client = new Anthropic({
  maxRetries: 5, // 默认是 2
});
```

## 与 Agent 的关系

Agent SDK 构建在 TypeScript SDK 之上，提供：
- **工具编排**: 自动管理工具调用流程
- **循环控制**: 控制 Agent 的决策循环
- **状态管理**: 管理 Agent 的内部状态
- **多步骤推理**: 支持复杂的多步骤任务完成

TypeScript SDK 是基础 API 客户端，而 Agent SDK 是更高级的抽象，专门用于构建自主 Agent。
