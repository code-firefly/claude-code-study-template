# 变更日志

本文件记录 Claude Code 学习计划的所有重要变更。

格式遵循 [语义化版本](https://semver.org/lang/zh-CN/) 规范。

---

## 版本说明

| 版本类型 | 说明 | 示例 |
|----------|------|------|
| **MAJOR** | 重大变更，可能破坏向后兼容性 | 1.0.0 → 2.0.0 |
| **MINOR** | 新增功能，向后兼容 | 1.0.0 → 1.1.0 |
| **PATCH** | Bug 修复，向后兼容 | 1.0.0 → 1.0.1 |

---

## [Unreleased]

### 计划中
- 添加更多实战项目模块
- 改进进度可视化

---

## [1.1.2] - 2026-02-28

### 新增 (Added)
- 🔖 **书签系统改进**：添加"书签探索行为规范"章节
  - 每次查询后主动询问"还有其他疑问吗？"
  - 添加探索笔记记录功能（用户触发）
  - 添加状态切换视觉提示（🔵 探索模式、✅ 返回主线）
- 📝 **探索笔记机制**：用户可主动要求将探索结果记录到书签笔记

### 改进 (Changed)
- 🎯 **书签探索流程**：从自动返回改为用户确认返回，避免过早结束探索
- 📍 **状态提示增强**：明确标识探索模式和主线返回，避免上下文污染

### 文档 (Documentation)
- 更新 CLAUDE.md 添加书签探索行为规范
- 更新 README.md 书签系统使用说明

---

## [1.1.0] - 2026-02-28

### 新增 (Added)
- 📦 新增 `openclaw-ecosystem` 模块 [P1] - OpenClaw AI 编排平台

### 变更 (Changed)
- 🎯 **课程定位调整**：从「开发导向」转向「配置使用 AI 能力导向」
- 🔄 **优先级重组**：
  - `agent-sdk`：P1 🟡 → P2 🟢（开发侧→配置侧）
  - `mcp-advanced`：P2 🟢 → P3 🔵（开发侧→了解级）
  - `everything-claude-code`：P3 🔵 → P1 🟡（提升优先级）
- 📝 **模块内容重写**：
  - `agent-sdk`：从「Agent SDK 开发」→「Agent 配置与使用」
  - `mcp-advanced`：从「MCP 高级应用」→「MCP 高级配置与资源管理」
  - `projects`：调整为「AI 能力集成项目」导向
  - `mcp-basics`：强化配置至少 2 个 MCP 服务器
  - `openclaw-ecosystem`：强化 AI 编排与协作定位
  - `everything-claude-code`：强化工具评估与选择
  - `claude-code-core`：强调 CLAUDE.md 配置核心技能
- 📖 **阶段 README 更新**：强调「配置使用 AI 能力」目标
- 🗺️ **推荐学习路径更新**：反映新的优先级分布

---

## [1.0.0] - 2026-02-27

### 新增 (Added)
- 🎉 初始化团队协作系统
- 📚 完整的学习工作流程（快速/完整模式）
- 🔖 学习书签系统（疑问分支追踪）
- 💾 知识缓存系统（本地持久化）
- 📋 8 个学习模块结构
  - 01-基础入门：claude-code-core, mcp-basics
  - 02-进阶探索：agent-sdk, mcp-advanced, everything-claude-code
  - 03-实战应用：cc-switch, spec-kit, projects
- 🔧 自动化脚本系统（init.sh, sync.sh, migrate.sh, backup.sh）
- 📖 团队协作指南（TEAM_GUIDE.md）
- ✅ .gitignore 个人数据保护
- 📝 .gitattributes 统一行尾符配置

### 修复 (Fixed)
- 🐛 修复 backup.sh 在 Windows 环境下的兼容性问题
- 🛡️ 清理 settings.local.json 的 Git 追踪状态

### 变更 (Changed)
- 重构 PROGRESS.md 结构，支持优先级分类
- 改进 checklist.md 模板，支持双学习模式

### 文档 (Documentation)
- 添加 README.md 完整使用说明
- 添加 TEAM_GUIDE.md 团队协作指南
- 添加 CHANGELOG.md 变更日志
- 添加 MIGRATION.md 迁移指南

---

## 变更类型说明

### 🎉 新增 (Added)
- 新功能
- 新模块
- 新命令

### 🔄 变更 (Changed)
- 现有功能的变更
- 配置格式变更

### 🐛 修复 (Fixed)
- Bug 修复
- 错误处理改进

### 🗑️ 废弃 (Deprecated)
- 即将移除的功能

### ❌ 删除 (Removed)
- 已移除的功能

### 🔒 安全 (Security)
- 安全相关的修复或改进

---

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|----------|
| 1.1.2 | 2026-02-28 | 书签系统改进：添加探索行为规范和状态提示 |
| 1.1.0 | 2026-02-28 | 课程定位调整：聚焦「配置使用 AI 能力」 |
| 1.0.0 | 2026-02-27 | 团队协作系统初始化 |

---

**创建日期**：2026-02-27
**当前版本**：1.1.2
