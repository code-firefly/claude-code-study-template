# MCP 使用指南

> **来源**：MCP SDK 文档和最佳实践
> **更新日期**：2026-03-07

---

## 快速开始

### 创建 MCP Server (TypeScript)

**1. 安装依赖**：
```bash
npm install @modelcontextprotocol/server zod
```

**2. 创建简单服务器**：
```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

// 创建服务器实例
const server = new Server({
  name: 'my-server',
  version: '1.0.0'
});

// 注册工具
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'hello',
      description: '打招呼',
      inputSchema: {
        type: 'object',
        properties: {
          name: { type: 'string' }
        },
        required: ['name']
      }
    }
  ]
}));

// 处理工具调用
server.setRequestHandler('tools/call', async (request) => {
  if (request.params.name === 'hello') {
    return {
      content: [{
        type: 'text',
        text: `你好，${request.params.arguments.name}！`
      }]
    };
  }
});

// 启动服务器
const transport = new StdioServerTransport();
await server.connect(transport);
```

### 配置 Claude Desktop

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

---

## 最佳实践

### 1. 工具设计原则

| 原则 | 说明 | 示例 |
|------|------|------|
| **单一职责** | 每个工具只做一件事 | `read_file` 而非 `file_operations` |
| **清晰命名** | 使用动词+名词 | `create_user` 而非 `user` |
| **详细描述** | 说明功能和用途 | "创建新用户，需要邮箱和用户名" |
| **明确 Schema** | 定义清晰的输入输出 | 使用 JSON Schema |

**好的工具定义**：
```json
{
  "name": "search_database",
  "description": "在数据库中搜索用户记录",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "搜索关键词（用户名或邮箱）"
      },
      "limit": {
        "type": "number",
        "description": "返回结果数量上限",
        "default": 10
      }
    },
    "required": ["query"]
  }
}
```

### 2. 资源组织策略

| 策略 | 说明 | URI 示例 |
|------|------|----------|
| **按类型** | 资源类型在前 | `resource://file/config` |
| **按层级** | 反映数据层级 | `resource://db/users/123` |
| **按环境** | 区分环境 | `resource://prod/api/status` |

**资源注册示例**：
```typescript
server.setRequestHandler('resources/list', async () => ({
  resources: [
    {
      uri: 'config://app/settings',
      name: '应用设置',
      description: '当前应用的配置',
      mimeType: 'application/json'
    },
    {
      uri: 'log://app/current',
      name: '应用日志',
      description: '实时应用日志',
      mimeType: 'text/plain'
    }
  ]
}));
```

### 3. 错误处理

**最佳实践**：
- 返回有意义的错误信息
- 使用适当的 HTTP 状态码
- 提供解决建议

**示例**：
```typescript
server.setRequestHandler('tools/call', async (request) => {
  try {
    const result = await executeTool(request);
    return { content: result };
  } catch (error) {
    return {
      content: [{
        type: 'text',
        text: `错误: ${error.message}\n建议: 检查输入参数和权限`
      }],
      isError: true
    };
  }
});
```

### 4. 安全考虑

| 风险 | 防护措施 |
|------|----------|
| **路径遍历** | 验证和规范化路径 |
| **命令注入** | 使用参数化查询 |
| **敏感数据** | 加密传输和存储 |
| **权限提升** | 实施最小权限原则 |

**安全示例**：
```typescript
import path from 'path';

function safeFilePath(userPath: string): string {
  // 规范化路径
  const normalized = path.normalize(userPath);
  // 确保在允许的目录内
  const allowedDir = '/app/data';
  const fullPath = path.resolve(allowedDir, normalized);
  if (!fullPath.startsWith(allowedDir)) {
    throw new Error('路径超出允许范围');
  }
  return fullPath;
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
    _meta: {
      page,
      limit,
      hasMore: results.length === limit
    }
  };
});
```

### 2. 流式响应
```typescript
server.setRequestHandler('tools/call', async (request) => {
  const stream = getDataStream();
  return {
    content: [{
      type: 'text',
      text: stream
    }],
    _meta: {
      stream: true
    }
  };
});
```

### 3. 缓存资源
```typescript
const cache = new Map();

server.setRequestHandler('resources/read', async (request) => {
  const { uri } = request.params;
  if (cache.has(uri)) {
    return { contents: [cache.get(uri)] };
  }
  const data = await fetchResource(uri);
  cache.set(uri, data);
  return { contents: [data] };
});
```

---

## 调试技巧

### 1. 日志记录
```typescript
// 开发环境启用详细日志
if (process.env.NODE_ENV === 'development') {
  server.on('request', (request) => {
    console.log('[MCP Request]', request.method, request.params);
  });
  server.on('response', (response) => {
    console.log('[MCP Response]', response);
  });
}
```

### 2. 验证工具
```typescript
import { z } from 'zod';

const inputSchema = z.object({
  path: z.string().min(1),
  line: z.number().optional().default(1)
});

// 在工具调用前验证
const validated = inputSchema.parse(request.params.arguments);
```

### 3. 测试工具
```typescript
// 使用 MCP Inspector 测试
// npx @modelcontextprotocol/inspect

// 或编写单元测试
describe('MCP Server', () => {
  it('should list tools', async () => {
    const result = await server.request('tools/list', {});
    expect(result.tools).toHaveLength(3);
  });
});
```

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

## 常见问题

### Q: 如何处理大文件？
A: 使用流式传输或分块读取

### Q: 如何实现认证？
A: 在 HTTP 传输层添加认证头

### Q: 如何版本管理 API？
A: 在工具名称中包含版本或使用 Server 版本

### Q: 如何监控性能？
A: 记录请求耗时和错误率
