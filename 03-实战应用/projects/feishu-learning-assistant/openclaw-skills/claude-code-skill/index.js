/**
 * Claude Code CLI 调用 Skill
 *
 * 用途：在 WSL 中调用 Windows 上的 Claude Code CLI
 * 环境：WSL 2 → Windows
 */

const { exec } = require('child_process');
const { promisify } = require('util');

const execAsync = promisify(exec);

class ClaudeCodeSkill {
  constructor(options = {}) {
    this.bridgePath = options.bridgePath || `${process.env.HOME}/.local/bin/claude-code-bridge.sh`;
    this.timeout = options.timeout || 30000; // 30 秒超时
  }

  /**
   * 执行 Claude Code 命令
   * @param {string} command - Claude Code 命令
   * @returns {Promise<{success: boolean, output?: string, error?: string}>}
   */
  async execute(command) {
    try {
      // 转义命令中的特殊字符
      const escapedCommand = this._escapeCommand(command);

      // 调用桥接脚本
      const { stdout, stderr } = await execAsync(
        `"${this.bridgePath}" ${escapedCommand}`,
        {
          timeout: this.timeout,
          env: {
            ...process.env,
            LANG: 'zh_CN.UTF-8'
          }
        }
      );

      // 检查执行结果
      if (stderr && !stdout) {
        return {
          success: false,
          error: stderr.trim()
        };
      }

      return {
        success: true,
        output: stdout.trim()
      };
    } catch (error) {
      // 处理超时
      if (error.killed && error.signal === 'SIGTERM') {
        return {
          success: false,
          error: '命令执行超时'
        };
      }

      // 处理其他错误
      return {
        success: false,
        error: error.message || '命令执行失败'
      };
    }
  }

  /**
   * 转义命令中的特殊字符
   * @param {string} command
   * @returns {string}
   */
  _escapeCommand(command) {
    // 转义双引号和反引号
    return command.replace(/"/g, '\\"').replace(/`/g, '\\`');
  }

  /**
   * 测试桥接脚本是否可用
   * @returns {Promise<boolean>}
   */
  async testConnection() {
    try {
      const result = await this.execute('--version');
      return result.success;
    } catch {
      return false;
    }
  }
}

module.exports = ClaudeCodeSkill;
