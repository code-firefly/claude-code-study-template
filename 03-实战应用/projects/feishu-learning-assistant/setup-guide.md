# 飞书学习助手 - 配置指南

> **项目**：飞书学习助手 (Feishu Learning Assistant)
> **预计配置时长**：1-2 小时
> **难度等级**：⭐⭐⭐ 中级
> **更新日期**：2026-03-03

---

## 配置前置检查

在开始配置前，请确认以下条件：

- [ ] 已完成 `openclaw-ecosystem` 模块学习
- [ ] WSL 2 环境已安装 OpenClaw
- [ ] Windows 环境已安装 Claude Code CLI
- [ ] 飞书机器人已配置并可接收消息
- [ ] 知道 Claude Code 项目在 Windows 中的完整路径

---

## 步骤 1：配置 Claude Code 桥接脚本

### 1.1 创建桥接脚本

在 WSL 中创建桥接脚本 `claude-code-bridge.sh`：

```bash
# 在 WSL 中执行
nano ~/.local/bin/claude-code-bridge.sh
```

输入以下内容：

```bash
#!/bin/bash

# Claude Code 桥接脚本 - WSL 调用 Windows CLI
# 用途：在 WSL 中调用 Windows 上的 Claude Code CLI

# Windows 用户名（请修改为你的用户名）
WINDOWS_USER="78044"

# Claude Code CLI 路径
CLAUDE_CODE_EXE="/mnt/c/Users/$WINDOWS_USER/AppData/Local/anthropic/claude-code/claude-code.exe"

# 学习项目路径（Windows 格式）
PROJECT_PATH="E:\\VebingCode\\claude-code-study"

# 检查 Claude Code 是否存在
if [ ! -f "$CLAUDE_CODE_EXE" ]; then
    echo "错误：Claude Code CLI 未找到"
    echo "请检查路径：$CLAUDE_CODE_EXE"
    exit 1
fi

# 执行 Claude Code 命令
"$CLAUDE_CODE_EXE" --cwd "$PROJECT_PATH" "$@"
```

### 1.2 设置执行权限

```bash
chmod +x ~/.local/bin/claude-code-bridge.sh
```

### 1.3 测试桥接脚本

```bash
# 测试查看学习状态
claude-code-bridge.sh "查看学习状态"
```

如果成功返回学习状态，说明桥接配置成功。

---

## 步骤 2：安装 OpenClaw Skills

### 2.1 创建 Skills 目录

```bash
# 在 WSL 中执行
mkdir -p ~/openclaw-skills/feishu-learning-assistant
cd ~/openclaw-skills/feishu-learning-assistant
```

### 2.2 安装 claude-code-skill

创建 `claude-code-skill` 目录：

```bash
mkdir -p claude-code-skill
cd claude-code-skill
npm init -y
```

创建 `skill.json`：

```json
{
  "name": "claude-code",
  "version": "1.0.0",
  "description": "调用 Claude Code CLI 执行学习命令",
  "main": "index.js",
  "author": "Your Name",
  "license": "MIT"
}
```

创建 `index.js`：

```javascript
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

module.exports = {
  name: 'claude-code',
  description: '调用 Claude Code CLI 执行学习命令',

  async execute(command, context = {}) {
    try {
      // 调用桥接脚本
      const bridgePath = `${process.env.HOME}/.local/bin/claude-code-bridge.sh`;
      const { stdout, stderr } = await execAsync(`${bridgePath} "${command}"`);

      if (stderr && !stdout) {
        return {
          success: false,
          error: stderr
        };
      }

      return {
        success: true,
        output: stdout
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }
};
```

### 2.3 安装 learning-manager Skill

创建 `learning-manager` 目录：

```bash
cd ~/openclaw-skills/feishu-learning-assistant
mkdir learning-manager
cd learning-manager
npm init -y
```

创建 `skill.json`：

```json
{
  "name": 'learning-manager',
  "version": "1.0.0",
  "description": "学习管理指令解析与路由",
  "main": "index.js",
  "author": "Your Name",
  "license": "MIT"
}
```

创建 `index.js`：

```javascript
const ClaudeCodeSkill = require('../claude-code-skill');

// 指令映射表
const COMMAND_MAP = {
  '开始学习': (args) => `开始学习 ${args.join(' ')}`,
  '查看进度': () => '查看学习状态',
  '更新': (args) => `更新进度 ${args.join(' ')}`,
  '创建书签': (args) => `创建书签 ${args.join(' ')}`,
  '继续书签': () => '继续书签',
  '完成书签': () => '完成书签',
  '查看状态': () => '查看学习状态',
};

module.exports = {
  name: 'learning-manager',
  description: '学习管理指令解析与路由',

  async parse(message) {
    // 移除多余空格
    message = message.trim();

    // 遍历指令映射
    for (const [keyword, handler] of Object.entries(COMMAND_MAP)) {
      if (message.startsWith(keyword)) {
        // 提取参数
        const args = message.slice(keyword.length).trim().split(/\s+/);
        return {
          intent: keyword,
          command: handler(args),
          args: args
        };
      }
    }

    // 未匹配到指令
    return null;
  },

  async execute(message) {
    // 解析指令
    const parsed = await this.parse(message);

    if (!parsed) {
      return {
        success: false,
        error: '未识别的指令',
        help: '可用指令：开始学习、查看进度、更新、创建书签、继续书签、完成书签'
      };
    }

    // 调用 Claude Code Skill
    const claudeCode = new ClaudeCodeSkill();
    const result = await claudeCode.execute(parsed.command);

    return result;
  }
};
```

---

## 步骤 3：配置 OpenClaw 飞书通道

### 3.1 注册 Skills 到 OpenClaw

编辑 OpenClaw 配置文件（通常在 `~/.openclaw/config.json`）：

```json
{
  "skills": {
    "claude-code": {
      "path": "~/openclaw-skills/feishu-learning-assistant/claude-code-skill",
      "enabled": true
    },
    "learning-manager": {
      "path": "~/openclaw-skills/feishu-learning-assistant/learning-manager",
      "enabled": true
    }
  },
  "channels": {
    "feishu": {
      "adapter": "feishu",
      "skills": ["learning-manager"],
      "enabled": true
    }
  }
}
```

### 3.2 重启 OpenClaw

```bash
# 重启 OpenClaw 服务
sudo systemctl restart openclaw
```

---

## 步骤 4：配置飞书机器人指令

### 4.1 在飞书开放平台配置

1. 进入飞书开放平台
2. 找到你的机器人应用
3. 添加快捷指令：

| 指令名称 | 指令内容 | 说明 |
|----------|----------|------|
| 查看学习进度 | 查看进度 | 显示当前学习状态 |
| 开始学习模块 | 开始学习 {模块名} | 启动指定模块 |
| 更新学习进度 | 更新 {模块名} | 同步模块进度 |

### 4.2 测试指令

在飞书中发送测试消息：

```
查看进度
```

---

## 步骤 5：端到端测试

### 5.1 测试指令列表

| 测试指令 | 预期结果 |
|----------|----------|
| 查看进度 | 显示学习进度总览 |
| 开始学习 mcp-basics | 启动 mcp-basics 模块 |
| 创建书签 测试书签 | 创建新的学习书签 |
| 继续书签 | 显示当前书签列表 |

### 5.2 验证清单

- [ ] 飞书消息能被 OpenClaw 接收
- [ ] 指令能正确解析
- [ ] Claude Code 能被正确调用
- [ ] 结果能返回到飞书
- [ ] 错误情况有友好提示

---

## 常见问题

### Q1: Claude Code CLI 路径找不到

**A**: 检查以下几点：
1. Windows 用户名是否正确
2. Claude Code 是否已安装
3. 安装路径是否为默认路径

### Q2: WSL 调用 Windows CLI 权限问题

**A**: 确保桥接脚本有执行权限：
```bash
chmod +x ~/.local/bin/claude-code-bridge.sh
```

### Q3: 中文乱码问题

**A**: 在桥接脚本中添加编码设置：
```bash
export LANG=zh_CN.UTF-8
```

### Q4: 飞书消息无响应

**A**: 检查：
1. OpenClaw 服务是否运行
2. 飞书 Webhook 是否配置正确
3. Skills 是否正确加载

---

## 下一步

配置完成后，你可以：

1. **扩展指令**：添加更多学习管理指令
2. **美化输出**：优化飞书消息展示格式
3. **添加提醒**：配置学习进度提醒功能
4. **数据分析**：集成学习数据分析

---

## 参考资源

- [Claude Code 文档](https://code.claude.com/docs)
- [OpenClaw GitHub](https://github.com/OpenClaw)
- [飞书开放平台](https://open.feishu.cn/)
