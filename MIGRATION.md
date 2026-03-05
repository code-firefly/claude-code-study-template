# 迁移指南

> 本指南帮助你从一个版本迁移到另一个版本，确保个人数据安全。

---

## ⚠️ 前置知识

在开始迁移前，确保你了解以下 Git 概念：

| 概念 | 含义 | 示例 |
|------|------|------|
| **upstream** | 官方主仓库 | `git fetch upstream` = 从官方仓库获取更新 |
| **origin** | 你的个人仓库 | `git push origin main` = 推送到你的仓库 |
| **HEAD** | 当前所在的提交 | `HEAD~1` = 上一个提交 |
| **--ours** | 保留"当前分支"的版本 | 合并冲突时，保留你的修改 |
| **--theirs** | 保留"要合并的分支"版本 | 合并冲突时，采用上游的修改 |
| **--hard** | 强制重置，丢弃未提交的修改 | ⚠️ 危险操作，会丢失数据 |

> 不熟悉这些概念？先阅读 [TEAM_GUIDE.md](./TEAM_GUIDE.md#-理解远程仓库origin-vs-upstream)

---

## 🔍 版本检测

### 检查当前版本

```bash
# 方法 1：查看 CHANGELOG.md
cat CHANGELOG.md | grep "^\## \["

# 方法 2：查看最近提交
git log --oneline -1

# 方法 3：查看 .templates 目录
ls -la .templates/
```

### 检查最新版本

```bash
# 获取上游更新信息
git fetch upstream
git tag | tail -1
```

---

## 🚀 迁移步骤

> **⚠️ 环境要求**：迁移脚本需要通过 Git Bash 或 WSL 运行。

### 步骤 1：备份个人数据

**方法 A：使用备份脚本（推荐）**

```bash
bash scripts/backup.sh
```

**方法 B：手动备份**

```bash
# 创建备份目录
mkdir -p .backups/migration-$(date +%Y%m%d)

# 复制个人数据
cp PROGRESS.md .backups/migration-$(date +%Y%m%d)/
cp .claude/LEARNING_BOOKMARKS.md .backups/migration-$(date +%Y%m%d)/
cp .claude/KNOWLEDGE_CACHE.md .backups/migration-$(date +%Y%m%d)/

# 复制所有模块清单和笔记
find . -name "checklist.md" -exec cp --parents {} .backups/migration-$(date +%Y%m%d)/ \;
find . -name "notes.md" -exec cp --parents {} .backups/migration-$(date +%Y%m%d)/ \;
```

### 步骤 2：获取更新

```bash
# 拉取上游更新
git fetch upstream

# 查看变更
git log HEAD..upstream/main --oneline
```

### 步骤 3：运行迁移脚本

```bash
bash scripts/migrate.sh
```

该脚本将：
1. 检测当前版本和目标版本
2. 验证个人数据完整性
3. 检查模板更新
4. 执行数据兼容性检查
5. 生成迁移报告

### 步骤 4：合并更新

```bash
# 合并上游更改
git merge upstream/main

# 如有冲突，解决后继续
git add .
git commit -m "Merge upstream updates (v{OLD_VERSION} → v{NEW_VERSION})"
```

### 步骤 5：验证迁移

```bash
# 验证个人文件完整性
test -f PROGRESS.md && echo "✓ PROGRESS.md 存在"
test -f .claude/LEARNING_BOOKMARKS.md && echo "✓ 书签文件存在"
test -f .claude/KNOWLEDGE_CACHE.md && echo "✓ 缓存文件存在"

# 检查模块文件
find . -name "checklist.md" | wc -l  # 应该显示 8
find . -name "notes.md" | wc -l      # 应该显示 8

# 验证 gitignore 配置
git status  # 不应该显示个人数据文件
```

---

## 📋 迁移检查清单

### 迁移前
- [ ] 已备份所有个人数据
- [ ] 已记录当前版本号
- [ ] 已查看 CHANGELOG.md 了解变更
- [ ] 已了解可能的影响

### 迁移中
- [ ] 备份成功验证
- [ ] 获取上游更新成功
- [ ] 迁移脚本运行无错误
- [ ] 合并完成（或冲突已解决）

### 迁移后
- [ ] 个人数据文件完整
- [ ] PROGRESS.md 格式正确
- [ ] 模块清单可正常访问
- [ ] 学习进度保留
- [ ] Claude 命令正常工作

---

## 🔄 版本特定迁移

### 迁移到 v1.0.0（从预发布版本）

如果你使用的是早期的预发布版本：

1. **新增 .gitignore 配置**
   ```bash
   # 确保 .gitignore 包含个人数据规则
   cat .gitignore | grep "个人学习数据"
   ```

2. **初始化模板系统**
   ```bash
   # 运行初始化脚本
   bash scripts/init.sh --force
   ```

3. **迁移书签数据**
   ```bash
   # 如果你有旧格式的书签，手动迁移到新格式
   # 参考 .templates/LEARNING_BOOKMARKS.template.md
   ```

---

## ⚠️ 常见问题

### Q1: 合并时出现冲突怎么办？

**A: 按优先级处理冲突**

1. **系统文件冲突**：保留上游版本（系统更新）
2. **个人数据冲突**：保留你的版本（本地优先）
3. **模板文件冲突**：保留上游版本（系统更新）

```bash
# 示例：解决 PROGRESS.md 冲突
git checkout --ours PROGRESS.md   # 保留你的版本（本地优先）
git add PROGRESS.md

# 示例：解决 CLAUDE.md 冲突
git checkout --theirs CLAUDE.md   # 保留上游版本（系统更新）
git add CLAUDE.md
```

### Q2: 迁移后进度丢失怎么办？

**A: 从备份恢复**

```bash
# 恢复单个文件
cp .backups/migration-YYYYMMDD/PROGRESS.md PROGRESS.md

# 恢复所有模块数据
cp -r .backups/migration-YYYYMMDD/*/checklist.md ./
```

### Q3: 新版本的模板如何应用？

**A: 模板不会自动覆盖现有文件**

如果你想使用新模板：

```bash
# 备份现有文件
cp <文件> <文件>.backup

# 从模板重新创建
cp .templates/<模板文件> <目标文件>

# 手动合并内容
```

### Q4: 迁移脚本失败了怎么办？

**A: 查看错误信息并手动执行步骤**

```bash
# 查看详细错误
bash scripts/migrate.sh --verbose

# 手动执行迁移步骤
# 参考"迁移步骤"部分
```

---

## 🔙 回滚方案

### 方案 A：使用 Git 回滚

```bash
# 查看迁移前的提交
git reflog

# 回滚到指定提交
git reset --hard HEAD@{n}

# 恢复个人数据
cp .backups/migration-YYYYMMDD/* ./
```

### 方案 B：从备份恢复

```bash
# 完整恢复备份
rm -rf PROGRESS.md .claude/LEARNING_BOOKMARKS.md .claude/KNOWLEDGE_CACHE.md
cp -r .backups/migration-YYYYMMDD/* ./
```

### 方案 C：切换到备份分支

```bash
# 创建备份分支
git branch backup-before-migration

# 迁移后如需回退
git checkout backup-before-migration
```

---

## 📞 获取帮助

如果迁移过程中遇到问题：

1. 查看 [TEAM_GUIDE.md](./TEAM_GUIDE.md) 的故障排除部分
2. 在 [GitHub Issues](https://github.com/YOUR_ORG/YOUR_REPO/issues) 搜索类似问题
3. 创建新 Issue，附上：
   - 当前版本和目标版本
   - 错误信息
   - 迁移脚本输出
   - 操作系统信息

---

## 📊 迁移报告模板

完成迁移后，建议记录迁移报告：

```markdown
## 迁移报告

**日期**：YYYY-MM-DD
**版本**：vX.Y.Z → vA.B.C
**操作人**：Your Name

### 迁移前检查
- [x] 备份完成
- [x] 版本确认

### 迁移过程
- [x] 获取更新
- [x] 运行迁移脚本
- [x] 解决冲突

### 迁移后验证
- [x] 个人数据完整
- [x] 功能正常

### 遇到的问题
1. 问题描述
   - 解决方案：...

### 备注
...
```

---

**创建日期**：2026-02-27
**支持版本**：1.0.0+
