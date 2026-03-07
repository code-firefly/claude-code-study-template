#!/bin/bash
# =============================================================================
# AI 技术学习模板 - 配置管理工具
# =============================================================================
# 用途：管理 update-config.json 配置文件
# 用法：source .claude/scripts/lib/config-manager.sh
# =============================================================================

# 配置文件路径
CONFIG_FILE=".claude/update-config.json"
CONFIG_VERSION="1.0.0"

# 默认配置
DEFAULT_CONFIG=$(cat <<EOF
{
  "version": "$CONFIG_VERSION",
  "autoCheck": {
    "enabled": true,
    "intervalHours": 24,
    "lastCheck": null,
    "cachedUpstreamVersion": null
  },
  "syncMode": "full"
}
EOF
)

# =============================================================================
# 辅助函数
# =============================================================================

# 检查 jq 是否可用
check_jq() {
    if ! command -v jq &> /dev/null; then
        return 1
    fi
    return 0
}

# 获取当前时间（ISO 8601 UTC 格式）
get_current_time() {
    # 使用 date 命令生成 UTC 时间
    if date +%s 2>/dev/null | grep -q ^[0-9]; then
        # GNU date
        date -u +"%Y-%m-%dT%H:%M:%SZ"
    else
        # BSD date (macOS)
        date -u +"%Y-%m-%dT%H:%M:%SZ"
    fi
}

# 将时间字符串转换为时间戳
date_to_timestamp() {
    local date_str="$1"
    if [ "$date_str" = "null" ] || [ -z "$date_str" ]; then
        echo 0
        return
    fi

    # 移除可能的 'Z' 后缀和 'T' 分隔符
    local clean_date="${date_str//Z/}"
    clean_date="${clean_date//T/ }"
    clean_date="${clean_date//\-/ }"
    clean_date="${clean_date//:/ }"

    # 尝试 GNU date
    if timestamp=$(date -d "$date_str" +%s 2>/dev/null); then
        echo "$timestamp"
        return
    fi

    # 尝试 BSD date (macOS)
    if timestamp=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$date_str" +%s 2>/dev/null); then
        echo "$timestamp"
        return
    fi

    # 失败时返回 0
    echo 0
}

# =============================================================================
# 配置文件操作
# =============================================================================

# 初始化配置文件（如不存在）
init_config_if_missing() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
        return 0
    fi

    # 验证配置文件是否有效 JSON
    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        # 配置文件损坏，重建默认配置
        local backup_file="${CONFIG_FILE}.corrupted.$(date +%s)"
        mv "$CONFIG_FILE" "$backup_file"
        echo "$DEFAULT_CONFIG" > "$CONFIG_FILE"
        return 1
    fi

    return 0
}

# 获取配置值
# 用法: get_config_value "autoCheck.enabled"
get_config_value() {
    local key="$1"

    if ! check_jq; then
        echo "null"
        return 1
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        init_config_if_missing
    fi

    jq -r ".$key" "$CONFIG_FILE" 2>/dev/null || echo "null"
}

# 设置配置值
# 用法: set_config_value "autoCheck.enabled" "true"
set_config_value() {
    local key="$1"
    local value="$2"

    if ! check_jq; then
        return 1
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        init_config_if_missing
    fi

    # 判断值的类型
    if [ "$value" = "true" ] || [ "$value" = "false" ]; then
        # 布尔值
        jq ".$key = $value" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    elif [ "$value" = "null" ]; then
        # null 值
        jq ".$key = null" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    elif echo "$value" | grep -qE '^\[.*\]$'; then
        # 数组值（需要保留引号）
        jq ".$key = $value" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    elif echo "$value" | grep -qE '^{.*}$'; then
        # 对象值（需要保留引号）
        jq ".$key = $value" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    elif echo "$value" | grep -qE '^[0-9]+$'; then
        # 数字值
        jq ".$key = $value" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    else
        # 字符串值（需要加引号）
        jq ".$key = \"$value\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    fi
}

# =============================================================================
# 更新检查缓存逻辑
# =============================================================================

# 判断是否应该检查更新（基于时间窗口）
# 返回: 0 = 应该检查, 1 = 不应检查
should_check_updates() {
    local enabled=$(get_config_value "autoCheck.enabled")

    # 如果未启用自动检查
    if [ "$enabled" != "true" ]; then
        return 1
    fi

    # 如果 jq 不可用，降级为总是检查
    if ! check_jq; then
        return 0
    fi

    local interval=$(get_config_value "autoCheck.intervalHours")
    local last_check=$(get_config_value "autoCheck.lastCheck")

    # 如果从未检查过，应该检查
    if [ "$last_check" = "null" ] || [ -z "$last_check" ]; then
        return 0
    fi

    # 计算时间差
    local now=$(date +%s)
    local last_check_ts=$(date_to_timestamp "$last_check")

    # 如果解析失败，应该检查
    if [ "$last_check_ts" = "0" ]; then
        return 0
    fi

    # 计算相差的小时数
    local diff_hours=$(( ($now - $last_check_ts) / 3600 ))

    # 如果超过间隔时间，应该检查
    if [ $diff_hours -ge $interval ]; then
        return 0
    fi

    # 在时间窗口内，不应检查
    return 1
}

# 更新检查缓存
# 用法: update_check_cache "2.1.0"
update_check_cache() {
    local upstream_version="$1"
    local current_time=$(get_current_time)

    if ! check_jq; then
        return 1
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        init_config_if_missing
    fi

    # 更新最后检查时间和缓存的版本
    jq ".autoCheck.lastCheck = \"$current_time\" | .autoCheck.cachedUpstreamVersion = \"$upstream_version\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    return 0
}

# 获取缓存的上游版本
get_cached_upstream_version() {
    get_config_value "autoCheck.cachedUpstreamVersion"
}

# 强制清除检查缓存（用于手动同步后）
clear_check_cache() {
    set_config_value "autoCheck.lastCheck" "null"
    set_config_value "autoCheck.cachedUpstreamVersion" "null"
}

# =============================================================================
# 同步模式管理
# =============================================================================

# 获取同步模式
get_sync_mode() {
    get_config_value "syncMode"
}

# 设置同步模式
# 用法: set_sync_mode "full" | "core" | "curriculum"
set_sync_mode() {
    local mode="$1"
    set_config_value "syncMode" "$mode"
}

# =============================================================================
# 版本提取函数（供 Skills 使用）
# =============================================================================

# 从 CHANGELOG.md 提取本地版本
get_local_version() {
    if [ -f "CHANGELOG.md" ]; then
        grep "^## \[" CHANGELOG.md | grep -v "Unreleased" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/' || echo "unknown"
    else
        echo "unknown"
    fi
}

# 从 upstream 提取版本
get_upstream_version() {
    # 检查是否配置了 upstream
    if ! git remote | grep -q "^upstream$" 2>/dev/null; then
        echo "no-upstream"
        return
    fi

    # 从 upstream 的 CHANGELOG.md 提取版本
    git show upstream/main:CHANGELOG.md 2>/dev/null | grep "^## \[" | grep -v "Unreleased" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/' || echo "unknown"
}

# 使用缓存版本进行检查（如果在时间窗口内）
check_updates_with_cache() {
    local local_version=$(get_local_version)
    local cached_version=$(get_cached_upstream_version)
    local result=0

    # 如果启用缓存且在时间窗口内
    if should_check_updates; then
        # 需要执行网络检查
        local upstream_version=$(get_upstream_version)

        # 更新缓存
        update_check_cache "$upstream_version"

        if [ "$local_version" != "$upstream_version" ] && [ "$upstream_version" != "unknown" ] && [ "$upstream_version" != "no-upstream" ]; then
            result=1  # 有更新
        fi
    else
        # 使用缓存版本
        if [ "$local_version" != "$cached_version" ] && [ "$cached_version" != "null" ] && [ "$cached_version" != "unknown" ]; then
            result=1  # 有更新（基于缓存）
        fi
    fi

    return $result
}

# =============================================================================
# 导出函数（供其他脚本使用）
# =============================================================================

export -f check_jq
export -f get_current_time
export -f date_to_timestamp
export -f init_config_if_missing
export -f get_config_value
export -f set_config_value
export -f should_check_updates
export -f update_check_cache
export -f get_cached_upstream_version
export -f clear_check_cache
export -f get_sync_mode
export -f set_sync_mode
export -f get_local_version
export -f get_upstream_version
export -f check_updates_with_cache
