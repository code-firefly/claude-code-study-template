#!/bin/bash
# =============================================================================
# Claude Code 学习计划 - 同步脚本
# =============================================================================
# 用途：同步上游更新到本地仓库
# 用法：bash scripts/sync.sh [--no-backup]
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取脚本所在目录的父目录（仓库根目录）
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# 当前日期
TODAY=$(date +%Y%m%d)

# =============================================================================
# 辅助函数
# =============================================================================

print_header() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║$1${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# =============================================================================
# 自定义模块检测
# =============================================================================

detect_custom_modules() {
    local custom_modules=()

    # 扫描所有模块目录查找 .custom 标记
    for module_dir in */*/*; do
        if [ -d "$module_dir" ] && [ -f "$module_dir/.custom" ]; then
            custom_modules+=("$module_dir")
        fi
    done

    echo "${custom_modules[@]}"
}

show_custom_module_warning() {
    local custom_modules=($1)

    if [ ${#custom_modules[@]} -gt 0 ]; then
        print_warning "发现 ${#custom_modules[@]} 个自定义模块："
        echo ""
        for module in "${custom_modules[@]}"; do
            local custom_file="$module/.custom"
            local custom_date=$(grep "自定义日期" "$custom_file" 2>/dev/null | sed 's/.*：//' || echo "未知")
            local custom_files=$(grep "自定义文件" "$custom_file" 2>/dev/null | sed 's/.*：//' || echo "未知")
            echo "  📝 $module"
            echo "     自定义日期: $custom_date"
            echo "     自定义文件: $custom_files"
        done
        echo ""
        print_warning "这些模块在同步时将被跳过，以避免覆盖您的自定义内容"
        echo ""
        read -p "是否继续同步？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "同步已取消"
            exit 0
        fi
    fi
}

# =============================================================================
# 检查函数
# =============================================================================

check_upstream() {
    if ! git remote | grep -q "^upstream$"; then
        print_error "upstream 远程仓库未配置"
        print_info "请先配置 upstream："
        echo ""
        echo "  git remote add upstream https://github.com/YOUR_ORG/YOUR_REPO.git"
        echo ""
        exit 1
    fi
    print_success "upstream 已配置"
}

check_clean_state() {
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "工作目录有未提交的更改"
        print_info "个人数据文件会被忽略，但建议先提交或暂存其他更改"
        echo ""
        git status --short
        echo ""
        read -p "是否继续同步？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "同步已取消"
            exit 0
        fi
    fi
}

get_current_version() {
    # 从 CHANGELOG.md 提取最新版本（跳过 [Unreleased]）
    if [ -f "CHANGELOG.md" ]; then
        grep "^## \[" CHANGELOG.md | grep -v "Unreleased" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/'
    else
        echo "unknown"
    fi
}

get_upstream_version() {
    # 从 upstream 的 CHANGELOG.md 提取最新版本（跳过 [Unreleased]）
    git show upstream/main:CHANGELOG.md 2>/dev/null | grep "^## \[" | grep -v "Unreleased" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/' || echo "unknown"
}

# =============================================================================
# 备份函数
# =============================================================================

backup_personal_data() {
    local backup_dir=".backups/sync-$TODAY"

    print_info "备份个人学习数据..."

    mkdir -p "$backup_dir"

    # 备份进度文件
    [ -f "PROGRESS.md" ] && cp "PROGRESS.md" "$backup_dir/"

    # 备份书签和缓存
    [ -f ".claude/LEARNING_BOOKMARKS.md" ] && cp ".claude/LEARNING_BOOKMARKS.md" "$backup_dir/"
    [ -f ".claude/KNOWLEDGE_CACHE.md" ] && cp ".claude/KNOWLEDGE_CACHE.md" "$backup_dir/"

    # 备份模块清单和笔记
    find . -name "checklist.md" -not -path "*/.templates/*" -not -path "*/.backups/*" -exec cp --parents {} "$backup_dir/" \;
    find . -name "notes.md" -not -path "*/.templates/*" -not -path "*/.backups/*" -exec cp --parents {} "$backup_dir/" \;

    print_success "备份已创建: $backup_dir"
}

# =============================================================================
# 同步函数
# =============================================================================

fetch_upstream() {
    print_info "从 upstream 获取更新..."

    if git fetch upstream 2>&1 | grep -q "fatal"; then
        print_error "获取 upstream 更新失败"
        print_info "请检查网络连接和 upstream 配置"
        exit 1
    fi

    print_success "已获取上游更新"
}

show_changelog() {
    print_info "检查版本更新..."

    local current_version=$(get_current_version)
    local upstream_version=$(get_upstream_version)

    echo ""
    echo "  当前版本: $current_version"
    echo "  上游版本: $upstream_version"
    echo ""

    if [ "$current_version" != "$upstream_version" ] && [ "$upstream_version" != "unknown" ]; then
        print_warning "发现新版本: $upstream_version"

        # 显示变更日志
        if [ -f "CHANGELOG.md" ]; then
            echo ""
            print_info "变更摘要："
            # 这里可以添加更复杂的日志解析逻辑
            echo "  请查看 CHANGELOG.md 了解详细变更"
        fi
    else
        print_success "已是最新版本"
    fi
}

merge_upstream() {
    print_info "合并 upstream 更新..."

    local current_branch=$(git branch --show-current)

    # 确保在 main 分支
    if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
        print_warning "当前不在 main/master 分支"
        read -p "是否切换到 main 分支继续？(y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git checkout main
        else
            print_error "请切换到 main 分支后再运行此脚本"
            exit 1
        fi
    fi

    # 执行合并
    if git merge --ff-only upstream/main 2>/dev/null; then
        print_success "快进合并成功"
    elif git merge upstream/main 2>&1; then
        print_success "合并成功"
    else
        print_warning "合并出现冲突"
        print_info "个人数据文件应被 .gitignore 保护，不会被影响"
        echo ""
        print_info "解决冲突步骤："
        echo "  1. 查看冲突文件: git status"
        echo "  2. 编辑冲突文件，保留需要的内容"
        echo "  3. 标记为已解决: git add <文件>"
        echo "  4. 完成合并: git commit"
        echo ""
        print_info "提示：系统文件冲突建议保留 upstream 版本"
        exit 1
    fi
}

verify_personal_data() {
    print_info "验证个人数据完整性..."

    local all_good=true

    # 检查关键文件
    [ -f "PROGRESS.md" ] || { print_error "PROGRESS.md 缺失"; all_good=false; }
    [ -f ".claude/LEARNING_BOOKMARKS.md" ] || { print_warning "书签文件缺失"; }
    [ -f ".claude/KNOWLEDGE_CACHE.md" ] || { print_warning "缓存文件缺失"; }

    # 检查模块文件数量
    local checklist_count=$(find . -name "checklist.md" -not -path "*/.templates/*" -not -path "*/.backups/*" | wc -l)
    if [ "$checklist_count" -lt 8 ]; then
        print_warning "模块清单文件可能不完整 ($checklist_count/8)"
    fi

    if $all_good; then
        print_success "个人数据验证通过"
    fi
}

# =============================================================================
# 主流程
# =============================================================================

main() {
    local do_backup=true

    # 解析参数
    for arg in "$@"; do
        case $arg in
            --no-backup)
                do_backup=false
                shift
                ;;
            -h|--help)
                echo "用法: bash scripts/sync.sh [--no-backup]"
                echo ""
                echo "选项:"
                echo "  --no-backup  跳过备份步骤"
                echo "  -h, --help   显示帮助信息"
                exit 0
                ;;
        esac
    done

    print_header "      Claude Code 学习计划 - 同步向导      "

    echo ""

    # 步骤 1：检查 upstream
    print_header "步骤 1/6: 检查 upstream 配置 "
    check_upstream
    echo ""

    # 步骤 2：检查工作目录状态
    print_header "步骤 2/6: 检查工作目录状态 "
    check_clean_state
    echo ""

    # 步骤 3：备份个人数据
    if $do_backup; then
        print_header "步骤 3/6: 备份个人数据 "
        backup_personal_data
        echo ""
    fi

    # 步骤 4：检测自定义模块
    print_header "步骤 4/6: 检测自定义模块 "
    local custom_modules=$(detect_custom_modules)
    show_custom_module_warning "$custom_modules"
    echo ""

    # 步骤 5：获取并显示更新
    print_header "步骤 5/6: 获取上游更新 "
    fetch_upstream
    show_changelog
    echo ""

    # 步骤 6：合并更新
    print_header "步骤 6/6: 合并上游更新 "
    read -p "是否继续合并更新？(Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        merge_upstream
        verify_personal_data
    else
        print_info "合并已跳过"
        exit 0
    fi
    echo ""

    # 完成
    print_header "          同步完成！          "
    echo ""
    print_success "仓库已与 upstream 同步"
    echo ""
    print_info "下一步："
    echo "  - 查看 CHANGELOG.md 了解详细变更"
    echo "  - 如需迁移，运行: bash scripts/migrate.sh"
    echo "  - 推送到你的仓库: git push origin $(git branch --show-current)"
    echo ""
}

# 运行主流程
main "$@"
