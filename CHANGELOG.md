# 变更日志

本文件记录 AI 技术学习模板的所有重要变更。

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

### 变更 (Changed)
- 🔄 **架构重构**：将学习系统从 Command Skills 重构为 Prompt Skills
  - 删除 study Command Skill（TypeScript，环境不兼容）
  - 新增 5 个 Prompt Skills（learning-*），支持真正的自然语言触发
  - 所有功能保持不变，用户交互更加自然直观
  - 非阻塞更新提醒已迁移到 learning-manager 和 learning-progress

### 删除 (Removed)
- 🗑️ `.claude/skills/study/` - 移除 TypeScript Command Skill（环境不兼容）
- 🗑️ `SYNC_TEST.md` - 删除过时的测试文档（命令式语法）
- 🗑️ `IMPLEMENTATION_STATUS.md` - 删除已废弃的实施状态文档

### 新增 (Added)
- ✨ **Prompt Skills**：5 个自然语言触发的学习管理技能
  - `learning-progress` - 查看学习状态、更新进度
  - `learning-manager` - 开始学习、完成学习、重置模块
  - `learning-bookmark` - 创建书签、继续探索、完成书签
  - `learning-cache` - 初始化缓存、刷新缓存、查看缓存
  - `learning-sync` - 检查更新、同步学习计划、模块管理

### 文档 (Docs)
- 📝 learning-sync/SKILL.md：移除 `/study` 命令引用
- 📝 learning-manager/SKILL.md：添加非阻塞更新提醒
- 📝 learning-progress/SKILL.md：添加非阻塞更新提醒

### 计划中
- 添加更多学习模块模板
- 改进进度可视化
- 支持自定义学习路径

---

## [2.0.1] - 2026-03-05

（兼容性更新）

### 向后兼容性 (Backward Compatibility)
- ✨ **模块名称别名映射**：支持旧模块名称继续使用
  - 在 CLAUDE.md 中添加了别名映射表
  - AI 行为时显示提示："注意：'{旧名称}' 已更名为 '{新名称}'，正在使用新名称继续..."
  - 旧名称完全兼容，无需强制迁移

### Clone 模式支持
- ✨ **两种使用模式**：
  - **Fork 模式**：公开仓库，通过 upstream 自动更新
  - **Clone 模式**：私有仓库，通过 `scripts/update-standalone.sh` 更新
- 📝 **TEMPLATE_GUIDE.md 更新**：添加模式选择指南

### 新增 (Added)
- 🛠️ **新增脚本**：
  - `scripts/migrate-v2.sh`：v1.x → v2.0 迁移脚本
  - `scripts/update-standalone.sh`：Clone 模式独立更新脚本
- 🔧 **update-checker.ts 改进**：
  - 新增 `isCloneMode()` 函数
  - 新增 `getRemoteVersionForCloneMode()` 函数
  - 支持 Clone 模式版本检测

### 文档 (Documentation)
- 📖 **CLAUDE.md 更新**：
  - 添加模块名称别名映射章节
- 📖 **TEMPLATE_GUIDE.md 更新**：
  - 添加两种使用模式说明
  - 添加 Clone 模式更新步骤
- 📖 **Windows 环境支持说明**：
  - README.md: 添加系统要求章节
  - TEMPLATE_GUIDE.md: 添加环境要求提示
  - MIGRATION.md: 添加环境要求提示

---

## [2.0.0] - 2026-03-05

### 重大变更 (Breaking Changes)
- 🔄 **项目重新定位**：从"Claude Code 学习计划"→"AI 技术学习模板"
  - 现在是一个可复用的学习框架，支持 Fork 后自定义学习内容
  - 内置 AI 工具基础课程作为示例

### 新增 (Added)
- ✨ **模块重命名**：所有模块使用通用名称，适合任何技术学习
  - `claude-code-core` → `ai-tools-fundamentals`
  - `mcp-basics` → `mcp-protocol`
  - `agent-sdk` → `agent-configuration`
  - `mcp-advanced` → `mcp-advanced-config`
  - `openclaw-ecosystem` → `ai-orchestration`
  - `everything-claude-code` → `ai-resources-research`
  - `cc-switch` → `config-management`
  - `spec-kit` → `spec-driven-dev`
  - `projects` → `practical-projects`
- 🛠️ **新增脚本**：`scripts/create-module.sh` 快速创建新模块
- 📝 **新增模板**：`.templates/module/README.template.md` 模块 README 模板

### 向后兼容性 (新增)
- ✨ **模块名称别名映射**：支持旧模块名称（如 `claude-code-core`）继续使用
  - 在 CLAUDE.md 中添加了别名映射表
  - AI 行为时显示提示："注意：'{旧名称}' 已更名为 '{新名称}'，正在使用新名称继续..."
- 📜 **迁移脚本**：新增 `scripts/migrate-v2.sh` 帮 v1.x 用户平滑迁移
  - 迁移 PROGRESS.md、 checklist.md、 notes.md 等文件
  - 显示迁移提示，建议运行迁移脚本
- 🔧 **Clone 模式支持**：
  - 新增 `scripts/update-standalone.sh` 脚本
  - 支持 Clone 模式（私有仓库）用户更新模板
  - 通过 HTTPS 获取最新版本，  智能合并更新（保留个人数据）
- 🔄 **update-checker.ts 改进**：支持 Clone 模式检测
  - 新增 `isCloneMode()` 函数
  - 新增 `getRemoteVersionForCloneMode()` 函数
  - 修改 `checkForUpdates()` 支持 Clone 模式
  - 修改 `formatUpdateReminder()` 和 `formatSyncCheckResult()` 支持 Clone 模式提示

- 📖 **TEMPLATE_GUIDE.md 更新**：添加两种使用模式说明和 Clone 模式更新步骤

### 文档 (Documentation)
- 📖 **README.md 重写**：更新为模板使用说明
- 📖 **CLAUDE.md 更新**：更新项目概述和模块映射
- 📖 **TEAM_GUIDE.md → TEMPLATE_GUIDE.md**：重命名并更新为模板使用指南

### 变更 (Changed)
- 🔄 阶段 README.md 更新:反映新的模块名称
- 🔄 模块 README.md 更新:更新标题和前置要求
- 🔄 `scripts/init.sh` 更新:更新模块列表

---

## [1.3.3] - 2026-03-04

### 测试 (Test)
- 🧪 版本更新检测功能验证版本
  - 用于验证 1.3.2 的自动 fetch upstream 修复
  - 团队成员运行 `/study update` 应能收到此版本的更新提醒

---

## [1.3.2] - 2026-03-04

### 修复 (Fixed)
- 🐛 修复版本检测机制
  - 修复 `getUpstreamVersion()` 未自动 fetch upstream 的问题
  - 添加 5 秒超时保护，避免网络问题导致阻塞
  - 现在团队成员会自动收到更新提醒

### 改进 (Improved)
- 📈 更新检测现在会在每次检查时自动获取上游最新版本信息

---

## [1.3.1] - 2026-03-04

### 测试 (Test)
- 🧪 测试同步功能验证
  - 版本号更新测试
  - 团队同步流程验证

---

## [1.3.0] - 2026-03-03

### 新增 (Added)
- 🔄 **学习计划同步功能** (版本 1.3.0)
  - 新增 `/study sync` 命令：检查上游更新
  - 新增 `/study sync auto` 命令：执行同步
  - 新增非阻塞更新提醒机制
  - 新增版本比较功能（基于 CHANGELOG.md）
  - 新增 upstream 配置检查

### 新增文件
- `.claude/skills/study/commands/sync.ts` - 同步命令处理器
- `.claude/skills/study/lib/update-checker.ts` - 更新检查器

### 文档 (Documentation)
- 更新 CLAUDE.md 添加同步管理命令说明

---

## [1.2.0] - 2026-03-01

### 新增 (Added)
- 📚 **理论知识展示行为规范**
  - 分块展示机制（超过 15 行自动分块）
  - 用户确认机制（每块后询问是否继续）
  - 来源标注规范（官方文档、GitHub README 等）
  - 独立于 `accept edits on` 设置

### 新增内容
- `03-实战应用/projects/feishu-learning-assistant/` - 飞书学习助手实战项目
  - 完整的项目架构文档
  - OpenClaw Skills 示例代码
  - 设置指南和场景示例
- `02-进阶探索/openclaw-ecosystem/exercises/day1-deployment/web-ui-guide.md` - Web UI 练习

### 改进 (Changed)
- 更新 .gitignore 添加 personal-notes

### 文档 (Documentation)
- 更新 CLAUDE.md 添加理论知识展示行为规范

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
| 2.0.1 | 2026-03-05 | 兼容性更新：模块别名映射、Clone 模式支持、Windows 环境说明 |
| 2.0.0 | 2026-03-05 | 项目重新定位为"AI 技术学习模板" |
| 1.3.3 | 2026-03-04 | 测试版本：同步功能验证 |
| 1.3.0 | 2026-03-03 | 学习计划同步功能：版本检查和自动同步 |
| 1.2.0 | 2026-03-01 | 理论知识展示规范 + 飞书学习助手项目 |
| 1.1.2 | 2026-02-28 | 书签系统改进：添加探索行为规范和状态提示 |
| 1.1.0 | 2026-02-28 | 课程定位调整：聚焦「配置使用 AI 能力」 |
| 1.0.0 | 2026-02-27 | 团队协作系统初始化 |

---

**创建日期**：2026-02-27
**当前版本**：2.0.1
