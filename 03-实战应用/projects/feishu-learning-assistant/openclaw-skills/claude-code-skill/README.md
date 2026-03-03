# claude-code-skill

> **OpenClaw Skill**：Claude Code CLI 调用桥接
> **版本**：1.0.0

---

## 功能说明

在 WSL 环境中调用 Windows 上的 Claude Code CLI，执行学习管理命令。

---

## 使用方法

### 基本用法

```javascript
const ClaudeCodeSkill = require('./index.js');

const skill = new ClaudeCodeSkill();

// 执行命令
const result = await skill.execute('查看学习状态');

if (result.success) {
  console.log(result.output);
} else {
  console.error(result.error);
}
```

### 自定义配置

```javascript
const skill = new ClaudeCodeSkill({
  bridgePath: '/path/to/bridge.sh',
  timeout: 60000  // 60 秒超时
});
```

---

## 返回值格式

```javascript
{
  success: boolean,  // 是否执行成功
  output?: string,   // 成功时的输出
  error?: string     // 失败时的错误信息
}
```

---

## 支持的命令

| 命令 | 说明 |
|------|------|
| 查看学习状态 | 显示所有模块进度 |
| 开始学习 `<模块>` | 启动模块学习 |
| 更新进度 `<模块>` | 同步模块进度 |
| 创建书签 `<名称>` | 创建学习书签 |
| 继续书签 | 继续探索书签 |
| 完成书签 | 完成当前书签 |

---

## 依赖

- Claude Code CLI (Windows)
- 桥接脚本 `claude-code-bridge.sh`
- Node.js 环境
