# 模板使用指南

> 本指南面向使用 AI 技术学习模板的用户，说明如何使用模板进行个性化学习。

---

## 📦 两种使用模式

本模板支持两种使用模式，你可以根据自己的需求选择：

### 模式 A：Fork 模式（推荐）

| 特性 | 说明 |
|------|------|
| **适合人群** | 想贡献改进、公开学习记录的用户 |
| **优点** | 自动获取模板更新、可贡献代码、操作简单 |
| **缺点** | 仓库必须公开（GitHub 免费版限制） |
| **更新方式** | `git fetch upstream` + `git merge` |

### 模式 B：Clone 模式（私有）

| 特性 | 说明 |
|------|------|
| **适合人群** | 私有学习、不想公开学习记录的用户 |
| **优点** | 完全私有、无需 GitHub 账号也可使用 |
| **缺点** | 更新需手动操作（运行脚本） |
| **更新方式** | `bash scripts/update-standalone.sh` |

---

## 🚀 快速开始

> **⚠️ 环境要求**：本项目仅支持 Windows 环境。所有脚本需要通过 Git Bash 或 WSL 运行。

### Fork 模式（推荐）

#### 步骤 1：Fork 模板仓库

1. 访问模板仓库：`https://github.com/GreadXu/claude-code-study`
2. 点击右上角 **Fork** 按钮
3. Fork 将创建你自己的副本仓库

#### 步骤 2：克隆你的仓库

```bash
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
git clone https://github.com/YOUR_USERNAME/claude-code-study.git
cd claude-code-study
```

### Clone 模式（私有）

#### 步骤 1：直接克隆模板仓库

```bash
# 克隆模板仓库到本地
git clone https://github.com/GreadXu/claude-code-study.git my-learning
cd my-learning

# 移除原始 origin（可选，避免误推送）
git remote remove origin
```

#### 步骤 3：初始化个人数据

```bash
# 运行初始化脚本
bash scripts/init.sh
```

> **Clone 模式用户**：初始化时当被问及 upstream 配置时，可以跳过（选择 n）。

#### 步骤 4（仅 Clone 模式）：配置更新脚本

Clone 模式用户需要使用 `update-standalone.sh` 脚本获取更新：

```bash
# 检查更新（不执行更新）
bash scripts/update-standalone.sh --check

# 执行更新
bash scripts/update-standalone.sh
```

该脚本将：
- 从模板创建你的个人数据文件（PROGRESS.md、checklist.md、notes.md 等）
- 配置 upstream 远程仓库
- 验证 .gitignore 配置
- 显示下一步指导

```bash
# 验证 upstream 配置（可选）
git remote -v | grep upstream
```

---

## 🌐 理解远程仓库：origin vs upstream

### 什么是远程仓库？

在 Git 中，**远程仓库（remote）** 是托管在互联网或其他网络上的 Git 仓库。你可以有多个远程仓库，每个都有一个名称（别名）。

### Fork 工作流中的两个远程仓库

当你 Fork 一个仓库后，会存在**两个仓库**：

```
┌─────────────────────────────────────────────────────────────┐
│                      模板仓库 (upstream)                     │
│         https://github.com/GreadXu/claude-code-study        │
│                    （官方模板源）                            │
│                    ↓ 你 Fork 了它                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  你的仓库 (origin)                          │
│       https://github.com/YOUR_USERNAME/claude-code-study    │
│                    （你拥有控制权）                          │
└─────────────────────────────────────────────────────────────┘
```

### origin 与 upstream 的区别

| 特性 | **origin** | **upstream** |
|------|-----------|--------------|
| **是什么** | 你 Fork 后的**个人仓库** | 原始的**模板仓库** |
| **所有权** | 你（完全控制） | 模板维护者 |
| **用途** | 你向这里推送代码 | 从这里获取模板更新 |
| **可写入** | ✅ 是 | ❌ 否（只能 PR） |
| **自动配置** | ✅ clone 时自动添加 | ❌ 需要手动添加 |

### Git 命令对照

```bash
# 查看所有远程仓库
git remote -v

# 输出示例：
# origin    https://github.com/YOUR_USERNAME/claude-code-study.git (fetch)
# origin    https://github.com/YOUR_USERNAME/claude-code-study.git (push)
# upstream  https://github.com/GreadXu/claude-code-study.git (fetch)
# upstream  https://github.com/GreadXu/claude-code-study.git (push)

# 从 origin 获取（你自己的仓库）
git fetch origin

# 从 upstream 获取（模板仓库的更新）
git fetch upstream

# 推送到 origin（你自己的仓库）
git push origin main

# 不能直接推送到 upstream（无权限）
# git push upstream main  ❌ 会报错
```

### 数据流向

```
                    获取更新
upstream ─────────────────────> 你的本地
  ▲                              │
  │                              │ 推送
  │                              │
  │                              ▼
  └────────── Pull Request ──── origin
     (贡献改进给模板仓库)
```

### 记忆技巧

> **origin** = **出发点** = 你自己的仓库，你的地盘你做主
>
> **upstream** = **上游源头** = 河流的源头，模板仓库的更新来源

---

## 🔄 同步模板更新

### 为什么需要同步？

模板仓库会定期更新：
- 🎉 新增学习模块
- 🐛 修复模板错误
- ✨ 改进学习流程
- 📚 更新文档内容

### Fork 模式同步步骤

```bash
# 运行同步脚本（推荐）
bash scripts/sync.sh
```

该脚本将：
- 自动备份你的个人数据
- 获取模板更新
- 显示变更日志
- 智能合并（保留个人数据）
- 检测冲突并提供处理提示

### 手动同步（高级 - Fork 模式）

```bash
# 1. 获取模板更新（upstream = 模板仓库）
git fetch upstream

# 2. 切换到主分支
git checkout main

# 3. 合并模板更改
git merge upstream/main

# 4. 解决冲突（如有）
# 编辑冲突文件后：
git add .
git commit -m "Merge upstream updates"

# 5. 推送到你的仓库（origin = 你的仓库）
git push origin main
```

### Clone 模式同步步骤

Clone 模式用户使用独立更新脚本：

```bash
# 运行独立更新脚本（推荐）
bash scripts/update-standalone.sh
```

该脚本将：
- 自动检测当前模式（Clone 模式）
- 临时下载最新模板到临时目录
- 智能合并更新（保留个人数据）
- 显示更新摘要

#### Clone 模式手动更新（高级）

```bash
# 1. 备份个人数据
bash scripts/backup.sh

# 2. 临时克隆最新模板
git clone --depth 1 https://github.com/GreadXu/claude-code-study.git .temp-update

# 3. 复制更新的文件（排除个人数据）
# 注意：不要复制 PROGRESS.md、*/checklist.md、*/notes.md 等
cp -r .temp-update/scripts/* scripts/
cp -r .temp-update/.templates/* .templates/
# ... 其他需要更新的文件

# 4. 清理临时目录
rm -rf .temp-update
```

---

## 📂 文件分类说明

### 系统文件（Git 追踪）

这些文件由模板仓库维护，更新时会被覆盖：

| 类型 | 文件/目录 | 说明 |
|------|-----------|------|
| **配置** | `.gitignore`, `CLAUDE.md` | 系统配置 |
| **模板** | `.templates/` | 初始化模板 |
| **文档** | `README.md`, `TEMPLATE_GUIDE.md` | 使用文档 |
| **脚本** | `scripts/` | 自动化脚本 |
| **模块结构** | `XX-阶段名称/*/README.md` | 模块导学 |

### 个人数据（Git 忽略）

这些文件完全本地管理，更新时不会受影响：

| 类型 | 文件/目录 | 说明 |
|------|-----------|------|
| **进度** | `PROGRESS.md` | 学习进度总表 |
| **书签** | `.claude/LEARNING_BOOKMARKS.md` | 学习书签 |
| **缓存** | `.claude/KNOWLEDGE_CACHE.md` | 缓存状态 |
| **清单** | `**/checklist.md` | 模块学习清单 |
| **笔记** | `**/notes.md` | 学习笔记 |
| **缓存** | `**/knowledge/` | 知识缓存目录 |

---

## 🛠️ 自定义学习计划

### 添加自定义模块

使用脚本快速创建新模块：

```bash
# 用法
bash scripts/create-module.sh <模块名> <阶段> <优先级>

# 示例：添加一个 React 学习模块
bash scripts/create-module.sh react-basics 01-基础入门 P1

# 示例：添加一个高级主题模块
bash scripts/create-module.sh advanced-patterns 02-进阶探索 P2
```

脚本将自动：
1. 创建模块目录结构
2. 生成 README.md、checklist.md、notes.md 模板
3. 提示你更新 CLAUDE.md 映射

### 手动创建模块

1. 创建模块目录：
```bash
mkdir -p 01-基础入门/my-module
```

2. 复制模板文件：
```bash
cp .templates/module/checklist.template.md 01-基础入门/my-module/checklist.md
cp .templates/module/notes.template.md 01-基础入门/my-module/notes.md
```

3. 创建 README.md（参考 `.templates/module/README.template.md`）

4. 更新 CLAUDE.md 中的模块路径映射

### 配置知识来源

在模块的 `README.md` 中添加学习资源：

```markdown
## 学习资源

### 官方文档
- [官方文档链接](https://example.com/docs)

### 推荐教程
- 你的教程链接...
```

---

## 🌿 分支策略

### 推荐工作流

```
main (你的主分支)
├── 个人数据文件（本地修改）
└── 系统文件（与 upstream 同步）
```

### 贡献分支（可选）

如果你想向模板贡献改进：

```bash
# 1. 创建功能分支
git checkout -b feature/my-improvement

# 2. 进行修改...

# 3. 提交更改
git add .
git commit -m "Add: my improvement"

# 4. 推送到你的仓库
git push origin feature/my-improvement

# 5. 创建 Pull Request 到模板仓库
```

---

## 🛡️ 数据保护

### .gitignore 保护机制

所有个人数据文件都已在 `.gitignore` 中配置，确保：

1. **不会意外提交**：`git add .` 不会包含这些文件
2. **更新时安全**：从 upstream 拉取更新不会影响这些文件
3. **完全隐私**：你的学习进度和笔记不会同步到 GitHub

### 验证配置

```bash
# 检查哪些文件被追踪
git status

# 应该看到类似：
# On branch main
# Your branch is up to date with 'origin/main'.
#
# nothing to commit, working tree clean
```

如果你看到 PROGRESS.md 或其他个人文件出现在 `git status` 中，说明配置有误。

---

## 📖 版本迁移

### 检测版本更新

当模板仓库发布新版本时，你会看到：

```bash
$ bash scripts/sync.sh
📢 发现新版本：v2.0.0 (当前: v1.3.3)
```

### 运行迁移

```bash
# 运行迁移脚本
bash scripts/migrate.sh
```

该脚本将：
- 检测当前版本和目标版本
- 验证个人数据完整性
- 检查模板更新
- 执行数据兼容性检查
- 生成迁移报告

---

## ❓ 常见问题解答

### Q1: 我的学习进度会丢失吗？

**A: 不会。** 所有个人数据文件都被 `.gitignore` 保护，模板更新不会影响这些文件。

### Q2: 如何备份我的学习数据？

**A:** 使用备份脚本：
```bash
bash scripts/backup.sh
```

### Q3: 我修改了系统文件，同步时会怎样？

**A: 会被覆盖。** 系统文件的修改会在下次同步时被模板版本覆盖。如需贡献改进，请通过 Pull Request。

### Q4: 如何添加自己的学习模块？

**A:** 使用 `scripts/create-module.sh` 脚本，或手动创建模块目录并复制模板文件。详见"自定义学习计划"章节。

### Q5: init.sh 脚本运行失败怎么办？

**A: 检查以下项目**：
1. 确保你在仓库根目录
2. 检查 .templates 目录是否存在
3. 查看错误信息并参考故障排除部分

### Q6: 如何回滚到之前的版本？

**A: 使用 git reflog**：
```bash
# 查看历史
git reflog

# 回滚到指定提交
git checkout HEAD@{n}

# 然后创建新分支
git checkout -b recovery-branch
```

---

## 🔧 故障排除

### 问题：同步时出现冲突

**解决方案**：
```bash
# 1. 查看冲突文件
git status

# 2. 编辑冲突文件，保留需要的部分
# 冲突标记如下：
# <<<<<<< HEAD
# 你的更改
# =======
# 模板更改
# >>>>>>> upstream/main

# 3. 标记为已解决
git add <冲突文件>

# 4. 完成合并
git commit
```

### 问题：init.sh 检测到已初始化

**解决方案**：
```bash
# 如果需要重新初始化，先删除现有文件
rm PROGRESS.md
rm .claude/LEARNING_BOOKMARKS.md
rm .claude/KNOWLEDGE_CACHE.md

# 然后重新运行
bash scripts/init.sh
```

### 问题：个人文件出现在 git status 中

**解决方案**：
```bash
# 1. 检查 .gitignore 是否正确
cat .gitignore

# 2. 如果文件已被追踪，需要先移除
git rm --cached <文件名>

# 3. 清理缓存
git cache clear

# 4. 验证
git status
```

---

## 📚 最佳实践

### 1. 定期同步模板更新

```bash
# 建议每周运行一次
bash scripts/sync.sh
```

### 2. 备份个人数据

```bash
# 定期备份到安全位置
bash scripts/backup.sh
```

### 3. 遵循学习路径

按照 README.md 中推荐的学习路径进行，避免跳跃式学习。

### 4. 记录学习日志

在 PROGRESS.md 的学习日志中记录重要里程碑和心得。

### 5. 使用书签系统

遇到需要深入探索的问题时，使用书签系统记录，确保能返回主线。

### 6. 自定义学习内容

根据你的学习目标，添加或删除模块，让模板适合你的需求。

---

## 🤝 贡献指南

### 如何贡献改进？

1. **发现问题**：在 Issues 中报告
2. **提出建议**：在 Discussions 中讨论
3. **提交代码**：
   - Fork 仓库
   - 创建功能分支
   - 提交 Pull Request

### 贡献类型

- 🐛 Bug 修复
- ✨ 新功能
- 📚 文档改进
- 🎨 代码优化
- ✅ 测试用例

---

## 📞 获取帮助

- 📖 查看完整文档：[README.md](./README.md)
- 💬 讨论区：[GitHub Discussions](https://github.com/GreadXu/claude-code-study/discussions)
- 🐛 问题报告：[GitHub Issues](https://github.com/GreadXu/claude-code-study/issues)

---

**创建日期**：2026-02-27
**最后更新**：2026-03-05
