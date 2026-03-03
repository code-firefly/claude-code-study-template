/**
 * /study update 命令处理器
 * 更新学习进度
 */

import { findModule, searchModule } from '../lib/module-locator.js';
import { parseChecklist, calculateProgress, getIncompleteItems } from '../lib/progress-parser.js';
import { generateUpdateUpdates, generateUpdatePreviewText, getCurrentDate } from '../lib/file-updater.js';
import { formatUpdatePreview, formatError, formatSuccess, formatModuleSuggestions, formatSingleModuleStatus } from '../lib/ui-formatter.js';
import { parseProgressFile } from '../lib/progress-calculator.js';
import { checkForUpdates, formatUpdateReminder } from '../lib/update-checker.js';

/**
 * 处理 /study update 命令
 */
export async function handle(args: { module: string; apply?: boolean }, context: {
  rootDir: string;
  readFile: (path: string) => Promise<string>;
  writeFile: (path: string, content: string) => Promise<void>;
  askUser: (question: string, options?: string[]) => Promise<string>;
}): Promise<string> {
  const { module: moduleInput, apply = false } = args;
  const { readFile, writeFile, askUser, rootDir } = context;

  // 非阻塞更新检查 - 存储提醒以供稍后添加
  const updateCheck = checkForUpdates(rootDir);
  const updateReminder = updateCheck.hasUpdates ? formatUpdateReminder(updateCheck) : '';

  // 辅助函数：添加更新提醒到结果
  const prependUpdateReminder = (result: string): string => {
    return updateReminder + result;
  };

  // 1. 查找模块
  const searchResult = searchModule(moduleInput);

  if (!searchResult.exact && searchResult.partial.length === 0) {
    return prependUpdateReminder(formatError('未找到模块', [
      `输入: "${moduleInput}"`,
      '请使用 /study status 查看所有可用模块'
    ]));
  }

  const module = searchResult.exact || searchResult.partial[0];

  // 2. 读取相关文件
  let checklistContent: string;
  let progressContent: string;

  try {
    checklistContent = await readFile(`${rootDir}/${module.checklistPath}`);
    progressContent = await readFile(`${rootDir}/PROGRESS.md`);
  } catch (error) {
    return prependUpdateReminder(formatError('无法读取模块文件', [
      `模块路径: ${module.path}`,
      '请确保模块目录结构完整'
    ]));
  }

  // 3. 解析当前进度
  const parsed = parseChecklist(checklistContent);

  // 4. 如果未选择模式，提示先开始学习
  if (parsed.mode === null) {
    return prependUpdateReminder(formatError('该模块尚未开始学习', [
      '请先使用 /study start ' + module.name + ' 开始学习',
      '然后手动编辑 checklist.md 勾选已完成的项目'
    ]));
  }

  // 5. 计算新进度
  const oldPercentage = calculateProgress(parsed);
  const newPercentage = oldPercentage; // 进度基于 checklist，没有变化

  // 6. 获取当前 PROGRESS.md 中的进度
  const progressParsed = parseProgressFile(progressContent);
  const currentRow = progressParsed.moduleRows.get(module.name);
  const currentPercentage = currentRow ? parseInt(currentRow.percentage) || 0 : 0;

  // 7. 生成更新预览
  const updates = generateUpdateUpdates(module, checklistContent, progressContent);

  // 8. 显示状态信息
  const statusLines: string[] = [];
  statusLines.push(formatSingleModuleStatus(
    module,
    parsed,
    {
      mode: parsed.mode === 'quick' ? '快速模式' : '完整模式',
      status: currentRow?.status || '进行中',
      percentage: `${newPercentage}%`
    }
  );

  // 9. 如果有未完成项，显示提示
  const incompleteItems = getIncompleteItems(parsed);
  if (incompleteItems.length > 0 && newPercentage < 100) {
    statusLines.push('📝 待完成项目:');
    const showItems = incompleteItems.slice(0, 5);
    for (const item of showItems) {
      statusLines.push(`   - ${item.substring(0, 55)}`);
    }
    if (incompleteItems.length > 5) {
      statusLines.push(`   ... 还有 ${incompleteItems.length - 5} 项`);
    }
    statusLines.push('');
    statusLines.push('提示: 请先手动编辑 checklist.md 勾选已完成的项目');
    statusLines.push('      然后使用 /study update 更新进度');
  }

  // 10. 如果进度没有变化，只显示状态
  if (newPercentage === currentPercentage) {
    statusLines.push('');
    statusLines.push('进度没有变化。如果已完成更多项目，请先更新 checklist.md。');
    return prependUpdateReminder(statusLines.join('\n'));
  }

  // 11. 显示更新预览
  const previewText = formatUpdatePreview(
    module.name,
    currentPercentage,
    newPercentage,
    currentRow?.status || '进行中',
    '进行中',
    parsed.mode,
    updates.map(u => ({ path: u.path, change: u.description }))
  );

  // 12. 询问是否应用（如果没有指定 --apply）
  if (!apply) {
    const confirmed = await askUser(previewText, ['y', 'n', 'Y', 'N']);
    if (confirmed.toLowerCase() !== 'y') {
      return prependUpdateReminder('已取消更新。\n');
    }
  }

  // 13. 应用更新
  for (const update of updates) {
    await writeFile(`${rootDir}/${update.path}`, update.updated);
  }

  // 14. 返回成功信息
  return prependUpdateReminder(formatSuccess('进度已更新!', [
    `模块: ${module.name}`,
    `进度: ${currentPercentage}% -> ${newPercentage}%`,
    `更新时间: ${getCurrentDate()}`
  ]));
}

export default handle;
