# 飞书学习助手 (Feishu Learning Assistant)

> **项目类型**：AI 能力集成
> **难度等级**：⭐⭐⭐⭐ 高级
> **预计时长**：1-2 周
> **前置要求**：完成 openclaw-ecosystem 模块
> **创建日期**：2026-03-03

---

## 项目概述

通过飞书机器人，使用自然语言控制 Claude Code 执行学习任务，实现自动化学习助手。本项目展示了 OpenClaw + Claude Code + 飞书的完整集成方案。

### 核心价值

- **学习场景自动化**：通过飞书直接操作学习进度，无需切换环境
- **三层架构演示**：展示飞书 → OpenClaw → Claude Code 的完整调用链
- **混合环境实践**：WSL + Windows 混合环境的实际应用案例
- **可扩展模板**：可作为其他 AI 工具集成的参考模板

---

## 架构设计

```
┌────────┐      ┌──────────┐      ┌─────────────┐      ┌──────────┐
│  飞书   │ ───> │ OpenClaw │ ───> │ Claude Code │ ───> │ 学习项目  │
│ (用户)  │      │ (协调器)  │      │  (执行器)   │      │          │
└────────┘      └──────────┘      └─────────────┘      └──────────┘
                      │
                      ▼
               返回学习结果
```

### 组件说明

| 组件 | 职责 | 环境 |
|------|------|------|
| 飞书 | 用户交互入口，接收自然语言指令 | 云端 |
| OpenClaw | 指令解析与调度，调用 Claude Code | WSL 2 |
| Claude Code CLI | 执行学习命令，操作项目文件 | Windows |
| 学习项目 | 实际被操作的学习计划目录 | Windows |

---

## 功能特性

### 核心功能

- ✅ **学习命令调度**
  - 开始学习模块
  - 更新学习进度
  - 查看学习状态
  - 创建/继续/完成书签

- ✅ **跨环境调用**
  - WSL 自动调用 Windows CLI
  - 路径自动转换（Windows ↔ WSL）
  - 结果格式化返回

- ✅ **飞书指令支持**
  - 自然语言指令解析
  - 指令映射到 Claude Code 命令
  - 执行结果美化展示

### 指令映射

| 飞书指令 | 功能 | Claude Code 命令 |
|----------|------|------------------|
| 开始学习 `<模块>` | 启动模块学习 | 开始学习 `<模块>` |
| 查看进度 | 显示学习状态 | 查看学习状态 |
| 更新 `<模块>` | 同步模块进度 | 更新进度 `<模块>` |
| 创建书签 `<名称>` | 记录学习疑问 | 创建书签 `<名称>` |
| 继续书签 | 继续探索书签 | 继续书签 |
| 完成书签 | 完成当前书签 | 完成书签 |

---

## 快速开始

### 前置条件

- ✅ 已完成 `openclaw-ecosystem` 模块
- ✅ WSL 2 环境已安装 OpenClaw
- ✅ Windows 环境已安装 Claude Code CLI
- ✅ 飞书机器人已配置并连接到 OpenClaw

### 配置步骤

1. **配置 Claude Code 桥接脚本**（详见 `setup-guide.md`）
2. **安装 OpenClaw Skills**
3. **配置飞书机器人指令**
4. **测试端到端流程**

---

## 项目结构

```
feishu-learning-assistant/
├── README.md                      # 本文件 - 项目说明
├── architecture.md                # 架构设计文档
├── setup-guide.md                 # 详细配置指南
├── openclaw-skills/               # OpenClaw Skills 配置
│   ├── README.md                  # Skills 说明
│   ├── claude-code-skill/         # Claude Code 调用 Skill
│   │   ├── skill.json             # Skill 配置
│   │   ├── index.js               # Skill 实现
│   │   └── README.md
│   └── learning-manager/          # 学习管理 Skill
│       ├── skill.json
│       ├── index.js
│       └── README.md
└── examples/                      # 使用示例
    └── scenarios.md               # 典型场景演示
```

---

## 验证方式

完成配置后，通过飞书发送：

```
查看学习状态
```

应返回：

```
╔═══════════════════════════════════════════════════════╗
║              Claude Code 学习进度总览                ║
╠═══════════════════════════════════════════════════════╣
║ 总体进度: 100% ████████████████████████████████████  ║
║ ...
╚═══════════════════════════════════════════════════════╝
```

---

## 与现有模块的关系

| 模块 | 关系 | 说明 |
|------|------|------|
| claude-code-core | 前置 | 理解 Claude Code 命令体系 |
| mcp-basics | 相关 | 理解协议通信机制 |
| openclaw-ecosystem | 前置 | 已配置飞书通道 |
| projects | 容器 | 本项目作为可选实战案例 |

---

## 技术要点

### 1. WSL 调用 Windows CLI

```bash
# 在 WSL 中调用 Windows 的 Claude Code
/mnt/c/Users/<user>/AppData/Local/anthropic/claude-code/claude-code.exe "命令"
```

### 2. 路径转换

```
Windows: E:\VebingCode\claude-code-study
WSL:      /mnt/e/VebingCode/claude-code-study
```

### 3. 指令解析与映射

OpenClaw Skills 负责将飞书的自然语言指令解析为对应的 Claude Code 命令。

---

## 后续扩展

- [ ] 支持更多学习命令
- [ ] 添加学习提醒功能
- [ ] 集成学习数据分析
- [ ] 支持语音指令

---

## 许可

本项目作为学习计划的一部分，仅供个人学习使用。
