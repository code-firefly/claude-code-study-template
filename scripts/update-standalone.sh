#!/bin/bash
# =============================================================================
# AI 技术学习模板 - 独立更新脚本（Clone 模式专用）
# =============================================================================
# 用途：Clone 模式用户更新模板
# 用法：bash scripts/update-standalone.sh [--check] [--dry-run]
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

# 模板仓库 URL
TEMPLATE_REPO="https://github.com/code-firefly/claude-code-study-template"
TEMP_DIR=".temp-update"

# 个人数据文件（不会被覆盖）
PERSONAL_FILES=(
    "PROGRESS.md"
    ".claude/LEARNING_BOOKMARKS.md"
    ".claude/KNOWLEDGE_CACHE.md"
)

# 个人数据目录模式（不会被覆盖）
PERSONAL_PATTERNS=(
    "*/checklist.md"
    "*/notes.md"
    "*/knowledge/*"
)

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
# 检测函数
# =============================================================================

# 检测是否为 Clone 模式
is_clone_mode() {
    if git remote | grep -q "^upstream$"; then
        return 1  # Fork 模式（有 upstream）
    fi
    return 0  # Clone 模式（无 upstream）
}

# 从 CHANGELOG.md 提取版本号
extract_version() {
    local changelog=$1
    if [ -f "$changelog" ]; then
        grep -m1 "^## \[" "$changelog" | sed 's/## \[\(.*\)\].*/\1/'
    else
        echo "unknown"
    fi
}

# 获取当前版本
get_current_version() {
    extract_version "$REPO_ROOT/CHANGELOG.md"
}

# 获取远程版本
get_remote_version() {
    local temp_changelog="$TEMP_DIR/CHANGELOG.md"
    if [ -f "$temp_changelog" ]; then
        extract_version "$temp_changelog"
    else
        echo "unknown"
    fi
}

# 比较版本号
compare_versions() {
    local v1=$1
    local v2=$2

    if [ "$v1" = "unknown" ] || [ "$v2" = "unknown" ]; then
        echo "unknown"
        return
    fi

    local IFS='.'
    read -ra v1_parts <<< "$v1"
    read -ra v2_parts <<< "$v2"

    for i in "${!v1_parts[@]}"; do
        local n1=${v1_parts[i]:-0}
        local n2=${v2_parts[i]:-0}
        if [ "$n1" -gt "$n2" ]; then
            echo "newer"
            return
        elif [ "$n1" -lt "$n2" ]; then
            echo "older"
            return
        fi
    done
    echo "same"
}

# 检查是否为个人数据文件
is_personal_file() {
    local file=$1

    # 检查精确匹配
    for pattern in "${PERSONAL_FILES[@]}"; do
        if [ "$file" = "$pattern" ]; then
            return 0
        fi
    done

    # 检查模式匹配
    for pattern in "${PERSONAL_PATTERNS[@]}"; do
        case "$file" in
            $pattern) return 0 ;;
        esac
    done

    return 1
}

# =============================================================================
# 备份函数
# =============================================================================

backup_personal_data() {
    local backup_dir=".backups/update-standalone-$TODAY"
    print_info "备份个人数据到: $backup_dir"
    mkdir -p "$backup_dir"

    for file in "${PERSONAL_FILES[@]}"; do
        if [ -f "$file" ]; then
            mkdir -p "$backup_dir/$(dirname "$file")"
            cp "$file" "$backup_dir/$file"
            print_success "已备份: $file"
        fi
    done

    # 备份模块文件
    for stage in "01-基础入门" "02-进阶探索" "03-实战应用"; do
        if [ -d "$stage" ]; then
            for module_dir in "$stage"/*/; do
                if [ -d "$module_dir" ]; then
                    for file in "checklist.md" "notes.md"; do
                        if [ -f "$module_dir$file" ]; then
                            rel_path="${module_dir#$REPO_ROOT/}$file"
                            mkdir -p "$backup_dir/$(dirname "$rel_path")"
                            cp "$module_dir$file" "$backup_dir/$rel_path"
                            print_success "已备份: $rel_path"
                        fi
                    done
                fi
            done
        fi
    done

    print_success "备份完成"
    echo ""
}

# =============================================================================
# 下载函数
# =============================================================================

download_template() {
    print_info "下载最新模板..."

    # 清理旧的临时目录
    rm -rf "$TEMP_DIR"

    # 浅克隆模板仓库
    if git clone --depth 1 "$TEMPLATE_REPO" "$TEMP_DIR" 2>/dev/null; then
        print_success "模板下载完成"
        return 0
    else
        print_error "模板下载失败，请检查网络连接"
        return 1
    fi
}

cleanup_temp() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        print_info "清理临时文件"
    fi
}

# =============================================================================
# 合并函数
# =============================================================================

merge_updates() {
    local dry_run=$1
    local updated_files=()
    local skipped_files=()

    print_info "合并更新..."

    # 使用 rsync 或 cp 复制文件
    if command -v rsync &> /dev/null; then
        # 使用 rsync（排除个人数据）
        rsync -av --delete \
            --exclude 'PROGRESS.md' \
            --exclude '.claude/LEARNING_BOOKMARKS.md' \
            --exclude '.claude/KNOWLEDGE_CACHE.md' \
            --exclude '*/checklist.md' \
            --exclude '*/notes.md' \
            --exclude '*/knowledge/*' \
            --exclude '.git/' \
            --exclude '.temp-update/' \
            --exclude '.backups/' \
            "$TEMP_DIR/" "$REPO_ROOT/" 2>/dev/null

        # 收集更新的文件
        while IFS= read -r file; do
            if is_personal_file "$file"; then
                skipped_files+=("$file")
            else
                updated_files+=("$file")
            fi
        done < <(cd "$TEMP_DIR" && find . -type f ! -path './.git/*' | sed 's|^\./||')
    else
        # 手动复制（不使用 rsync）
        print_warning "rsync 不可用，使用手动复制"

        # 复制关键目录
        for dir in "scripts" ".templates" ".claude/skills"; do
            if [ -d "$TEMP_DIR/$dir" ]; then
                rm -rf "$REPO_ROOT/$dir"
                cp -r "$TEMP_DIR/$dir" "$REPO_ROOT/$dir"
                updated_files+=("$dir/")
            fi
        done

        # 复制关键文件
        for file in "README.md" "CLAUDE.md" "TEMPLATE_GUIDE.md" "CHANGELOG.md" ".gitignore"; do
            if [ -f "$TEMP_DIR/$file" ] && ! is_personal_file "$file"; then
                cp "$TEMP_DIR/$file" "$REPO_ROOT/$file"
                updated_files+=("$file")
            fi
        done

        # 复制阶段目录（排除模块的 checklist.md 和 notes.md）
        for stage in "01-基础入门" "02-进阶探索" "03-实战应用"; do
            if [ -d "$TEMP_DIR/$stage" ]; then
                for module_dir in "$TEMP_DIR/$stage"/*/; do
                    if [ -d "$module_dir" ]; then
                        module_name=$(basename "$module_dir")
                        target_dir="$REPO_ROOT/$stage/$module_name"

                        # 复制 README.md
                        if [ -f "$module_dir/README.md" ]; then
                            mkdir -p "$target_dir"
                            cp "$module_dir/README.md" "$target_dir/"
                            updated_files+=("$stage/$module_name/README.md")
                        fi
                    fi
                done
            fi
        done

        skipped_files=("PROGRESS.md" "*/checklist.md" "*/notes.md" "*/knowledge/*")
    fi

    echo ""
    print_success "更新合并完成"
    echo ""

    # 显示更新摘要
    if [ ${#updated_files[@]} -gt 0 ]; then
        print_info "已更新的文件/目录:"
        for file in "${updated_files[@]}"; do
            echo "  ✓ $file"
        done
    fi

    echo ""
    if [ ${#skipped_files[@]} -gt 0 ]; then
        print_info "已跳过的个人数据文件:"
        for file in "${skipped_files[@]}"; do
            echo "  ⊙ $file"
        done
    fi
}

# =============================================================================
# 检查更新
# =============================================================================

check_updates() {
    print_header "       独立更新检查（Clone 模式）       "
    echo ""

    # 检测模式
    if ! is_clone_mode; then
        print_warning "检测到 Fork 模式（已配置 upstream）"
        print_info "Fork 模式建议使用: bash scripts/sync.sh"
        echo ""
        read -p "是否继续使用独立更新？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    # 下载模板检查版本
    if ! download_template; then
        cleanup_temp
        exit 1
    fi

    local current_version=$(get_current_version)
    local remote_version=$(get_remote_version)

    echo ""
    print_info "当前版本: $current_version"
    print_info "最新版本: $remote_version"
    echo ""

    local comparison=$(compare_versions "$current_version" "$remote_version")

    case "$comparison" in
        "older")
            print_warning "发现新版本可用！"
            echo ""
            print_info "运行 'bash scripts/update-standalone.sh' 执行更新"
            ;;
        "newer"|"same")
            print_success "已是最新版本"
            ;;
        *)
            print_warning "无法比较版本，建议手动检查更新"
            ;;
    esac

    cleanup_temp
}

# =============================================================================
# 主流程
# =============================================================================

main() {
    local check_only=false
    local dry_run=false

    # 解析参数
    for arg in "$@"; do
        case $arg in
            --check|-c)
                check_only=true
                shift
                ;;
            --dry-run|-d)
                dry_run=true
                shift
                ;;
            -h|--help)
                echo "用法: bash scripts/update-standalone.sh [选项]"
                echo ""
                echo "选项:"
                echo "  --check, -c    仅检查更新（不执行更新）"
                echo "  --dry-run, -d  预览更新（不实际修改文件）"
                echo "  -h, --help     显示帮助信息"
                echo ""
                echo "说明:"
                echo "  此脚本用于 Clone 模式用户更新模板。"
                echo "  Fork 模式用户建议使用 scripts/sync.sh"
                exit 0
                ;;
        esac
    done

    # 检查模式
    if [ "$check_only" = true ]; then
        check_updates
        exit 0
    fi

    print_header "       独立更新（Clone 模式）       "
    echo ""

    # 检测模式
    if ! is_clone_mode; then
        print_warning "检测到 Fork 模式（已配置 upstream）"
        print_info "Fork 模式建议使用: bash scripts/sync.sh"
        echo ""
        read -p "是否继续使用独立更新？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    # 下载模板
    if ! download_template; then
        exit 1
    fi

    # 检查版本
    local current_version=$(get_current_version)
    local remote_version=$(get_remote_version)

    echo ""
    print_info "当前版本: $current_version"
    print_info "最新版本: $remote_version"
    echo ""

    local comparison=$(compare_versions "$current_version" "$remote_version")

    if [ "$comparison" = "same" ]; then
        print_success "已是最新版本，无需更新"
        cleanup_temp
        exit 0
    elif [ "$comparison" = "older" ]; then
        print_warning "发现新版本: $remote_version"
    fi

    # 显示更新预览
    if [ -f "$TEMP_DIR/CHANGELOG.md" ]; then
        echo ""
        print_info "最新变更日志:"
        echo "────────────────────────────────────────"
        head -30 "$TEMP_DIR/CHANGELOG.md"
        echo "────────────────────────────────────────"
    fi

    echo ""
    print_warning "更新将覆盖系统文件，但保留个人数据"
    echo ""
    read -p "确认执行更新？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "更新已取消"
        cleanup_temp
        exit 0
    fi

    # 备份
    backup_personal_data

    # 合并更新
    if [ "$dry_run" = true ]; then
        print_info "[预览模式] 将执行以下更新:"
        merge_updates true
    else
        merge_updates false
    fi

    # 清理
    cleanup_temp

    # 完成
    echo ""
    print_header "          更新完成！          "
    echo ""
    print_success "模板已更新到版本: $remote_version"
    echo ""
    print_info "后续操作:"
    echo "  1. 使用 '查看学习状态' 验证更新结果"
    echo "  2. 检查备份目录: .backups/update-standalone-$TODAY/"
    echo ""
}

# 运行主流程
main "$@"
