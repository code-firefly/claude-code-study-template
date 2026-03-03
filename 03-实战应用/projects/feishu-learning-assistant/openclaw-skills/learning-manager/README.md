# learning-manager

> **OpenClaw Skill**：学习管理指令解析与路由
> **版本**：1.0.0

---

## 功能说明

解析飞书学习指令，路由到对应的 Claude Code 命令。

---

## 支持的指令

### 进度管理

| 飞书指令 | Claude Code 命令 | 说明 |
|----------|------------------|------|
| 查看进度 | 查看学习状态 | 显示所有模块进度 |
| 学习状态 | 查看学习状态 | 同上 |
| 我的进度 | 查看学习状态 | 同上 |
| 更新 `<模块>` | 更新进度 `<模块>` | 同步模块进度 |
| 开始学习 `<模块>` | 开始学习 `<模块>` | 启动模块学习 |

### 书签系统

| 飞书指令 | Claude Code 命令 | 说明 |
|----------|------------------|------|
| 创建书签 `<名称>` | 创建书签 `<名称>` | 记录学习疑问 |
| 继续书签 | 继续书签 | 继续探索书签 |
| 完成书签 | 完成书签 | 完成当前书签 |

### 帮助

| 飞书指令 | 功能 |
|----------|------|
| 帮助 / help / ？ | 显示可用指令列表 |

---

## 使用方法

### 基本用法

```javascript
const LearningManagerSkill = require('./index.js');

const manager = new LearningManagerSkill();

// 执行指令
const result = await manager.execute('查看进度');

if (result.success) {
  console.log(result.output);
} else {
  console.error(result.error);
}
```

### 调试模式

```javascript
const manager = new LearningManagerSkill({
  debug: true
});
```

### 解析指令（不执行）

```javascript
const parsed = manager.parse('开始学习 mcp-basics');
// 返回: { intent: '开始学习', command: '开始学习 mcp-basics', args: ['mcp-basics'] }
```

---

## 返回值格式

```javascript
{
  success: boolean,  // 是否执行成功
  output?: string,   // 成功时的输出
  error?: string,    // 失败时的错误信息
  help?: string      // 未识别指令时的帮助信息
}
```

---

## 依赖

- claude-code-skill（Claude Code CLI 调用）
- Node.js 环境
