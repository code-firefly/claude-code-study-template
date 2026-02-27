#!/bin/bash
# =============================================================================
# Claude Code 学习计划 - 备份脚本
# =============================================================================
# 用途：备份个人学习数据到安全位置
# 用法：bash scripts/backup.sh [--output <path>]
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

# 当前日期和时间
NOW=$(date +%Y%m%d-%H%M%S)

# 默认备份目录
DEFAULT_BACKUP_DIR=".backups/backup-$NOW"

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

human_size() {
    local bytes=$1
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes}B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    elif [ "$bytes" -lt 1073741824 ]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# =============================================================================
# 备份函数
# =============================================================================

create_backup() {
    local backup_dir=$1

    print_info "创建备份到: $backup_dir"

    mkdir -p "$backup_dir"

    # 创建备份清单
    local manifest="$backup_dir/manifest.txt"
    echo "# Claude Code 学习计划 - 备份清单" > "$manifest"
    echo "# 备份时间: $(date)" >> "$manifest"
    echo "# 仓库路径: $REPO_ROOT" >> "$manifest"
    echo "" >> "$manifest"

    local total_size=0
    local file_count=0

    # 备份进度文件
    if [ -f "PROGRESS.md" ]; then
        cp "PROGRESS.md" "$backup_dir/"
        local size=$(stat -c%s "PROGRESS.md" 2>/dev/null || stat -f%z "PROGRESS.md" 2>/dev/null || echo "0")
        echo "PROGRESS.md ($size bytes)" >> "$manifest"
        total_size=$((total_size + size))
        file_count=$((file_count + 1))
        print_success "已备份: PROGRESS.md"
    fi

    # 备份书签和缓存
    if [ -f ".claude/LEARNING_BOOKMARKS.md" ]; then
        mkdir -p "$backup_dir/.claude"
        cp ".claude/LEARNING_BOOKMARKS.md" "$backup_dir/.claude/"
        local size=$(stat -c%s ".claude/LEARNING_BOOKMARKS.md" 2>/dev/null || stat -f%z ".claude/LEARNING_BOOKMARKS.md" 2>/dev/null || echo "0")
        echo ".claude/LEARNING_BOOKMARKS.md ($size bytes)" >> "$manifest"
        total_size=$((total_size + size))
        file_count=$((file_count + 1))
        print_success "已备份: LEARNING_BOOKMARKS.md"
    fi

    if [ -f ".claude/KNOWLEDGE_CACHE.md" ]; then
        mkdir -p "$backup_dir/.claude"
        cp ".claude/KNOWLEDGE_CACHE.md" "$backup_dir/.claude/"
        local size=$(stat -c%s ".claude/KNOWLEDGE_CACHE.md" 2>/dev/null || stat -f%z ".claude/KNOWLEDGE_CACHE.md" 2>/dev/null || echo "0")
        echo ".claude/KNOWLEDGE_CACHE.md ($size bytes)" >> "$manifest"
        total_size=$((total_size + size))
        file_count=$((file_count + 1))
        print_success "已备份: KNOWLEDGE_CACHE.md"
    fi

    # 备份模块清单和笔记
    # 使用更兼容的方式处理 find 输出
    local temp_list=$(mktemp)
    find . -name "checklist.md" -not -path "*/.templates/*" -not -path "*/.backups/*" > "$temp_list" 2>/dev/null
    find . -name "notes.md" -not -path "*/.templates/*" -not -path "*/.backups/*" >> "$temp_list" 2>/dev/null

    while IFS= read -r file; do
        [ -z "$file" ] && continue

        # 创建目标目录结构
        local target_dir="$backup_dir/$(dirname "$file")"
        mkdir -p "$target_dir"
        cp "$file" "$target_dir/"

        local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0")
        echo "$file ($size bytes)" >> "$manifest"
        total_size=$((total_size + size))
        file_count=$((file_count + 1))
        print_success "已备份: $file"
    done < "$temp_list"
    rm -f "$temp_list"

    # 备份知识缓存（如果存在）
    local temp_dirs=$(mktemp)
    find . -type d -name "knowledge" -not -path "*/.templates/*" -not -path "*/.backups/*" > "$temp_dirs" 2>/dev/null

    while IFS= read -r dir; do
        [ -z "$dir" ] && continue

        local target_dir="$backup_dir/$(dirname "$dir")"
        mkdir -p "$target_dir"
        cp -r "$dir" "$target_dir/"

        print_success "已备份: $dir"
    done < "$temp_dirs"
    rm -f "$temp_dirs"

    # 添加摘要到清单
    echo "" >> "$manifest"
    echo "=== 备份摘要 ===" >> "$manifest"
    echo "文件数量: $file_count" >> "$manifest"
    echo "总大小: $total_size bytes" >> "$manifest"
    echo "人类可读: $(human_size $total_size)" >> "$manifest"

    print_success "备份完成"
    echo ""
    print_info "备份统计:"
    echo "  文件数量: $file_count"
    echo "  总大小: $(human_size $total_size)"
    echo "  位置: $backup_dir"
}

verify_backup() {
    local backup_dir=$1

    print_info "验证备份完整性..."

    local errors=0

    # 检查关键文件
    if [ ! -f "$backup_dir/PROGRESS.md" ] && [ -f "PROGRESS.md" ]; then
        print_error "PROGRESS.md 未备份"
        errors=$((errors + 1))
    fi

    if [ ! -f "$backup_dir/.claude/LEARNING_BOOKMARKS.md" ] && [ -f ".claude/LEARNING_BOOKMARKS.md" ]; then
        print_warning "LEARNING_BOOKMARKS.md 未备份（可能不存在）"
    fi

    if [ ! -f "$backup_dir/.claude/KNOWLEDGE_CACHE.md" ] && [ -f ".claude/KNOWLEDGE_CACHE.md" ]; then
        print_warning "KNOWLEDGE_CACHE.md 未备份（可能不存在）"
    fi

    # 检查清单文件数量
    local original_count=$(find . -name "checklist.md" -not -path "*/.templates/*" -not -path "*/.backups/*" | wc -l)
    local backup_count=$(find "$backup_dir" -name "checklist.md" | wc -l)

    if [ "$backup_count" -lt "$original_count" ]; then
        print_error "清单文件不完整 ($backup_count/$original_count)"
        errors=$((errors + 1))
    fi

    if [ $errors -eq 0 ]; then
        print_success "备份验证通过"
        return 0
    else
        print_error "备份验证发现 $errors 个问题"
        return 1
    fi
}

# =============================================================================
# 主流程
# =============================================================================

main() {
    local output_path=""

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --output|-o)
                output_path="$2"
                shift 2
                ;;
            -h|--help)
                echo "用法: bash scripts/backup.sh [--output <path>]"
                echo ""
                echo "选项:"
                echo "  --output, -o <path>  指定备份目录路径"
                echo "  -h, --help          显示帮助信息"
                echo ""
                echo "示例:"
                echo "  bash scripts/backup.sh                    # 备份到默认位置"
                echo "  bash scripts/backup.sh -o ~/my-backup     # 备份到指定位置"
                exit 0
                ;;
            *)
                print_error "未知选项: $1"
                echo "使用 --help 查看帮助信息"
                exit 1
                ;;
        esac
    done

    # 确定备份目录
    local backup_dir="${output_path:-$DEFAULT_BACKUP_DIR}"

    print_header "      Claude Code 学习计划 - 数据备份      "

    echo ""

    # 步骤 1：创建备份
    print_header "步骤 1/2: 创建备份 "
    create_backup "$backup_dir"
    echo ""

    # 步骤 2：验证备份
    print_header "步骤 2/2: 验证备份 "
    if verify_backup "$backup_dir"; then
        echo ""
    else
        echo ""
        print_warning "备份可能不完整，请检查"
    fi

    # 完成
    print_header "          备份完成！          "
    echo ""
    print_success "备份已保存到: $backup_dir"
    echo ""
    print_info "恢复方法:"
    echo "  cp -r $backup_dir/* ./"
    echo ""
    print_info "或者恢复特定文件:"
    echo "  cp $backup_dir/PROGRESS.md ./"
    echo ""
}

# 运行主流程
main "$@"
