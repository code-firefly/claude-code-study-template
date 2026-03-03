# Day 1 练习：OpenClaw Web UI 探索

> **练习目标**：全面熟悉 OpenClaw Web UI 的各项功能和操作，掌握基础到高级的使用技巧。
>
> **预计时长**：1-1.5 小时
> **前置条件**：已完成 OpenClaw 部署和 Gateway 启动

---

## 练习 1：基础操作

### 任务 A：访问和登录
1. **获取 Gateway Token**
   ```bash
   # 在 WSL 中执行
   cat ~/.openclaw/openclaw.json | grep token
   ```

2. **在浏览器中打开 Web UI**
   - URL: `http://127.0.0.1:18789/?token={你的token}`
   - 或者直接访问 `http://127.0.0.1:18789`（Web UI 会提示输入 token）

3. **验证连接成功**
   - 观察 Gateway 状态显示为"Connected"
   - 查看主界面布局

### 任务 B：发送测试消息
1. 在消息中心创建或选择一个会话
2. 输入测试消息（如："你好"）
3. 观察 AI 响应
4. 尝试不同类型的消息：
   - 问题："今天天气怎么样？"
   - 命令："帮我搜索一下最新科技新闻"
   - 闲聊："讲个笑话"

### 任务 C：查看消息历史
1. 浏览会话中的历史消息
2. 点击某条消息查看详细信息
3. 理解消息的完整结构（用户消息 + AI 响应）
4. 尝试使用搜索功能快速定位消息

---

## 练习 2：Skill 管理

### 任务 A：浏览 Skills
1. 进入 Skill 管理面板
2. 查看所有已安装的 Skills
3. 区分系统 Skills 和用户 Skills
4. 观察 Skill 的状态：
   - `ready` - 已就绪，可以使用
   - `missing` - 缺少依赖或配置
   - `configured` - 已配置

### 任务 B：启用/禁用 Skill
1. 选择一个用户安装的 Skill
2. 尝试禁用它
3. 重启 Gateway：
   ```bash
   # 在 WSL 中执行
   pkill -f openclaw-gateway && openclaw gateway start
   ```
4. 验证 Skill 已被禁用（测试该 Skill 是否响应）
5. 重新启用 Skill 并重启 Gateway

### 任务 C：理解 Skill 详情
1. 点击某个 Skill 查看详情
2. 理解 Skill 的描述、配置要求
3. 查看 Skill 的来源标签：
   - `openclaw-bundled` - OpenClaw 内置
   - `clawhub` - ClawHub 社区
   - `workspace` - 工作区自定义
4. 查看 Skill 的版本信息

---

## 练习 3：配置面板

### 任务 A：查看当前配置
1. 进入配置面板
2. 浏览完整的 openclaw.json 内容
3. 理解各项配置的含义：
   - `agents` - Agent 配置
   - `gateway` - Gateway 设置
   - `channels` - 通道配置
   - `providers` - API 提供商
   - `sessions` - 会话隔离级别

### 任务 B：理解模型配置
1. 查看 `agents.defaults.model` 设置
2. 理解 `providers` 配置结构
3. 确认当前使用的模型（如 `openai/qwen-coding-plus`）

### 任务 C：理解通道配置
1. 查看 `channels` 配置
2. 确认飞书通道已启用
3. 查看 `allowFrom` 白名单设置
4. 理解通道安全机制

---

## 练习 4：Canvas 数据

### 任务 A：浏览 Canvas
1. 进入 Canvas 浏览器
2. 查看 `sessions` 数据：
   - 观察会话 ID 结构
   - 查看消息存储格式
   - 理解会话状态字段
3. 查看 `users` 数据：
   - 观察用户 ID 生成规则
   - 查看用户元数据
4. 理解 Canvas 的数据结构

### 任务 B：数据操作
1. 尝试查看某个特定会话的数据
2. 理解 Canvas 中的字段含义：
   - `messages` - 消息数组
   - `context` - 会话上下文
   - `metadata` - 元数据
3. （可选）尝试导出数据为 JSON

---

## 练习 5：开发工具

### 任务 A：API 端点
1. 查看所有可用的 API 端点
2. 理解 REST API 的结构：
   - `GET /api/sessions` - 获取会话列表
   - `POST /api/message` - 发送消息
   - `GET /api/skills` - 获取 Skills 列表
3. （高级）尝试调用某个 API

### 任务 B：日志查看器
1. 打开日志查看器
2. 观察实时日志流
3. 发送一条消息并观察日志变化
4. 理解日志级别：
   - `info` - 一般信息
   - `warn` - 警告信息
   - `error` - 错误信息

### 任务 C：系统信息
1. 查看 Gateway 版本信息
2. 查看运行统计数据：
   - 消息数量
   - 会话数量
   - 运行时间
3. 运行诊断工具

---

## 练习 6：高级功能（可选）

### 任务 A：WebSocket 调试
1. 查看原始 WebSocket 消息
2. 发送一条消息并观察 WebSocket 流量
3. 理解消息格式：
   - 请求格式
   - 响应格式
   - 事件通知

### 任务 B：会话管理
1. 创建一个新会话
2. 删除一个测试会话
3. 清空会话历史
4. 理解会话生命周期

### 任务 C：配置修改
1. 在配置面板中修改某个设置（如修改默认模型）
2. 保存配置
3. 重启 Gateway 使配置生效
4. 验证修改成功

---

## 练习输出清单

完成所有练习后，你应该能够：

**基础操作**
- [ ] 独立访问和登录 Web UI
- [ ] 发送并接收测试消息
- [ ] 浏览和查看消息历史
- [ ] 使用搜索功能定位消息

**Skill 管理**
- [ ] 列出所有已安装的 Skills
- [ ] 启用/禁用指定的 Skill
- [ ] 理解 Skill 状态和详情
- [ ] 区分不同来源的 Skills

**配置管理**
- [ ] 理解 openclaw.json 的结构
- [ ] 查看和修改配置
- [ ] 重启 Gateway 使配置生效
- [ ] 理解通道安全机制

**Canvas 数据**
- [ ] 浏览 Canvas 数据结构
- [ ] 查看会话和用户数据
- [ ] 理解数据字段含义
- [ ] 导出 Canvas 数据

**开发工具**
- [ ] 查看和调用 API 端点
- [ ] 使用日志查看器
- [ ] 理解系统诊断信息
- [ ] 查看运行统计数据

**高级功能**
- [ ] 调试 WebSocket 消息
- [ ] 管理会话生命周期
- [ ] 修改配置并验证
- [ ] 理解消息流向

---

## 常见问题

**Q: Token 在哪里找到？**
A: 在 `~/.openclaw/openclaw.json` 的 `gateway.auth.token` 字段。可以使用以下命令快速查看：
```bash
cat ~/.openclaw/openclaw.json | grep -A 2 '"auth"'
```

**Q: 为什么修改 Skill 状态后没有生效？**
A: 需要重启 Gateway 才能使 Skill 状态更改生效：
```bash
pkill -f openclaw-gateway && openclaw gateway start
```

**Q: Canvas 数据安全吗？**
A: Canvas 是本地持久化存储，数据只在本地，不会上传到云端。但请注意备份重要数据。

**Q: 如何清空所有会话历史？**
A: 在 Canvas 浏览器中选择 `sessions` 数据，然后删除所有条目；或在会话管理中选择"清空会话历史"。

**Q: Web UI 无法连接怎么办？**
A: 检查以下几点：
1. Gateway 是否正在运行：`ps aux | grep openclaw-gateway`
2. 端口是否正确：默认为 18789
3. Token 是否正确
4. 防火墙是否阻止了连接

**Q: 如何从 Windows 访问 WSL 中的 OpenClaw？**
A: WSL2 会自动转发 localhost 端口，直接在 Windows 浏览器中访问 `http://127.0.0.1:18789` 即可。

---

## 练习笔记

在此记录你的练习过程中发现的问题和解决方案：

<!-- 在此添加你的笔记 -->
