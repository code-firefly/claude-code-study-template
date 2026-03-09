# agent-configuration 学习笔记

> **学习模式**：完整模式
> **开始日期**：2026-03-09
> **完成日期**：待定

---

## 学习记录

- **2026-03-09**: 开始完整模式学习，初始化知识缓存
- **2026-03-09**: 完成 SDK 概述学习
  - TypeScript SDK 基本概念和安装
  - Messages API、工具使用、流式响应
  - MCP 集成
- **2026-03-09**: 完成核心概念学习
  - Agent vs Chatbot 的区别
  - 工具调用（Tool Use）机制
  - 循环控制（Loop Control）
  - 状态管理（内部状态 vs 上下文）
  - 多步骤推理
  - Agent 类型（信息检索、任务执行、编程辅助、领域专用）
  - 工具定义方式（Zod Schema、JSON Schema）
  - 参数设置和错误处理
  - Agent 设计原则

---

## 核心概念

### Agent vs Chatbot

| 特性 | Chatbot | Agent |
|------|---------|-------|
| 响应方式 | 被动响应 | 自主决策 |
| 交互模式 | 单轮交互 | 多步骤推理 |
| 能力边界 | 无工具能力 | 工具调用 + API |
| 运行机制 | 请求-响应 | 循环控制直到完成 |

**关键转变**：从"问答系统"到"任务执行系统"

### Agent 四大核心能力

1. **工具调用 (Tool Use)**
   - Claude 根据需要调用预定义工具
   - `toolRunner` 自动处理调用流程
   - 工具需要清晰的 schema 和 description

2. **循环控制 (Loop Control)**
   ```
   接收输入 → 分析任务 → 选择工具 → 执行工具 → 处理结果 → 判断完成
        ↑                                              ↓
        └──────────────── 未完成则继续 ──────────────────┘
   ```

3. **状态管理**
   - **API 可见状态**：messages、toolResults（进入上下文）
   - **内部状态**：currentStep、completed（控制逻辑，不发送给 API）

4. **多步骤推理**
   - 将复杂任务分解为多个步骤
   - 每步可能调用不同工具
   - 依赖前一步的结果继续推理

### Agent 类型

- **信息检索型**：搜索、查询、整合信息
- **任务执行型**：API 调用、文件操作、数据处理
- **编程辅助型**：代码生成、执行、测试
- **领域专用型**：数据分析、客服、写作等

---

## 架构理解

### SDK 分层设计

```
┌─────────────────────────────────────┐
│     Claude Code (完整 IDE)          │  ← 顶层：AI 开发环境
├─────────────────────────────────────┤
│     Agent SDK (高级抽象)            │  ← 中层：工具编排、状态管理
├─────────────────────────────────────┤
│   TypeScript SDK (基础 API)         │  ← 底层：直接 API 访问
├─────────────────────────────────────┤
│        Claude API                   │  ← 接口层
└─────────────────────────────────────┘
```

### TypeScript SDK 架构

- **Messages API**：与 Claude 交互的主要方式
- **工具使用**：`betaZodTool`、`toolRunner`
- **流式响应**：Server Sent Events (SSE)
- **MCP 集成**：`mcpTools`、`mcpMessages` 辅助函数

### 内部状态 vs 上下文

```typescript
interface AgentState {
  messages: Message[];      // ✅ 进入上下文（对话历史）
  toolResults: ToolResult[]; // ✅ 进入上下文（工具结果）
  currentStep: number;       // ❌ 内部使用（控制逻辑）
  completed: boolean;        // ❌ 内部使用（完成判断）
}
```

**设计原则**：
- 只有对话相关的信息进入 API 上下文
- 控制逻辑变量保留在 Agent 内部
- 节省 Token，保护实现细节

---

## 配置与设置

### TypeScript 基础

**什么是 TypeScript**：
- JavaScript 的超集，添加静态类型检查
- 编译后生成 JavaScript 代码
- 提供 IDE 智能补全和编译时错误检查

**核心概念**：
```typescript
// 基本类型
let name: string = "Alice";
let age: number = 25;

// Interface 定义对象结构
interface User {
  name: string;
  age: number;
  email?: string;  // 可选
}

// 函数类型
function greet(user: User): string {
  return `Hello ${user.name}`;
}
```

### Zod Schema

**什么是 Zod**：
- 运行时类型验证库
- 单一来源定义：既是类型又是验证器

**基本用法**：
```typescript
import { z } from 'zod';

// 定义 schema
const UserSchema = z.object({
  name: z.string().min(3),
  age: z.number().min(18),
  email: z.string().email().optional(),
});

// 运行时验证
const user = UserSchema.parse(data);

// 类型推导
type User = z.infer<typeof UserSchema>;
```

**在 Agent 中的应用**：
```typescript
const weatherTool = betaZodTool({
  name: 'get_weather',
  inputSchema: z.object({
    location: z.string().describe('城市名称'),
    unit: z.enum(['celsius', 'fahrenheit']).default('celsius'),
  }),
  run: (input) => {
    // input 类型自动推断
    return getWeather(input.location, input.unit);
  },
});
```

### 模型参数配置

| 参数 | 说明 | 建议值 |
|------|------|--------|
| `model` | 模型选择 | `claude-sonnet-4-5-20250929` |
| `max_tokens` | 输出 token 限制 | 1024-4096（根据任务复杂度） |
| `temperature` | 温度（0-1） | 0-0.3（稳定）/ 0.7-1（创造性） |

### 运行时环境

| 运行时 | 用途 | TypeScript 支持 |
|--------|------|----------------|
| **Node.js** | 服务器端 | 需要编译或 ts-node |
| **Deno** | 现代运行时 | 原生支持 TS |
| **Bun** | 高性能运行时 | 原生支持 TS |
| **浏览器** | 客户端 | 需要打包 |

---

## 常用命令/操作

### SDK 安装和初始化

| 命令/操作 | 用途 | 实践经验 |
|-----------|------|----------|
| `npm install @anthropic-ai/sdk` | 安装 TypeScript SDK | 需要Node.js 20+ |
| `npm install zod` | 安装 Zod 验证库 | 配合 SDK 使用 |
| `export ANTHROPIC_API_KEY=xxx` | 设置 API Key | 推荐使用环境变量 |

### 创建工具

```typescript
// 使用 Zod Schema（推荐）
import { betaZodTool } from '@anthropic-ai/sdk/helpers/beta/zod';

const tool = betaZodTool({
  name: 'tool_name',
  inputSchema: z.object({
    param: z.string(),
  }),
  description: '工具描述',
  run: async (input) => {
    // 工具逻辑
    return result;
  },
});
```

### 工具执行

```typescript
// 使用 toolRunner 自动处理循环
const result = await anthropic.beta.messages.toolRunner({
  model: 'claude-3-5-sonnet-20241022',
  max_tokens: 1024,
  messages: [{ role: 'user', content: '用户消息' }],
  tools: [tool1, tool2, tool3],
});
```

### 错误处理

```typescript
// API 错误
try {
  await client.messages.create({...});
} catch (error) {
  if (error instanceof Anthropic.APIError) {
    console.log(error.status);  // 400, 401, 429, 500
    console.log(error.name);    // 错误类型
  }
}

// 工具错误
import { ToolError } from '@anthropic-ai/sdk/lib/tools/BetaRunnableTool';

if (invalidInput) {
  throw new ToolError('详细的错误信息');
}
```

### 使用本地模型

```typescript
// 方案 1：LangChain
import { ChatOllama } from '@langchain/ollama';
const ollama = new ChatOllama({
  model: 'llama3.2',
  baseUrl: 'http://localhost:11434',
});

// 方案 2：OpenAI SDK + Ollama
import OpenAI from 'openai';
const client = new OpenAI({
  baseURL: 'http://localhost:11434/v1',
  apiKey: 'ollama',
});
```

---

## 学习心得与总结

### 关键收获

1. **Agent 的本质是循环**
   - 不是一次性的请求-响应，而是持续的自我驱动循环
   - 每轮评估"任务完成了吗？"，未完成则继续
   - 这让 Agent 能处理复杂的多步骤任务

2. **状态管理的艺术**
   - 内部状态 vs 上下文的分离很重要
   - 只有对话相关的内容进入 API 上下文
   - 控制逻辑保留在 Agent 内部，节省 Token

3. **工具描述的重要性**
   - Claude 依赖工具的 description 来理解何时使用
   - 就像给 AI 写"使用说明书"
   - 好的描述能让 Agent 更聪明地选择工具

4. **TypeScript 和 Zod 的价值**
   - TypeScript 提供编译时类型安全
   - Zod 提供运行时验证
   - 两者结合构成完整的类型安全系统

### Agent 设计原则

- **单一职责**：每个 Agent 专注一种任务
- **工具组合**：简单工具组合实现复杂功能
- **状态最小化**：只保存必要的状态
- **可观察性**：提供清晰的日志
- **优雅降级**：失败时提供备选方案

### 学习路径建议

1. 先用云端 API 理解概念（Claude 质量最高）
2. 再考虑本地模型（降低成本、保护隐私）
3. 使用 LangChain 等框架实现多模型切换

---

## 问题与解决方案

| 问题 | 解决方案 |
|------|----------|
| **内部状态和上下文的关系** | 内部状态 = Agent 的"大脑"（控制逻辑），上下文 = 和 AI 的"对话记录"。只有 messages 和 toolResults 会进入上下文，currentStep 和 completed 是内部变量 |
| **可以使用本地部署的大模型吗？** | Anthropic SDK 只支持 Claude API。要使用本地模型，可以用：1）LangChain/Vercel AI SDK（统一接口）2）OpenAI SDK + Ollama（兼容接口）3）直接 HTTP 请求 |
| **TypeScript 和 Zod 是什么？** | TypeScript 是 JavaScript 的类型安全超集（编译时检查），Zod 是运行时验证库。两者结合提供完整的类型安全。用于 Node.js、浏览器等运行时 |
| **工具调用的循环如何控制？** | 使用 `toolRunner` 自动处理。手动实现需要：1）发送请求 2）检查是否有 tool_use 3）执行工具 4）将结果加入 messages 5）重复直到完成 |
| **如何选择 Token 限制？** | 简单任务 512-1024，中等 1024-2048，复杂 2048-4096。Agent 应用建议 2048+，因为需要生成多步骤计划 |
