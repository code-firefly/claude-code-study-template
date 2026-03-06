# 知识缓存系统

> 本地持久化知识记忆，减少重复的文档获取。

---

## 🚀 优化说明

知识缓存系统使用以下参数拉取网页内容，确保快速加载：

| 参数 | 值 | 说明 |
|------|-----|------|
| `retain_images` | `false` | 跳过图片下载 |
| `keep_img_data_url` | `false` | 不保留图片数据 URL |
| `with_images_summary` | `false` | 不生成图片摘要 |
| `timeout` | `20` | 20秒超时，适合大型文档 |

**预期效果**：加载速度提升 50-70%

---

## 使用命令

| 操作 | 命令 |
|------|------|
| 初始化缓存 | `初始化知识缓存 <模块名>` |
| 刷新缓存 | `刷新知识缓存` 或 `刷新知识缓存 <模块名>` |
| 查看缓存状态 | `查看知识缓存` |

---

## 缓存状态表

| 模块 | 状态 | 缓存日期 | 资料来源 |
|------|------|----------|----------|
| ai-tools-fundamentals | ✅ 已缓存 | 2026-03-06 | anthropics/claude-code |
| mcp-protocol | 未缓存 | - | anthropic-ai/sdk-python |
| agent-configuration | 未缓存 | - | anthropic-ai/sdk-python |
| mcp-advanced-config | 未缓存 | - | anthropic-ai/sdk-python |
| ai-orchestration | 未缓存 | - | OpenClaw/openclaw |
| ai-resources-research | 未缓存 | - | - |
| config-management | 未缓存 | - | - |
| spec-driven-dev | 未缓存 | - | anthropics/spec-kit |
| practical-projects | 未缓存 | - | - |

---

## 更新历史

| 日期 | 模块 | 操作 | 备注 |
|------|------|------|------|
| 2026-03-06 | - | 初始化 | 从模板创建个人缓存追踪文件 |
| 2026-03-06 | ai-tools-fundamentals | 初始化缓存 | 创建基础知识缓存结构 |

---

## 缓存目录结构

```
XX-阶段名称/模块名/
└── knowledge/              # 知识缓存目录
    ├── README.md           # 缓存说明
    ├── overview.md         # 概述内容
    ├── concepts.md         # 核心概念
    ├── guides.md           # 使用指南
    └── .metadata.json      # 缓存元数据
```

---

## 元数据格式

```json
{
  "moduleName": "claude-code-core",
  "cacheDate": "YYYY-MM-DD",
  "sources": [
    {"type": "github", "url": "anthropics/claude-code", "path": "README.md"},
    {"type": "docs", "url": "code.claude.com/docs/en/overview"}
  ],
  "version": "main-abc123",
  "status": "cached"
}
```

---

**创建日期**：2026-03-06
