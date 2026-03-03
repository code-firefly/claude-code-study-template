# OpenClaw Skills 配置说明

> **项目**：飞书学习助手
> **组件**：OpenClaw Skills
> **更新日期**：2026-03-03

---

## 概述

本目录包含飞书学习助手项目所需的 OpenClaw Skills 配置。这些 Skills 实现了飞书指令到 Claude Code 命令的桥接。

---

## Skills 结构

```
openclaw-skills/
├── README.md                              # 本文件
├── claude-code-skill/                     # Claude Code CLI 调用 Skill
│   ├── skill.json                         # Skill 配置
│   ├── index.js                           # Skill 实现
│   └── README.md                          # Skill 说明
└── learning-manager/                      # 学习管理 Skill
    ├── skill.json                         # Skill 配置
    ├── index.js                           # Skill 实现
    └── README.md                          # Skill 说明
```

---

## claude-code-skill

### 功能

调用 Windows 上的 Claude Code CLI，执行学习命令。

### 接口

```javascript
{
  name: 'claude-code',
  execute: async (command) => {
    // command: 要执行的 Claude Code 命令
    // 返回: { success: boolean, output: string }
  }
}
```

### 使用示例

```javascript
const ClaudeCodeSkill = require('./claude-code-skill');

const skill = new ClaudeCodeSkill();
const result = await skill.execute('查看学习状态');

console.log(result.output);
```

---

## learning-manager

### 功能

解析飞书学习指令，路由到对应的 Claude Code 命令。

### 支持的指令

| 飞书指令 | Claude Code 命令 |
|----------|------------------|
| 开始学习 `<模块>` | 开始学习 `<模块>` |
| 查看进度 | 查看学习状态 |
| 更新 `<模块>` | 更新进度 `<模块>` |
| 创建书签 `<名称>` | 创建书签 `<名称>` |
| 继续书签 | 继续书签 |
| 完成书签 | 完成书签 |

### 接口

```javascript
{
  name: 'learning-manager',
  parse: async (message) => {
    // message: 飞书消息内容
    // 返回: { intent, command, args } 或 null
  },
  execute: async (message) => {
    // message: 飞书消息内容
    // 返回: Claude Code 执行结果
  }
}
```

### 使用示例

```javascript
const LearningManager = require('./learning-manager');

const manager = new LearningManager();

// 解析指令
const parsed = await manager.parse('开始学习 mcp-basics');
console.log(parsed); // { intent: '开始学习', command: '开始学习 mcp-basics', args: ['mcp-basics'] }

// 执行指令
const result = await manager.execute('查看进度');
console.log(result.output);
```

---

## 安装步骤

### 1. 复制 Skills 到 OpenClaw 目录

```bash
cp -r openclaw-skills/* ~/.openclaw/skills/
```

### 2. 安装依赖

```bash
cd ~/.openclaw/skills/claude-code-skill
npm install

cd ~/.openclaw/skills/learning-manager
npm install
```

### 3. 配置 OpenClaw

编辑 `~/.openclaw/config.json`，添加 Skills：

```json
{
  "skills": {
    "claude-code": {
      "path": "~/.openclaw/skills/claude-code-skill",
      "enabled": true
    },
    "learning-manager": {
      "path": "~/.openclaw/skills/learning-manager",
      "enabled": true
    }
  }
}
```

### 4. 重启 OpenClaw

```bash
sudo systemctl restart openclaw
```

---

## 测试

### 测试 claude-code-skill

```bash
node -e "
const Skill = require('./index.js');
const skill = new Skill();
skill.execute('查看学习状态').then(console.log);
"
```

### 测试 learning-manager

```bash
node -e "
const Manager = require('./index.js');
const manager = new Manager();
manager.execute('查看进度').then(console.log);
"
```

---

## 故障排查

### Skill 无法加载

检查 `skill.json` 格式是否正确，`main` 字段指向的文件是否存在。

### Claude Code 调用失败

检查桥接脚本路径和权限：
```bash
ls -la ~/.local/bin/claude-code-bridge.sh
```

### 指令无法解析

检查 `COMMAND_MAP` 配置，确保指令关键词正确。
