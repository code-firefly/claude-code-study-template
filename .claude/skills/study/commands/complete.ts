/**
 * /study complete 命令处理器
 * 完成学习模块
 */

import { findModule, searchModule } from '../lib/module-locator.js';
import { parseChecklist, calculateProgress, getIncompleteItems } from '../lib/progress-parser.js';
import { generateCompleteUpdates, getCurrentDate } from '../lib/file-updater.js';
import { formatCompleteConfirmation, formatError, formatSuccess, formatModuleSuggestions, formatWarning } from '../lib/ui-formatter.js';
import { checkForUpdates, formatUpdateReminder } from '../lib/update-checker.js';

/**
 * 处理 /study complete 命令
 */
export async function handle(args: { module: string; force?: boolean }, context: {
  rootDir: string;
  readFile: (path: string) => Promise<string>;
  writeFile: (path: string, content: string) => Promise<void>;
  askUser: (question: string, options?: string[]) => Promise<string>;
}): Promise<string> {
  const { module: moduleInput, force = false } = args;
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
  let notesContent: string;
  let progressContent: string;

  try {
    checklistContent = await readFile(`${rootDir}/${module.checklistPath}`);
    notesContent = await readFile(`${rootDir}/${module.notesPath}`);
    progressContent = await readFile(`${rootDir}/PROGRESS.md`);
  } catch (error) {
    return prependUpdateReminder(formatError('无法读取模块文件', [
      `模块路径: ${module.path}`,
      '请确保模块目录结构完整'
    ]));
  }

  // 3. 解析当前进度
  const parsed = parseChecklist(checklistContent);
  const percentage = calculateProgress(parsed);

  // 4. 如果未选择模式，提示错误
  if (parsed.mode === null) {
    return prependUpdateReminder(formatError('该模块尚未开始学习', [
      '请先使用 /study start ' + module.name + ' 开始学习'
    ]));
  }

  // 5. 获取未完成项
  const incompleteItems = getIncompleteItems(parsed);

  // 6. 显示完成确认信息
  const confirmation = formatCompleteConfirmation(module, percentage, incompleteItems);

  // 7. 如果有未完成项且未使用 --force，询问确认
  if (percentage < 100 && !force) {
    const choice = await askUser(confirmation + '\n\n是否仍要完成? (y/n):', ['y', 'n', 'Y', 'N']);
    if (choice.toLowerCase() !== 'y') {
      return prependUpdateReminder('已取消完成学习。\n');
    }
  } else if (percentage === 100) {
    const choice = await askUser(confirmation + '\n\n确认完成学习? (y/n):', ['y', 'n', 'Y', 'N']);
    if (choice.toLowerCase() !== 'y') {
      return prependUpdateReminder('已取消完成学习。\n');
    }
  } else {
    // 使用 --force 强制完成
    const choice = await askUser(confirmation + '\n\n确认强制完成? (y/n):', ['y', 'n', 'Y', 'N']);
    if (choice.toLowerCase() !== 'y') {
      return prependUpdateReminder('已取消完成学习。\n');
    }
  }

  // 8. 生成并应用更新
  const { updates, warnings } = generateCompleteUpdates(
    module,
    checklistContent,
    notesContent,
    progressContent,
    force
  );

  // 应用所有更新
  for (const update of updates) {
    await writeFile(`${rootDir}/${update.path}`, update.updated);
  }

  // 9. 生成成功信息
  const modeText = parsed.mode === 'quick' ? '快速模式' : '完整模式';
  const completionNotes = percentage < 100 ? ` (完成度 ${percentage}%)` : '';

  const successLines = [
    '',
    '🎉 恭喜完成学习!',
    '',
    `模块: ${module.name}`,
    `模式: ${modeText}`,
    `完成日期: ${getCurrentDate()}${completionNotes}`,
    ''
  ];

  if (warnings.length > 0) {
    successLines.push('注意:');
    for (const warning of warnings) {
      successLines.push(`  - ${warning}`);
    }
    successLines.push('');
  }

  successLines.push('下一步:');
  successLines.push('1. 查阅学习笔记 notes.md');
  successLines.push('2. 继续下一个模块的学习');
  successLines.push('3. 使用 /study status 查看整体进度');
  successLines.push('');

  return prependUpdateReminder(successLines.join('\n'));
}

export default handle;
