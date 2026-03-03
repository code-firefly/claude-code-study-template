/**
 * Study Workflow Skill - 入口文件
 * 学习工作流程管理 Skill
 *
 * 命令:
 *   /study start <模块名>     - 开始学习
 *   /study update <模块名>    - 更新进度
 *   /study complete <模块名>  - 完成学习
 *   /study status [模块名]    - 查看状态
 *   /study sync [mode]        - 同步上游更新
 */

import { handle as handleStart } from './commands/start.js';
import { handle as handleUpdate } from './commands/update.js';
import { handle as handleComplete } from './commands/complete.js';
import { handle as handleStatus } from './commands/status.js';
import { handle as handleSync } from './commands/sync.js';

// 导出所有类型
export * from './lib/types.js';

// 导出库函数
export * from './lib/module-locator.js';
export * from './lib/progress-parser.js';
export * from './lib/progress-calculator.js';
export * from './lib/file-updater.js';
export * from './lib/ui-formatter.js';
export * from './lib/update-checker.js';

// 导出命令处理器
export { handleStart, handleUpdate, handleComplete, handleStatus, handleSync };

// Skill 元数据
export const skillMeta = {
  name: 'study',
  version: '1.0.0',
  description: 'Claude Code 学习工作流程管理'
};

/**
 * 主入口函数 - 根据命令路由到相应的处理器
 */
export async function main(command: string, args: any, context: any): Promise<string> {
  switch (command) {
    case 'start':
      return await handleStart(args, context);
    case 'update':
      return await handleUpdate(args, context);
    case 'complete':
      return await handleComplete(args, context);
    case 'status':
      return await handleStatus(args, context);
    case 'sync':
      return await handleSync(args, context);
    default:
      return `未知命令: ${command}\n可用命令: start, update, complete, status, sync\n`;
  }
}

export default {
  main,
  skillMeta
};
