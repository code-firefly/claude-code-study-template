# Agent 配置与使用指南

📚 **来源**: anthropics/anthropic-sdk-typescript GitHub
https://github.com/anthropics/anthropic-sdk-typescript

---

## 快速开始指南

### 步骤 1: 安装 SDK

```bash
npm install @anthropic-ai/sdk
```

### 步骤 2: 设置 API Key

```bash
# 设置环境变量
export ANTHROPIC_API_KEY="your-api-key-here"
```

或创建 `.env` 文件：
```
ANTHROPIC_API_KEY=your-api-key-here
```

### 步骤 3: 创建基本 Agent

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

async function runAgent() {
  const message = await client.messages.create({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: 'Hello, Claude! Can you help me today?'
    }],
  });

  console.log(message.content);
}

runAgent();
```

---

## 工具使用指南

### 创建简单工具

```typescript
import { betaZodTool } from '@anthropic-ai/sdk/helpers/beta/zod';
import { z } from 'zod';

const calculatorTool = betaZodTool({
  name: 'calculate',
  description: '执行基本数学计算',
  inputSchema: z.object({
    expression: z.string().describe('要计算的数学表达式'),
  }),
  run: async (input) => {
    try {
      const result = eval(input.expression);
      return `计算结果: ${result}`;
    } catch (error) {
      return `计算错误: ${error.message}`;
    }
  },
});
```

### 创建多工具 Agent

```typescript
import Anthropic from '@anthropic-ai/sdk';

const anthropic = new Anthropic();

const tools = [
  calculatorTool,
  weatherTool,
  searchTool,
];

async function runMultiToolAgent(userQuery: string) {
  const finalMessage = await anthropic.beta.messages.toolRunner({
    model: 'claude-3-5-sonnet-20241022',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: userQuery,
    }],
    tools: tools,
  });

  return finalMessage;
}
```

---

## 流式响应指南

### 基本流式调用

```typescript
import Anthropic from '@anthropic-ai/sdk';

const anthropic = new Anthropic();

async function streamAgentResponse() {
  const stream = await anthropic.messages.create({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: 'Tell me a short story'
    }],
    stream: true,
  });

  for await (const event of stream) {
    switch (event.type) {
      case 'text':
        process.stdout.write(event.text);
        break;
      case 'tool_use':
        console.log('\n[Tool called]:', event.name);
        break;
      case 'stop':
        console.log('\n[Stream ended]');
        break;
    }
  }
}

streamAgentResponse();
```

### 使用流式辅助函数

```typescript
async function streamWithHelpers() {
  const stream = anthropic.messages
    .stream({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      messages: [{
        role: 'user',
        content: 'Say hello there!',
      }],
    })
    .on('text', (text) => {
      console.log('Text chunk:', text);
    })
    .on('tool_use', (toolUse) => {
      console.log('Tool called:', toolUse.name);
    })
    .on('error', (error) => {
      console.error('Error:', error);
    });

  const message = await stream.finalMessage();
  console.log('Final message:', message);
}
```

---

## MCP 集成指南

### 连接 MCP 服务器

```typescript
import Anthropic from '@anthropic-ai/sdk';
import { mcpTools, mcpMessages } from '@anthropic-ai/sdk/helpers/beta/mcp';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const anthropic = new Anthropic();

// 连接到 MCP 服务器
const transport = new StdioClientTransport({
  command: 'mcp-server',
  args: []
});

const mcpClient = new Client({
  name: 'my-client',
  version: '1.0.0'
});

await mcpClient.connect(transport);
```

### 使用 MCP 工具

```typescript
async function useMcpTools() {
  // 获取 MCP 工具列表
  const { tools } = await mcpClient.listTools();

  // 使用 toolRunner 执行 MCP 工具
  const runner = await anthropic.beta.messages.toolRunner({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: [{
      role: 'user',
      content: 'Use the available tools'
    }],
    tools: mcpTools(tools, mcpClient),
  });

  return runner;
}
```

### 使用 MCP Prompts

```typescript
async function useMcpPrompts() {
  // 获取 MCP prompt
  const { messages } = await mcpClient.getPrompt({
    name: 'my-prompt'
  });

  // 转换并发送到 Claude
  const response = await anthropic.beta.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 1024,
    messages: mcpMessages(messages),
  });

  return response;
}
```

---

## 错误处理指南

### 基本错误处理

```typescript
import Anthropic, { APIError } from '@anthropic-ai/sdk';

const client = new Anthropic();

async function safeAgentCall() {
  try {
    const message = await client.messages.create({
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      messages: [{
        role: 'user',
        content: 'Hello'
      }],
    });
    return message;
  } catch (error) {
    if (error instanceof APIError) {
      console.error('API Error:', error.message);
      console.error('Status:', error.status);

      // 根据错误类型处理
      switch (error.status) {
        case 401:
          console.error('API Key 无效，请检查配置');
          break;
        case 429:
          console.error('请求过于频繁，请稍后重试');
          break;
        case 500:
          console.error('服务器错误，请稍后重试');
          break;
      }
    }
    throw error;
  }
}
```

### 工具错误处理

```typescript
import { ToolError } from '@anthropic-ai/sdk/lib/tools/BetaRunnableTool';

const robustTool = betaZodTool({
  name: 'robust_operation',
  description: '带错误处理的工具',
  inputSchema: z.object({
    input: z.string(),
  }),
  run: async (input) => {
    try {
      // 执行操作
      const result = await performOperation(input);

      if (result.error) {
        // 返回工具错误，包含详细错误信息
        throw new ToolError([
          { type: 'text', text: `操作失败: ${result.error}` },
          { type: 'text', text: '建议: 请检查输入参数' },
        ]);
      }

      return result;
    } catch (error) {
      throw new ToolError(`工具执行异常: ${error.message}`);
    }
  },
});
```

---

## 高级配置

### 自定义超时

```typescript
const client = new Anthropic({
  timeout: 20 * 1000,  // 20 秒超时
});

// 或针对单个请求
await client.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello' }],
}, {
  timeout: 5 * 1000,  // 5 秒超时
});
```

### 配置重试

```typescript
const client = new Anthropic({
  maxRetries: 5,  // 最多重试 5 次（默认 2 次）
});
```

### 使用自定义 Logger

```typescript
import pino from 'pino';

const logger = pino();

const client = new Anthropic({
  logger: logger.child({ name: 'Anthropic' }),
  logLevel: 'debug',  // 显示所有日志
});
```

---

## 性能优化建议

### 1. 使用流式响应

对于长时间任务，使用流式 API：
- 更好的用户体验
- 减少内存占用
- 避免连接超时

### 2. 合理设置 max_tokens

- 简单任务: 512-1024
- 中等任务: 1024-2048
- 复杂任务: 2048-4096

### 3. 启用请求批处理

对于批量任务，使用 Message Batches API：

```typescript
const batch = await anthropic.messages.batches.create({
  requests: [
    {
      custom_id: 'request-1',
      params: {
        model: 'claude-sonnet-4-5-20250929',
        max_tokens: 1024,
        messages: [{ role: 'user', content: 'Hello' }],
      },
    },
    // ... 更多请求
  ],
});
```

### 4. 缓存常见响应

对于重复性查询，考虑实现缓存层

---

## 调试技巧

### 1. 启用详细日志

```typescript
const client = new Anthropic({
  logLevel: 'debug',  // 显示所有请求和响应
});
```

### 2. 使用 Request ID

每个响应包含 `_request_id`，用于调试：

```typescript
const message = await client.messages.create({...});
console.log('Request ID:', message._request_id);
```

### 3. 监控 Token 使用

```typescript
const message = await client.messages.create({...});
console.log('Usage:', message.usage);
// { input_tokens: 25, output_tokens: 13 }
```

---

## 安全最佳实践

### 1. 保护 API Key

- 使用环境变量存储 API Key
- 不要将 API Key 提交到版本控制
- 使用 `.gitignore` 排除 `.env` 文件

### 2. 验证用户输入

在工具中验证所有输入参数：

```typescript
const tool = betaZodTool({
  name: 'safe_tool',
  inputSchema: z.object({
    url: z.string().url().max(2048),  // 验证 URL 格式和长度
  }),
  run: async (input) => {
    // 额外的安全检查
    if (!isAllowedDomain(input.url)) {
      throw new ToolError('域名不在允许列表中');
    }
    // ...
  },
});
```

### 3. 限制工具权限

- 使用最小权限原则
- 为每个工具定义明确的权限边界
- 实施速率限制

---

## 常见问题解决

### Q: 如何处理工具调用超时？

```typescript
const toolWithTimeout = betaZodTool({
  name: 'timed_tool',
  inputSchema: z.object({ input: z.string() }),
  run: async (input) => {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);

    try {
      const result = await fetchWithTimeout(input, { signal: controller.signal });
      clearTimeout(timeoutId);
      return result;
    } catch (error) {
      if (error.name === 'AbortError') {
        throw new ToolError('操作超时（5秒）');
      }
      throw error;
    }
  },
});
```

### Q: 如何实现多轮对话？

```typescript
const conversationHistory = [];

async function chat(userMessage: string) {
  conversationHistory.push({
    role: 'user',
    content: userMessage,
  });

  const response = await client.messages.create({
    model: 'claude-sonnet-4-5-20250929',
    max_tokens: 1024,
    messages: conversationHistory,
  });

  conversationHistory.push(...response.content);

  return response;
}
```

### Q: 如何处理大量工具？

- 对工具进行逻辑分组
- 使用清晰的前缀命名（如 `weather_*`, `search_*`）
- 在工具描述中说明使用场景
