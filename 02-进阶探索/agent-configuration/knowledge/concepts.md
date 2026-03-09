# Agent 核心概念

📚 **来源**: anthropics/anthropic-sdk-typescript GitHub + Agent SDK 文档
https://github.com/anthropics/anthropic-sdk-typescript

---

## 1. Agent 与 Chatbot 的区别

### Chatbot
- **被动响应**: 根据用户输入直接生成回复
- **单轮交互**: 通常基于当前输入生成输出
- **无工具能力**: 无法主动调用外部服务

### Agent
- **自主决策**: 根据任务目标自主规划和执行
- **多步骤推理**: 能够分解复杂任务并逐步完成
- **工具调用**: 可以主动调用外部工具和 API
- **循环控制**: 持续运行直到任务完成

---

## 2. Agent 核心能力

### 2.1 工具调用 (Tool Use)

Agent 能够根据需要调用预定义的工具：

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
```

**关键点**：
- 工具需要明确定义输入 schema
- 工具应该有清晰的描述，帮助 Agent 理解何时使用
- `toolRunner` 自动处理工具调用流程

### 2.2 循环控制 (Loop Control)

Agent 在循环中运行，持续决策和执行：

1. **接收输入**: 用户请求或当前状态
2. **分析任务**: 理解需要完成的任务
3. **选择工具**: 决定是否需要调用工具
4. **执行工具**: 调用选定的工具
5. **处理结果**: 解析工具返回的结果
6. **判断完成**: 决定是否继续或结束

### 2.3 状态管理

Agent 需要维护内部状态：

```typescript
interface AgentState {
  messages: Message[];
  toolResults: ToolResult[];
  currentStep: number;
  completed: boolean;
}
```

**状态类型**：
- 对话历史 (messages)
- 工具执行历史 (toolResults)
- 当前进度 (currentStep)
- 完成状态 (completed)

### 2.4 多步骤推理

Agent 能够将复杂任务分解为多个步骤：

**示例**: "帮我查询旧金山的天气，然后告诉我适合穿什么衣服"

1. 步骤 1: 识别需要查询天气
2. 步骤 2: 调用天气工具，获取天气信息
3. 步骤 3: 根据天气信息，分析穿衣建议
4. 步骤 4: 生成最终回复

---

## 3. Agent 类型

### 3.1 信息检索型 Agent

**功能**: 主动搜索和获取信息

**特点**:
- 使用搜索工具
- 整合多个信息源
- 过滤和总结信息

**示例工具**:
- Web 搜索工具
- 数据库查询工具
- 文档检索工具

### 3.2 任务执行型 Agent

**功能**: 执行具体的操作任务

**特点**:
- 调用 API 执行操作
- 管理操作流程
- 处理执行错误

**示例工具**:
- API 调用工具
- 文件操作工具
- 数据处理工具

### 3.3 编程辅助型 Agent

**功能**: 帮助编写和调试代码

**特点**:
- 理解代码上下文
- 生成代码片段
- 执行和测试代码

**示例工具**:
- 代码执行工具
- 文件读写工具
- 测试运行工具

### 3.4 领域专用型 Agent

**功能**: 专注于特定领域的任务

**示例**:
- **数据分析 Agent**: 处理数据和生成报告
- **客服 Agent**: 处理客户咨询
- **写作 Agent**: 辅助内容创作

---

## 4. 工具定义方式

### 4.1 使用 Zod Schema

```typescript
import { z } from 'zod';
import { betaZodTool } from '@anthropic-ai/sdk/helpers/beta/zod';

const tool = betaZodTool({
  name: 'calculate',
  inputSchema: z.object({
    expression: z.string().describe('数学表达式'),
  }),
  description: '计算数学表达式',
  run: (input) => {
    return eval(input.expression);
  },
});
```

### 4.2 使用 JSON Schema

```typescript
const tool = {
  name: 'send_email',
  description: '发送电子邮件',
  input_schema: {
    type: 'object',
    properties: {
      to: { type: 'string', description: '收件人' },
      subject: { type: 'string', description: '主题' },
      body: { type: 'string', description: '正文' },
    },
    required: ['to', 'subject', 'body'],
  },
  handler: async (input) => {
    // 发送邮件逻辑
  },
};
```

### 4.3 工具最佳实践

1. **清晰的名称**: 使用描述性名称，如 `get_weather` 而非 `tool1`
2. **详细的描述**: 说明工具的功能和使用场景
3. **明确的参数**: 参数应该有清晰的类型和描述
4. **错误处理**: 妥善处理工具执行错误
5. **返回格式**: 统一的返回数据格式

---

## 5. 参数设置

### 5.1 模型选择

```typescript
model: 'claude-sonnet-4-5-20250929'  // 最新 Sonnet
// 或
model: 'claude-3-5-sonnet-20241022'   // 稳定版本
```

### 5.2 Token 限制

```typescript
max_tokens: 1024  // 最大输出 token 数
```

**建议**:
- 简单任务: 512-1024
- 中等任务: 1024-2048
- 复杂任务: 2048-4096

### 5.3 温度设置

```typescript
// SDK 中通过 API 参数控制
// 较低温度 (0-0.3): 更确定性的输出
// 较高温度 (0.7-1): 更创造性的输出
```

---

## 6. 错误处理

### 6.1 工具错误

```typescript
import { ToolError } from '@anthropic-ai/sdk/lib/tools/BetaRunnableTool';

const screenshotTool = betaZodTool({
  name: 'take_screenshot',
  inputSchema: z.object({ url: z.string() }),
  run: async (input) => {
    if (!isValidUrl(input.url)) {
      throw new ToolError(`Invalid URL: ${input.url}`);
    }
    // ...
  },
});
```

### 6.2 API 错误

```typescript
try {
  const message = await client.messages.create({...});
} catch (error) {
  if (error instanceof Anthropic.APIError) {
    console.log(error.status);  // 400, 401, 429, 500, etc.
    console.log(error.name);    // BadRequestError, AuthenticationError, etc.
  }
}
```

### 错误类型

| 状态码 | 错误类型 | 说明 |
|--------|----------|------|
| 400 | BadRequestError | 请求格式错误 |
| 401 | AuthenticationError | API Key 无效 |
| 403 | PermissionDeniedError | 权限不足 |
| 404 | NotFoundError | 资源不存在 |
| 429 | RateLimitError | 超出速率限制 |
| 500+ | InternalServerError | 服务器错误 |

---

## 7. Agent 设计原则

### 7.1 单一职责

每个 Agent 应该专注于特定类型的任务

### 7.2 工具组合

通过组合多个简单工具实现复杂功能

### 7.3 状态最小化

只保存必要的状态信息

### 7.4 可观察性

提供清晰的日志和调试信息

### 7.5 优雅降级

工具调用失败时，提供备选方案
