/**
 * /study sync 命令处理器
 * 同步上游更新到本地学习计划
 */

import { checkForUpdates, formatSyncCheckResult } from '../lib/update-checker.js';
import { formatSuccess, formatError, formatWarning } from '../lib/ui-formatter.js';
import { execSync } from 'child_process';

/**
 * 执行同步脚本
 */
async function runSyncScript(rootDir: string): Promise<{ success: boolean; output: string; error?: string }> {
  try {
    const output = execSync('bash scripts/sync.sh', {
      cwd: rootDir,
      encoding: 'utf-8',
      stdio: 'pipe'
    });
    return { success: true, output };
  } catch (error: any) {
    return {
      success: false,
      output: error.stdout || '',
      error: error.stderr || error.message
    };
  }
}

/**
 * 检查 upstream 配置
 */
function checkUpstreamConfigured(rootDir: string): boolean {
  try {
    const remotes = execSync('git remote', {
      cwd: rootDir,
      encoding: 'utf-8'
    });
    return remotes.split('\n').includes('upstream');
  } catch {
    return false;
  }
}

/**
 * 显示 upstream 配置指引
 */
function showUpstreamGuide(): string {
  const lines: string[] = [];

  lines.push('');
  lines.push('═════════════════════════════════════════════════════════');
  lines.push('⚙️  配置 upstream 远程仓库');
  lines.push('═════════════════════════════════════════════════════════');
  lines.push('');
  lines.push('upstream 远程仓库未配置，请按照以下步骤配置：');
  lines.push('');
  lines.push('1. 添加 upstream 远程仓库：');
  lines.push('   git remote add upstream <原始仓库URL>');
  lines.push('');
  lines.push('   示例：');
  lines.push('   git remote add upstream https://github.com/username/claude-code-study.git');
  lines.push('');
  lines.push('2. 验证配置：');
  lines.push('   git remote -v');
  lines.push('');
  lines.push('3. 配置完成后，再次运行：');
  lines.push('   /study sync');
  lines.push('');
  lines.push('═════════════════════════════════════════════════════════');

  return lines.join('\n');
}

/**
 * 处理 /study sync 命令
 */
export async function handle(args: { mode?: 'check' | 'auto' }, context: {
  rootDir: string;
  readFile: (path: string) => Promise<string>;
  writeFile: (path: string, content: string) => Promise<void>;
  askUser: (question: string, options?: string[]) => Promise<string>;
}): Promise<string> {
  const { mode = 'check' } = args;
  const { askUser, rootDir } = context;

  // Step 1: 检查 upstream 配置
  if (!checkUpstreamConfigured(rootDir)) {
    return showUpstreamGuide();
  }

  // Step 2: 检查更新
  const updateCheck = checkForUpdates(rootDir);

  // Step 3: 根据模式处理
  if (mode === 'check') {
    // check 模式：仅显示信息
    return formatSyncCheckResult(updateCheck);
  }

  // auto 模式：执行同步
  if (!updateCheck.hasUpdates) {
    return formatSyncCheckResult(updateCheck);
  }

  // 显示更新信息并确认
  const lines: string[] = [];
  lines.push('');
  lines.push('╔════════════════════════════════════════════════════════╗');
  lines.push('║              准备同步上游更新                        ║');
  lines.push('╚════════════════════════════════════════════════════════╝');
  lines.push('');
  lines.push(`当前版本: ${updateCheck.currentVersion}`);
  lines.push(`上游版本: ${updateCheck.upstreamVersion}`);
  lines.push('');
  lines.push('同步过程将：');
  lines.push('  1. 备份个人学习数据到 .backups/sync-<日期>/');
  lines.push('  2. 从 upstream 获取最新更新');
  lines.push('  3. 合并更新到本地分支');
  lines.push('  4. 验证个人数据完整性');
  lines.push('');
  lines.push('⚠️  注意：');
  lines.push('  - 个人数据文件（PROGRESS.md、checklist.md、notes.md）');
  lines.push('    已被 .gitignore 保护，不会被覆盖');
  lines.push('  - 如有冲突，系统文件建议保留 upstream 版本');
  lines.push('');

  const confirmed = await askUser(lines.join('\n') + '\n是否继续同步？(y/n):', ['y', 'n', 'Y', 'N']);

  if (confirmed.toLowerCase() !== 'y') {
    return '\n已取消同步。\n';
  }

  // 执行同步
  lines.push('正在同步...');
  lines.push('');

  const result = await runSyncScript(rootDir);

  if (result.success) {
    lines.push('');
    lines.push('═════════════════════════════════════════════════════════');
    lines.push('✅ 同步完成！');
    lines.push('═════════════════════════════════════════════════════════');
    lines.push('');
    lines.push('下一步：');
    lines.push('  - 查看 CHANGELOG.md 了解详细变更');
    lines.push('  - 如需迁移个人数据，运行: bash scripts/migrate.sh');
    lines.push('  - 推送到你的仓库: git push origin $(git branch --show-current)');
    lines.push('');

    return lines.join('\n') + '\n' + result.output;
  } else {
    lines.push('');
    lines.push('❌ 同步失败');
    lines.push('');

    if (result.error) {
      lines.push('错误信息:');
      lines.push(result.error);
      lines.push('');
    }

    lines.push('提示：');
    lines.push('  - 检查网络连接');
    lines.push('  - 确保在 main 分支上');
    lines.push('  - 手动运行: bash scripts/sync.sh');
    lines.push('');

    return lines.join('\n');
  }
}

export default handle;
