# 01-基础入门

> **预计时长**：2-3 周（完整模式）
> **难度等级**：⭐ 入门
> **更新日期**：2026-02-26

---

## 阶段概述

本阶段聚焦 Claude Code 生态的核心基础知识，为后续深入学习打下坚实基础。通过本阶段学习，你将掌握 Claude Code 的核心使用方法和 MCP 协议的基础概念。

## 学习模块

| 模块 | 优先级 | 学习模式 | 状态 |
|------|--------|----------|------|
| [claude-code-core](./claude-code-core/) | P0 🔴 必学 | - | 未开始 |
| [mcp-basics](./mcp-basics/) | P1 🟡 推荐 | - | 未开始 |

---

## 前置知识

开始本阶段学习前，建议你具备：

- [ ] 基本的命令行操作能力（cd, ls, git 等）
- [ ] Git 基础知识（clone, commit, push, pull）
- [ ] 文本编辑器的基本使用（VS Code、Neovim 等）
- [ ] 了解基本的开发工作流

## 时间规划

### 快速模式（仅理论）
- claude-code-core：约 3 天
- mcp-basics：约 2 天
- **合计**：约 5 天

### 完整模式（理论+实践）
- claude-code-core：约 1 周
- mcp-basics：约 1 周
- **合计**：约 2-3 周

---

## 学习目标

完成本阶段后，你将能够：

### claude-code-core [P0]
- [ ] 理解 Claude Code 的核心架构和工作原理
- [ ] 熟练使用至少 10 个核心命令
- [ ] 掌握权限系统和安全最佳实践
- [ ] 完成基础配置和环境搭建

### mcp-basics [P1]
- [ ] 理解 MCP 协议的基本概念和工作原理
- [ ] 成功配置至少 2 个 MCP 服务器
- [ ] 能够使用 MCP 工具完成简单任务
- [ ] 了解常见 MCP 服务器的类型和用途

---

## 学习资源

### 什么是 MCP？

> **MCP (Model Context Protocol)** 是一个开放协议，让 Claude 能够与外部工具和数据源交互。
>
> **简单理解**：
> - **没有 MCP**：Claude 只能处理你输入的文字
> - **有 MCP**：Claude 可以读取文件、搜索数据库、执行命令...
>
> **示例**：配置一个 MCP 文件系统服务器，Claude 就能直接读取你的代码文件。

### 官方文档
- [Claude Code 官方文档](https://github.com/anthropics/claude-code)
- [Claude Code 官方指南](https://claude.ai/claude-code)
- [MCP 官方文档](https://modelcontextprotocol.io/)
- [MCP GitHub](https://github.com/modelcontextprotocol)

### 推荐阅读顺序
1. 先完成 claude-code-core，建立 Claude Code 基础认知
2. 再学习 mcp-basics，理解扩展协议
3. 回顾整体架构，形成知识体系

---

## 进度更新

本阶段的总体进度会自动反映在根目录的 `PROGRESS.md` 文件中。各模块的详细进度请查看对应模块的 `checklist.md`。

---

## 常见问题

### Q: 必须按顺序学习吗？
**A**: 建议按顺序学习，因为 mcp-basics 需要 claude-code-core 作为基础。

### Q: 快速模式够用吗？
**A**: 如果你的目标是快速了解 Claude Code 生态，快速模式足够。但若要深入应用，建议选择完整模式。

### Q: 遇到问题怎么办？
**A**: 可以查阅各模块目录下的 `notes.md` 学习笔记，或访问官方文档获取帮助。
