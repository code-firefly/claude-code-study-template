/**
 * 学习管理 Skill
 *
 * 用途：解析飞书学习指令，路由到对应的 Claude Code 命令
 * 功能：指令解析、参数提取、命令映射
 */

const ClaudeCodeSkill = require('../claude-code-skill');

/**
 * 指令映射表
 *
 * 格式：{ 飞书指令关键词: (args) => Claude Code 命令生成函数 }
 */
const COMMAND_MAP = {
  '开始学习': (args) => `开始学习 ${args.join(' ')}`,
  '查看进度': () => '查看学习状态',
  '更新': (args) => `更新进度 ${args.join(' ')}`,
  '创建书签': (args) => `创建书签 ${args.join(' ')}`,
  '继续书签': () => '继续书签',
  '完成书签': () => '完成书签',
  '查看状态': () => '查看学习状态',
  '学习状态': () => '查看学习状态',
  '我的进度': () => '查看学习状态',
};

/**
 * 帮助文档
 */
const HELP_TEXT = `
📚 学习助手可用指令：

【进度管理】
• 查看进度 / 学习状态 / 我的学习进度
• 更新 <模块名> - 同步模块进度
• 开始学习 <模块名> - 启动模块学习

【书签系统】
• 创建书签 <名称> - 记录学习疑问
• 继续书签 - 继续探索书签
• 完成书签 - 完成当前书签

【示例】
• 查看进度
• 开始学习 mcp-basics
• 更新 claude-code-core
• 创建书签 深入理解 Tool Use
• 继续书签
`.trim();

class LearningManagerSkill {
  constructor(options = {}) {
    this.claudeCodeSkill = new ClaudeCodeSkill(options.claudeCode);
    this.debug = options.debug || false;
  }

  /**
   * 解析飞书消息，提取指令和参数
   * @param {string} message - 飞书消息内容
   * @returns {{ intent: string, command: string, args: string[] } | null}
   */
  parse(message) {
    // 移除多余空格
    message = message.trim();

    // 遍历指令映射
    for (const [keyword, handler] of Object.entries(COMMAND_MAP)) {
      if (message.startsWith(keyword)) {
        // 提取参数
        const argsString = message.slice(keyword.length).trim();
        const args = argsString ? argsString.split(/\s+/) : [];

        return {
          intent: keyword,
          command: handler(args),
          args: args
        };
      }
    }

    // 检查是否是帮助请求
    if (['帮助', 'help', '使用帮助', '？', '?'].includes(message.toLowerCase())) {
      return {
        intent: 'help',
        command: 'help',
        args: []
      };
    }

    // 未匹配到指令
    return null;
  }

  /**
   * 执行学习管理指令
   * @param {string} message - 飞书消息内容
   * @returns {Promise<{success: boolean, output?: string, error?: string}>}
   */
  async execute(message) {
    try {
      // 解析指令
      const parsed = this.parse(message);

      if (!parsed) {
        return {
          success: false,
          error: '未识别的指令',
          help: HELP_TEXT
        };
      }

      // 处理帮助请求
      if (parsed.intent === 'help') {
        return {
          success: true,
          output: HELP_TEXT
        };
      }

      // 调试日志
      if (this.debug) {
        console.log(`[LearningManager] 解析结果:`, parsed);
      }

      // 调用 Claude Code Skill
      const result = await this.claudeCodeSkill.execute(parsed.command);

      return result;
    } catch (error) {
      return {
        success: false,
        error: `指令执行失败: ${error.message}`
      };
    }
  }

  /**
   * 获取可用指令列表
   * @returns {string[]}
   */
  getAvailableCommands() {
    return Object.keys(COMMAND_MAP);
  }

  /**
   * 获取帮助文档
   * @returns {string}
   */
  getHelp() {
    return HELP_TEXT;
  }
}

module.exports = LearningManagerSkill;
