#!/bin/bash
# =============================================================================
# AI 技术学习模板 - 初始化脚本
# =============================================================================
# 用途：新用户初始化个人学习数据
# 用法：bash scripts/init.sh [--force]
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录的父目录（仓库根目录）
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# 当前日期
TODAY=$(date +%Y-%m-%d)

# =============================================================================
# 辅助函数
# =============================================================================

print_header() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║$1${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
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
# 检查函数
# =============================================================================

check_initialized() {
    if [ -f "PROGRESS.md" ] && [ -f ".claude/LEARNING_BOOKMARKS.md" ]; then
        return 0  # 已初始化
    fi
    return 1  # 未初始化
}

check_templates() {
    if [ ! -d ".templates" ]; then
        print_error "模板目录不存在：.templates/"
        print_info "请确保你从正确的主仓库 Fork"
        exit 1
    fi

    local templates=(
        ".templates/PROGRESS.template.md"
        ".templates/KNOWLEDGE_CACHE.template.md"
        ".templates/LEARNING_BOOKMARKS.template.md"
        ".templates/module/checklist.template.md"
        ".templates/module/notes.template.md"
    )

    for template in "${templates[@]}"; do
        if [ ! -f "$template" ]; then
            print_error "模板文件缺失：$template"
            exit 1
        fi
    done

    print_success "模板文件检查通过"
}

check_gitignore() {
    if ! grep -q "个人学习数据" .gitignore 2>/dev/null; then
        print_warning ".gitignore 可能未配置个人数据忽略规则"
        print_info "建议检查 .gitignore 文件"
        return 1
    fi
    print_success ".gitignore 配置检查通过"
    return 0
}

# =============================================================================
# 初始化函数
# =============================================================================

init_progress_file() {
    print_info "创建 PROGRESS.md..."

    # 替换模板中的日期占位符
    sed "s/{{DATE}}/$TODAY/g" .templates/PROGRESS.template.md > PROGRESS.md

    print_success "PROGRESS.md 已创建"
}

init_cache_file() {
    print_info "创建 KNOWLEDGE_CACHE.md..."

    # 确保 .claude 目录存在
    mkdir -p .claude

    # 替换模板中的日期占位符
    sed "s/{{DATE}}/$TODAY/g" .templates/KNOWLEDGE_CACHE.template.md > .claude/KNOWLEDGE_CACHE.md

    print_success "KNOWLEDGE_CACHE.md 已创建"
}

init_bookmarks_file() {
    print_info "创建 LEARNING_BOOKMARKS.md..."

    # 替换模板中的日期占位符
    sed "s/{{DATE}}/$TODAY/g" .templates/LEARNING_BOOKMARKS.template.md > .claude/LEARNING_BOOKMARKS.md

    print_success "LEARNING_BOOKMARKS.md 已创建"
}

init_module_files() {
    print_info "初始化模块文件..."

    # 查找所有模块目录
    local module_dirs=$(find . -type d \( -name "ai-tools-fundamentals" -o -name "mcp-protocol" -o -name "agent-configuration" -o -name "mcp-advanced-config" -o -name "ai-orchestration" -o -name "ai-resources-research" -o -name "config-management" -o -name "spec-driven-dev" -o -name "practical-projects" \) 2>/dev/null)

    for module_dir in $module_dirs; do
        # 跳过模板目录
        if [[ "$module_dir" == *".templates"* ]]; then
            continue
        fi

        local module_name=$(basename "$module_dir")
        local checklist_path="$module_dir/checklist.md"
        local notes_path="$module_dir/notes.md"

        # 创建 checklist.md
        if [ ! -f "$checklist_path" ]; then
            print_info "  创建 $module_name/checklist.md..."

            # 获取模块优先级（从 README.md 中提取）
            local priority=""
            if [ -f "$module_dir/README.md" ]; then
                priority=$(grep -oP "P[0-3]" "$module_dir/README.md" | head -1)
            fi
            [ -z "$priority" ] && priority="P1"

            # 替换模板占位符
            sed -e "s/{{MODULE_NAME}}/$module_name/g" \
                -e "s/{{PRIORITY}}/$priority/g" \
                -e "s/{{DATE}}/$TODAY/g" \
                -e "s/{{QUICK_MODE_DAYS}}/3/g" \
                -e "s/{{FULL_MODE_DAYS}}/7/g" \
                .templates/module/checklist.template.md > "$checklist_path"
        fi

        # 创建 notes.md
        if [ ! -f "$notes_path" ]; then
            print_info "  创建 $module_name/notes.md..."

            # 替换模板占位符
            sed -e "s/{{MODULE_NAME}}/$module_name/g" \
                -e "s/{{LEARNING_MODE}}/未选择/g" \
                -e "s/{{START_DATE}}/待定/g" \
                .templates/module/notes.template.md > "$notes_path"
        fi
    done

    print_success "模块文件初始化完成"
}

configure_upstream() {
    print_info "检查 upstream 远程仓库..."

    # 检查是否已配置 upstream
    if git remote | grep -q "^upstream$"; then
        print_success "upstream 已配置"
        git remote -v | grep upstream
    else
        print_warning "upstream 未配置"
        print_info "请手动添加 upstream 远程仓库："
        echo ""
        echo "  git remote add upstream https://github.com/YOUR_ORG/YOUR_REPO.git"
        echo ""
        read -p "是否现在配置 upstream? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "请输入 upstream 仓库 URL: " upstream_url
            git remote add upstream "$upstream_url"
            print_success "upstream 已配置"
        fi
    fi
}

verify_gitignore() {
    print_info "验证 .gitignore 配置..."

    # 检查关键文件是否被忽略
    local test_files=("PROGRESS.md" ".claude/LEARNING_BOOKMARKS.md" ".claude/KNOWLEDGE_CACHE.md")
    local all_ignored=true

    for file in "${test_files[@]}"; do
        if git check-ignore -q "$file" 2>/dev/null; then
            print_success "  $file 被正确忽略"
        else
            print_warning "  $file 未被忽略（这可能不是问题）"
            all_ignored=false
        fi
    done

    if $all_ignored; then
        print_success "所有个人数据文件配置正确"
    fi
}

# 新增：交互式启用 .gitignore 保护
configure_gitignore_protection() {
    print_header "步骤 4/6: 配置 .gitignore 保护 "
    echo ""
    print_info "Fork 用户通常希望保护个人学习数据，避免与上游仓库冲突"
    print_info "选择保护级别："
    echo ""
    echo "  1. 🛡️  启用全部保护（推荐）"
    echo "     - 所有个人数据文件不会被 Git 追踪"
    echo "     - 避免同步时被上游覆盖"
    echo "     - 适合 Fork 用户的自定义学习内容"
    echo ""
    echo "  2. 📊 仅保护进度文件"
    echo "     - 仅保护 PROGRESS.md、书签、缓存"
    echo "     - 模块清单和笔记可以被追踪"
    echo "     - 适合希望分享模块进度的用户"
    echo ""
    echo "  3. ⚙️  跳过（手动配置）"
    echo "     - 保持当前 .gitignore 配置"
    echo "     - 手动管理个人数据保护"
    echo ""
    read -p "请选择保护级别 (1/2/3) [默认: 1]: " protection_choice
    protection_choice=${protection_choice:-1}
    echo ""

    case $protection_choice in
        1)
            enable_full_gitignore_protection
            ;;
        2)
            enable_progress_only_protection
            ;;
        3)
            print_info "跳过 .gitignore 保护配置"
            print_info "您可以在 .gitignore 中手动调整配置"
            ;;
        *)
            print_warning "无效选择，跳过保护配置"
            ;;
    esac
    echo ""
}

# 启用全部保护
enable_full_gitignore_protection() {
    print_info "启用全部 .gitignore 保护..."

    local gitignore_file=".gitignore"
    local temp_file="${gitignore_file}.tmp"

    # 使用 sed 取消注释个人数据部分
    sed -e 's/^  # PROGRESS\.md$/  PROGRESS.md/' \
        -e 's/^  # KNOWLEDGE_CACHE\.md$/  KNOWLEDGE_CACHE.md/' \
        -e 's/^  # LEARNING_BOOKMARKS\.md$/  LEARNING_BOOKMARKS.md/' \
        -e 's/^  # \*\*\/checklist\.md$/  **\/checklist.md/' \
        -e 's/^  # \*\*\/notes\.md$/  **\/notes.md/' \
        -e 's/^  # \*\*\/knowledge\/$/  **\/knowledge\//' \
        -e 's/^  # \.claude\/LEARNING_BOOKMARKS\.md$/  .claude\/LEARNING_BOOKMARKS.md/' \
        -e 's/^  # \.claude\/KNOWLEDGE_CACHE\.md$/  .claude\/KNOWLEDGE_CACHE.md/' \
        -e 's/^  # \.claude\/settings\.local\.json$/  .claude\/settings.local.json/' \
        -e 's/^  # personal-notes\/$/  personal-notes\//' \
        "$gitignore_file" > "$temp_file"

    if [ $? -eq 0 ]; then
        mv "$temp_file" "$gitignore_file"
        print_success "已启用全部 .gitignore 保护"
        print_info "以下文件将不会被 Git 追踪："
        echo "  - PROGRESS.md"
        echo "  - LEARNING_BOOKMARKS.md"
        echo "  - KNOWLEDGE_CACHE.md"
        echo "  - **/checklist.md"
        echo "  - **/notes.md"
        echo "  - **/knowledge/"
        echo "  - personal-notes/"
    else
        rm -f "$temp_file"
        print_error "更新 .gitignore 失败"
    fi
}

# 仅保护进度文件
enable_progress_only_protection() {
    print_info "启用进度文件 .gitignore 保护..."

    local gitignore_file=".gitignore"
    local temp_file="${gitignore_file}.tmp"

    # 仅取消注释进度文件部分
    sed -e 's/^  # PROGRESS\.md$/  PROGRESS.md/' \
        -e 's/^  # KNOWLEDGE_CACHE\.md$/  KNOWLEDGE_CACHE.md/' \
        -e 's/^  # LEARNING_BOOKMARKS\.md$/  LEARNING_BOOKMARKS.md/' \
        -e 's/^  # \.claude\/LEARNING_BOOKMARKS\.md$/  .claude\/LEARNING_BOOKMARKS.md/' \
        -e 's/^  # \.claude\/KNOWLEDGE_CACHE\.md$/  .claude\/KNOWLEDGE_CACHE.md/' \
        "$gitignore_file" > "$temp_file"

    if [ $? -eq 0 ]; then
        mv "$temp_file" "$gitignore_file"
        print_success "已启用进度文件 .gitignore 保护"
        print_info "以下文件将不会被 Git 追踪："
        echo "  - PROGRESS.md"
        echo "  - LEARNING_BOOKMARKS.md"
        echo "  - KNOWLEDGE_CACHE.md"
        print_warning "模块清单 (checklist.md) 和笔记 (notes.md) 仍会被追踪"
    else
        rm -f "$temp_file"
        print_error "更新 .gitignore 失败"
    fi
}

# =============================================================================
# 主流程
# =============================================================================

main() {
    local force=false

    # 解析参数
    for arg in "$@"; do
        case $arg in
            --force)
                force=true
                shift
                ;;
            -h|--help)
                echo "用法: bash scripts/init.sh [--force]"
                echo ""
                echo "选项:"
                echo "  --force    强制重新初始化（覆盖现有文件）"
                echo "  -h, --help 显示帮助信息"
                exit 0
                ;;
        esac
    done

    print_header "      AI 技术学习模板 - 初始化向导      "

    # 检查是否已初始化
    if check_initialized && [ "$force" = false ]; then
        print_warning "检测到已初始化的学习数据"
        echo ""
        read -p "是否重新初始化？这将覆盖现有文件。(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "初始化已取消"
            exit 0
        fi
    fi

    echo ""

    # 步骤 1：检查模板文件
    print_header "步骤 1/6: 检查模板文件 "
    check_templates
    echo ""

    # 步骤 2：创建进度文件
    print_header "步骤 2/6: 创建进度文件 "
    init_progress_file
    echo ""

    # 步骤 3：创建书签和缓存文件
    print_header "步骤 3/6: 创建书签和缓存文件 "
    init_cache_file
    init_bookmarks_file
    echo ""

    # 步骤 4：初始化模块文件
    print_header "步骤 4/6: 初始化模块文件 "
    init_module_files
    echo ""

    # 步骤 5：配置 .gitignore 保护
    configure_gitignore_protection

    # 步骤 6：配置 upstream 和验证
    print_header "步骤 6/6: 配置与验证 "
    configure_upstream
    verify_gitignore
    echo ""

    # 完成
    print_header "          初始化完成！          "
    echo ""
    print_success "所有文件已创建，可以开始学习了！"
    echo ""
    print_info "下一步："
    echo "  1. 对 Claude 说：'查看学习状态'"
    echo "  2. 对 Claude 说：'开始学习 ai-tools-fundamentals'"
    echo "  3. 选择学习模式（快速/完整）"
    echo ""
    print_info "更多信息请查看："
    echo "  - README.md（快速开始指南）"
    echo "  - TEMPLATE_GUIDE.md（模板使用指南）"
    echo ""

    # 迁移提示（针对 v1.x 用户）
    echo ""
    print_warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_warning "  如果你是从 v1.x 版本升级的用户"
    print_warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_warning ""
    print_warning "  检测到你可能在使用旧的模块名称。"
    print_warning "  建议运行迁移脚本更新模块名称："
    print_warning ""
    print_warning "    bash scripts/migrate-v2.sh --dry-run  # 预览"
    print_warning "    bash scripts/migrate-v2.sh --backup  # 执行迁移"
    print_warning ""
    print_warning "  迁移后旧名称仍可使用（通过别名映射）"
    print_warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# 运行主流程
main "$@"
