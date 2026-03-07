#!/bin/bash
# =============================================================================
# AI 技术学习模板 - CHANGELOG 分类解析器
# =============================================================================
# 用途：解析 CHANGELOG.md 的更新分类标签
# 用法：source .claude/scripts/lib/changelog-parser.sh
# =============================================================================

# CHANGELOG 文件路径
CHANGELOG_FILE="CHANGELOG.md"

# 更新类型颜色定义
CORE_COLOR='\033[0;34m'   # 蓝色
CURRICULUM_COLOR='\033[0;32m'  # 绿色
FIX_COLOR='\033[0;33m'   # 黄色
DOCS_COLOR='\033[0;36m'  # 青色
NC='\033[0m' # No Color

# =============================================================================
# 解析函数
# =============================================================================

# 获取最新版本的所有更新条目
# 返回: 最新版本的原始更新内容
get_latest_version_changes() {
    if [ ! -f "$CHANGELOG_FILE" ]; then
        echo ""
        return 1
    fi

    # 查找第一个版本标记（跳过 [Unreleased]）
    local start_line=$(grep -n "^## \[" "$CHANGELOG_FILE" | grep -v "Unreleased" | head -1 | cut -d: -f1)

    if [ -z "$start_line" ]; then
        echo ""
        return 1
    fi

    # 查找下一个版本标记（确定结束位置）
    local end_line=$(tail -n +$((start_line + 1)) "$CHANGELOG_FILE" | grep -n "^## \[" | head -1 | cut -d: -f1)

    if [ -z "$end_line" ]; then
        # 没有下一个版本，读取到文件末尾
        tail -n +$((start_line + 1)) "$CHANGELOG_FILE"
    else
        # 读取两个版本之间的内容
        head -n $((start_line + end_line - 1)) "$CHANGELOG_FILE" | tail -n +$((start_line + 1))
    fi
}

# 按类型分类更新条目
# 参数: $1 = 更新类型 (Core|Curriculum|Fix|Docs)
# 返回: 该类型的所有更新条目
parse_update_type() {
    local update_type="$1"
    local changes=$(get_latest_version_changes)

    if [ -z "$changes" ]; then
        echo ""
        return 1
    fi

    # 查找对应类型的章节
    echo "$changes" | awk "
        /### \[?$update_type\]?/ { in_section=1; next }
        /^### / && in_section { in_section=0; next }
        in_section && /^- / { print }
        in_section && /^$/ { next }
    "
}

# 获取最新版本号
get_latest_version() {
    if [ ! -f "$CHANGELOG_FILE" ]; then
        echo "unknown"
        return 1
    fi

    grep "^## \[" "$CHANGELOG_FILE" | grep -v "Unreleased" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/'
}

# 获取最新版本日期
get_latest_version_date() {
    if [ ! -f "$CHANGELOG_FILE" ]; then
        echo ""
        return 1
    fi

    grep "^## \[" "$CHANGELOG_FILE" | grep -v "Unreleased" | head -1 | sed 's/.*- \([0-9-]*\)$/\1/'
}

# 检查特定类型是否有更新
# 参数: $1 = 更新类型 (Core|Curriculum|Fix|Docs)
# 返回: 0 = 有更新, 1 = 无更新
has_update_type() {
    local update_type="$1"
    local changes=$(get_latest_version_changes)

    if [ -z "$changes" ]; then
        return 1
    fi

    # 检查是否存在该类型章节
    echo "$changes" | grep -q "### \[?$update_type\]?"
    return $?
}

# 获取所有可用的更新类型
# 返回: 包含更新类型的列表
get_available_update_types() {
    local changes=$(get_latest_version_changes)
    local types=()

    if echo "$changes" | grep -q "### \[?\[Core\]\]?"; then
        types+=("Core")
    fi

    if echo "$changes" | grep -q "### \[?\[Curriculum\]\]?"; then
        types+=("Curriculum")
    fi

    if echo "$changes" | grep -q "### \[?\[Fix\]\]?"; then
        types+=("Fix")
    fi

    if echo "$changes" | grep -q "### \[?\[Docs\]\]?"; then
        types+=("Docs")
    fi

    echo "${types[@]}"
}

# 显示更新分类预览
# 用途: 在同步前显示各类型的更新数量和摘要
show_update_classification_preview() {
    local version=$(get_latest_version)
    local date=$(get_latest_version_date)

    echo ""
    echo "  📋 版本: $version ($date)"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Core 更新
    if has_update_type "Core"; then
        local core_count=$(parse_update_type "Core" | wc -l)
        echo -e "  ${CORE_COLOR}[Core] 框架更新${NC} ($core_count 项) - 建议同步"
        parse_update_type "Core" | head -3 | sed 's/^/    /'
        if [ $core_count -gt 3 ]; then
            echo "    ... (还有 $((core_count - 3)) 项)"
        fi
        echo ""
    fi

    # Curriculum 更新
    if has_update_type "Curriculum"; then
        local curriculum_count=$(parse_update_type "Curriculum" | wc -l)
        echo -e "  ${CURRICULUM_COLOR}[Curriculum] 课程内容${NC} ($curriculum_count 项) - 用户可选"
        parse_update_type "Curriculum" | head -3 | sed 's/^/    /'
        if [ $curriculum_count -gt 3 ]; then
            echo "    ... (还有 $((curriculum_count - 3)) 项)"
        fi
        echo ""
    fi

    # Fix 更新
    if has_update_type "Fix"; then
        local fix_count=$(parse_update_type "Fix" | wc -l)
        echo -e "  ${FIX_COLOR}[Fix] Bug 修复${NC} ($fix_count 项) - 建议同步"
        parse_update_type "Fix" | head -3 | sed 's/^/    /'
        if [ $fix_count -gt 3 ]; then
            echo "    ... (还有 $((fix_count - 3)) 项)"
        fi
        echo ""
    fi

    # Docs 更新
    if has_update_type "Docs"; then
        local docs_count=$(parse_update_type "Docs" | wc -l)
        echo -e "  ${DOCS_COLOR}[Docs] 文档更新${NC} ($docs_count 项) - 可选"
        parse_update_type "Docs" | head -3 | sed 's/^/    /'
        if [ $docs_count -gt 3 ]; then
            echo "    ... (还有 $((docs_count - 3)) 项)"
        fi
        echo ""
    fi

    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# 生成选择性同步建议
# 返回: 基于更新类型的同步建议
generate_sync_suggestion() {
    local has_core=false
    local has_curriculum=false
    local has_fix=false
    local has_docs=false

    has_update_type "Core" && has_core=true
    has_update_type "Curriculum" && has_curriculum=true
    has_update_type "Fix" && has_fix=true
    has_update_type "Docs" && has_docs=true

    if $has_core || $has_fix; then
        echo "建议: 同步核心更新（[Core] + [Fix]）"
    fi

    if $has_curriculum; then
        echo "可选: 同步课程内容（[Curriculum]）"
    fi

    if $has_docs && ! $has_core && ! $has_fix && ! $has_curriculum; then
        echo "建议: 仅文档更新，可选同步"
    fi
}

# =============================================================================
# 同步模式管理
# =============================================================================

# 获取同步模式
get_sync_mode() {
    if [ -f ".claude/update-config.json" ] && command -v jq &> /dev/null; then
        jq -r ".syncMode" ".claude/update-config.json" 2>/dev/null || echo "full"
    else
        echo "full"
    fi
}

# 设置同步模式
set_sync_mode() {
    local mode="$1"
    if [ -f ".claude/update-config.json" ] && command -v jq &> /dev/null; then
        jq ".syncMode = \"$mode\"" ".claude/update-config.json" > ".claude/update-config.json.tmp" && \
        mv ".claude/update-config.json.tmp" ".claude/update-config.json"
    fi
}

# 根据同步模式过滤要同步的文件
# 参数: $1 = 同步模式 (full|core|curriculum)
# 返回: 要同步的文件列表（相对路径）
filter_sync_files_by_mode() {
    local mode="$1"
    local changes=$(get_latest_version_changes)

    case "$mode" in
        core)
            # 只同步核心文件（脚本、配置、SKILL 文件等）
            echo "scripts/"
            echo ".claude/skills/"
            echo ".claude/scripts/"
            echo ".templates/"
            ;;
        curriculum)
            # 只同步课程内容（模块目录）
            echo "01-基础入门/"
            echo "02-进阶探索/"
            echo "03-实战应用/"
            ;;
        full|*)
            # 同步全部
            echo ""
            ;;
    esac
}

# =============================================================================
# 导出函数（供其他脚本使用）
# =============================================================================

export -f get_latest_version_changes
export -f parse_update_type
export -f get_latest_version
export -f get_latest_version_date
export -f has_update_type
export -f get_available_update_types
export -f show_update_classification_preview
export -f generate_sync_suggestion
export -f get_sync_mode
export -f set_sync_mode
export -f filter_sync_files_by_mode
