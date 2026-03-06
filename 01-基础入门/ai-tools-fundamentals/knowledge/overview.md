# Claude Code 概述

> 来源：Claude Code GitHub Repository + 官方资源

## 什么是 Claude Code？

Claude Code 是 Anthropic 官方的 **AI 编程助手 CLI 工具**，它：

- 🖥️ **运行在终端中** - 原生命令行界面
- 🧠 **理解你的代码库** - 自动分析和理解项目结构
- ⚡ **加速开发流程** - 通过自然语言命令执行各种任务
- 🔄 **处理 Git 工作流** - 自动化版本控制操作

## 核心特性

### 1. 自然语言交互
- 使用自然语言描述需求，无需记忆复杂命令
- 支持上下文对话，理解项目上下文

### 2. 智能代码操作
- 执行例程任务（格式化、重构、测试）
- 解释复杂代码逻辑
- 处理 Git 工作流（提交、分支、合并）

### 3. 多平台支持
- 在终端中使用
- 在 IDE 中集成
- 在 GitHub 上通过 @claude 标签使用

## 安装方式

### macOS/Linux（推荐）
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Windows（推荐）
```powershell
irm https://claude.ai/install.ps1 | iex
```

### Homebrew（macOS/Linux）
```bash
brew install --cask claude-code
```

### WinGet（Windows）
```powershell
winget install Anthropic.ClaudeCode
```

## 开始使用

1. 安装 Claude Code
2. 导航到项目目录
3. 运行 `claude` 命令启动

## 设计理念

Claude Code 的核心设计理念是 **让 AI 成为你的编程助手**，而非替代你：

- 🤝 **协作式** - AI 与你协同工作，不是全自动
- 🎯 **可控性** - 你保留最终决策权
- 🔒 **安全性** - 权限系统保护你的代码和数据

## 数据隐私

### 收集的数据
- 使用数据（代码接受/拒绝）
- 关联的对话数据
- 通过 `/bug` 命令提交的反馈

### 隐私保护措施
- 敏感信息的有限保留期
- 对用户会话数据的受限访问
- 不使用反馈进行模型训练的明确政策

> 💡 **提示**：查看完整隐私政策和使用条款了解详情。
