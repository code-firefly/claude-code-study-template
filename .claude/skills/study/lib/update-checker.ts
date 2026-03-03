/**
 * Update Checker - 检查上游更新
 * 用于检查本地学习计划是否有上游更新可用
 */

import { execSync } from 'child_process';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

/**
 * 更新检查结果
 */
export interface UpdateCheckResult {
  /** 是否有更新 */
  hasUpdates: boolean;
  /** 当前版本 */
  currentVersion: string;
  /** 上游版本 */
  upstreamVersion: string;
  /** 错误信息（如果有） */
  error?: string;
  /** upstream 是否已配置 */
  upstreamConfigured: boolean;
}

/**
 * 从 CHANGELOG.md 提取版本号
 */
function extractVersion(changelogContent: string): string {
  const match = changelogContent.match(/^## \[([\d.]+)\]/m);
  return match ? match[1] : 'unknown';
}

/**
 * 获取当前本地版本
 */
function getCurrentVersion(rootDir: string): string {
  const changelogPath = join(rootDir, 'CHANGELOG.md');
  if (!existsSync(changelogPath)) {
    return 'unknown';
  }
  try {
    const content = readFileSync(changelogPath, 'utf-8');
    return extractVersion(content);
  } catch {
    return 'unknown';
  }
}

/**
 * 获取上游版本（通过 git）
 */
function getUpstreamVersion(rootDir: string): string {
  try {
    const changelogContent = execSync('git show upstream/main:CHANGELOG.md', {
      cwd: rootDir,
      encoding: 'utf-8',
      stdio: ['pipe', 'pipe', 'pipe'] // 抑制错误输出
    });
    return extractVersion(changelogContent);
  } catch {
    return 'unknown';
  }
}

/**
 * 检查 upstream 是否已配置
 */
function isUpstreamConfigured(rootDir: string): boolean {
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
 * 比较两个版本号
 * 返回: 1 (v1 > v2), -1 (v1 < v2), 0 (v1 === v2)
 */
function compareVersions(v1: string, v2: string): number {
  if (v1 === 'unknown') return -1;
  if (v2 === 'unknown') return 1;

  const parts1 = v1.split('.').map(Number);
  const parts2 = v2.split('.').map(Number);

  for (let i = 0; i < Math.max(parts1.length, parts2.length); i++) {
    const p1 = parts1[i] || 0;
    const p2 = parts2[i] || 0;
    if (p1 > p2) return 1;
    if (p1 < p2) return -1;
  }
  return 0;
}

/**
 * 检查是否有上游更新
 *
 * @param rootDir - 仓库根目录
 * @returns 更新检查结果
 */
export function checkForUpdates(rootDir: string): UpdateCheckResult {
  const upstreamConfigured = isUpstreamConfigured(rootDir);

  if (!upstreamConfigured) {
    return {
      hasUpdates: false,
      currentVersion: getCurrentVersion(rootDir),
      upstreamVersion: 'unknown',
      upstreamConfigured: false,
      error: 'upstream 未配置'
    };
  }

  const currentVersion = getCurrentVersion(rootDir);
  const upstreamVersion = getUpstreamVersion(rootDir);

  if (upstreamVersion === 'unknown') {
    return {
      hasUpdates: false,
      currentVersion,
      upstreamVersion: 'unknown',
      upstreamConfigured: true,
      error: '无法获取上游版本（请检查网络连接）'
    };
  }

  const hasUpdates = compareVersions(upstreamVersion, currentVersion) > 0;

  return {
    hasUpdates,
    currentVersion,
    upstreamVersion,
    upstreamConfigured: true
  };
}

/**
 * 格式化更新提醒信息（非阻塞）
 *
 * @param result - 更新检查结果
 * @returns 格式化的提醒文本
 */
export function formatUpdateReminder(result: UpdateCheckResult): string {
  const lines: string[] = [];

  lines.push('╔═══════════════════════════════════════════════════════════════════╗');
  lines.push('║ ⚠ 发现学习计划更新可用                                          ║');
  lines.push('╠═══════════════════════════════════════════════════════════════════╣');

  if (!result.upstreamConfigured) {
    lines.push('║ upstream 远程仓库未配置                                        ║');
    lines.push('╠═══════════════════════════════════════════════════════════════════╣');
    lines.push('║ 当前版本: ' + result.currentVersion.padEnd(52) + '║');
    lines.push('╠═══════════════════════════════════════════════════════════════════╣');
    lines.push('║ 配置指引:                                                      ║');
    lines.push('║   git remote add upstream <原始仓库URL>                        ║');
    lines.push('╠═══════════════════════════════════════════════════════════════════╣');
    lines.push('║ 配置后可使用: /study sync 检查更新                             ║');
  } else if (result.error) {
    lines.push('║ 当前版本: ' + result.currentVersion.padEnd(52) + '║');
    lines.push('║ 上游版本: ' + result.upstreamVersion.padEnd(52) + '║');
    lines.push('╠═══════════════════════════════════════════════════════════════════╣');
    lines.push('║ ⚠ ' + result.error.padEnd(60) + '║');
  } else {
    lines.push('║ 当前版本: ' + result.currentVersion.padEnd(52) + '║');
    lines.push('║ 上游版本: ' + result.upstreamVersion.padEnd(52) + '║');
    lines.push('╠═══════════════════════════════════════════════════════════════════╣');
    lines.push('║ 建议：学习结束后运行 "同步学习计划" 或 /study sync auto        ║');
  }

  lines.push('╚═══════════════════════════════════════════════════════════════════╝');

  return '\n' + lines.join('\n') + '\n';
}

/**
 * 格式化同步检查结果
 *
 * @param result - 更新检查结果
 * @returns 格式化的检查结果文本
 */
export function formatSyncCheckResult(result: UpdateCheckResult): string {
  const lines: string[] = [];

  lines.push('');
  lines.push('╔════════════════════════════════════════════════════════╗');
  lines.push('║           学习计划同步 - 版本检查                    ║');
  lines.push('╚════════════════════════════════════════════════════════╝');
  lines.push('');

  if (!result.upstreamConfigured) {
    lines.push('❌ upstream 远程仓库未配置');
    lines.push('');
    lines.push('请先配置 upstream 远程仓库：');
    lines.push('');
    lines.push('  git remote add upstream <原始仓库URL>');
    lines.push('');
    lines.push('例如：');
    lines.push('  git remote add upstream https://github.com/username/claude-code-study.git');
    lines.push('');
    return lines.join('\n');
  }

  lines.push(`当前版本: ${result.currentVersion}`);
  lines.push(`上游版本: ${result.upstreamVersion}`);
  lines.push('');

  if (result.error) {
    lines.push(`❌ ${result.error}`);
    lines.push('');
    lines.push('请检查：');
    lines.push('  1. 网络连接是否正常');
    lines.push('  2. upstream URL 是否正确');
    lines.push('  3. 是否有权限访问上游仓库');
    lines.push('');
  } else if (result.hasUpdates) {
    lines.push('✨ 发现上游更新！');
    lines.push('');
    lines.push(`新版本: ${result.upstreamVersion}`);
    lines.push(`当前版本: ${result.currentVersion}`);
    lines.push('');
    lines.push('如需同步，请使用：');
    lines.push('  /study sync auto 或 "同步学习计划"');
    lines.push('');
  } else {
    lines.push('✅ 已是最新版本');
    lines.push('');
  }

  return lines.join('\n');
}
