/**
 * /study start 命令处理器
 * 开始学习一个模块
 */

import { findModule, searchModule } from '../lib/module-locator.js';
import { parseChecklist } from '../lib/progress-parser.js';
import { generateStartUpdates, generateUpdatePreviewText, getCurrentDate } from '../lib/file-updater.js';
import { formatStartConfirmation, formatError, formatSuccess, formatModuleSuggestions, formatWarning } from '../lib/ui-formatter.js';
import { checkForUpdates, formatUpdateReminder } from '../lib/update-checker.js';

/**
 * 处理 /study start 命令
 */
export async function handle(args: { module: string }, context: {
  rootDir: string;
  readFile: (path: string) => Promise<string>;
  writeFile: (path: string, content: string) => Promise<void>;
  askUser: (question: string, options?: string[]) => Promise<string>;
}): Promise<string> {
  const { module: moduleInput } = args;
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

  // 2. 如果是模糊匹配，询问用户确认
  if (!searchResult.exact && searchResult.partial.length > 0) {
    const suggestions = searchResult.partial.slice(0, 3).map(m => m.name);
    if (searchResult.partial.length > 1) {
      // 多个匹配，让用户选择
      const prompt = `找到多个匹配的模块，请选择:\n${suggestions.map((s, i) => `${i + 1}. ${s}`).join('\n')}\n请输入编号 (1-${suggestions.length}):`;
      const choice = await askUser(prompt);
      const index = parseInt(choice, 10) - 1;
      if (index >= 0 && index < searchResult.partial.length) {
        // 继续使用选中的模块
      } else {
        return prependUpdateReminder(formatError('无效的选择'));
      }
    }
  }

  // 3. 读取相关文件
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

  // 4. 检查是否已经开始学习
  const parsed = parseChecklist(checklistContent);
  if (parsed.mode !== null) {
    const modeText = parsed.mode === 'quick' ? '快速模式' : '完整模式';
    return prependUpdateReminder(formatWarning('该模块已经开始学习', [
      `当前学习模式: ${modeText}`,
      '如需重新开始，请先手动重置 checklist.md'
    ]));
  }

  // 5. 询问用户选择学习模式
  const modeChoice = await askUser(
    `请选择学习模式:\n1. 📚 快速模式 (约 3 天) - 理论为主\n2. 🛠️ 完整模式 (约 1 周) - 理论+实践\n请输入 1 或 2:`,
    ['1', '2']
  );

  const mode = modeChoice === '1' ? 'quick' : 'complete';

  // 6. 显示确认信息
  const confirmation = formatStartConfirmation(module, mode);
  const confirmed = await askUser(confirmation, ['y', 'n', 'Y', 'N']);

  if (confirmed.toLowerCase() !== 'y') {
    return prependUpdateReminder('已取消开始学习。\n');
  }

  // 7. 生成并应用更新
  const updates = generateStartUpdates(
    module,
    mode,
    checklistContent,
    notesContent,
    progressContent
  );

  // 应用所有更新
  for (const update of updates) {
    await writeFile(`${rootDir}/${update.path}`, update.updated);
  }

  // 8. 返回成功信息
  const modeText = mode === 'quick' ? '快速模式' : '完整模式';
  return prependUpdateReminder(formatSuccess('开始学习!', [
    `模块: ${module.name}`,
    `模式: ${modeText}`,
    `开始日期: ${getCurrentDate()}`,
    '',
    '下一步:',
    '1. 阅读 README.md 了解模块内容',
    '2. 按照 checklist.md 逐步完成学习',
    '3. 使用 /study update 更新进度'
  ]));
}

export default handle;
