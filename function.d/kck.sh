#!/bin/bash
### kck - Kubernetes 配置管理工具
###
### 用法:
###   kck [--list|-l]                 显示所有可用配置
###   kck <配置名>                     切换到指定配置（仅设置环境变量）
###   kck [--set-default|-d] <配置名>  切换配置并设置为默认（修改软链接）
###   kck --current|-c                显示当前激活的配置
###   kck --help|-h                   显示此帮助信息
###
### 示例:
###   kck                            # 列出所有配置
###   kck production                 # 临时切换到 production 配置
###   kck --set-default production   # 切换到 production 并设为默认
###   kck --current                  # 显示当前配置
###
### 符号说明:
###   >  当前激活的配置（绿色高亮）
###   *  config 软链接指向的配置

_kck_log_info() {
    printf "\033[32m%s\033[0m\n" "$*"
}

_kck_log_error() {
    printf "\033[31m%s\033[0m\n" "$*"
}

# 帮助函数
_kck_help() {
    cat << 'EOF'
kck - Kubernetes 配置管理工具

用法:
  kck [--list|-l]                 显示所有可用配置
  kck <配置名>                     切换到指定配置（仅设置环境变量）
  kck [--set-default|-d] <配置名>  切换配置并设置为默认（修改软链接）
  kck --current|-c                显示当前激活的配置
  kck --help|-h                   显示此帮助信息

示例:
  kck                            # 列出所有配置
  kck production                 # 临时切换到 production 配置
  kck --set-default production   # 切换到 production 并设为默认
  kck --current                  # 显示当前配置

符号说明:
  >  当前激活的配置（绿色高亮）
  *  config 软链接指向的配置
EOF
}


# 获取当前激活的 kubeconfig 名称
_kck_get_current_name() {
    local kubeconfig="${KUBECONFIG:-${HOME}/.kube/config}"
    
    if [ ! -e "$kubeconfig" ]; then
        if [ "$1" = "--log" ]; then
            echo
            _kck_log_error "错误: 当前配置文件 $kubeconfig 不存在" >&2
            return 1
        fi
        return
    fi
    
    # 如果是符号链接，获取链接目标的文件名

    if [ -L "$kubeconfig" ]; then
        local target
        target=$(readlink "$kubeconfig")
        basename "$target" .kubeconfig
    else
        # 如果是普通文件，返回文件名
        basename "$kubeconfig" .kubeconfig
    fi
}

# 获取 config 软链接指向的配置名称
_kck_get_config_link_name() {
    local kubeconfig_default="${HOME}/.kube/config"
    
    if [ -L "$kubeconfig_default" ]; then
        local target=$(readlink "$kubeconfig_default")
        basename "$target" .kubeconfig
    else
        # 如果不是软链接，返回空
        echo ""
    fi
}

# 获取最长配置名称的长度（用于格式化输出）
_kck_get_max_name_length() {
    local kube_dir="$1"
    local max_length=0
    local name
    local length
    
    # 查找所有 kubeconfig 文件
    for file in "$kube_dir"/*.kubeconfig "$kube_dir"/config; do
        [ -f "$file" ] || continue

        name="$(basename "$file" .kubeconfig)"
        length="${#name}"
        
        if (( length > max_length )); then
            max_length=$length
        fi
    done
    
    echo "$max_length"
}

# 列出所有可用的 kubeconfig 文件
_kck_list() {
    local kube_dir="${HOME}/.kube"
    local kubeconfig_default="${kube_dir}/config"
    
    # 检查 .kube 目录是否存在
    if [ ! -d "$kube_dir" ]; then
        echo "错误: $kube_dir 目录不存在" >&2
        return 1
    fi
    
    # 获取当前激活的配置名称（通过 KUBECONFIG 或默认配置）
    local current_name
    if ! current_name=$(_kck_get_current_name); then
        return 1
    fi
    
    # 获取 config 软链接指向的配置名称
    local config_link_name=$(_kck_get_config_link_name)
    
    # 获取最长名称长度用于格式化
    local max_length=$(_kck_get_max_name_length "$kube_dir")
    
    # 收集所有配置文件
    local configs=()
    
    # 添加 .kubeconfig 文件
    for file in "$kube_dir"/*.kubeconfig; do
        [ -f "$file" ] && configs+=($(basename "$file"))
    done
    
    # 如果 config 文件存在且不是符号链接，也添加进来
    if [ -f "$kubeconfig_default" ] && [ ! -L "$kubeconfig_default" ]; then
        configs+=("config")
    fi
    
    # 检查是否找到配置文件
    if (( ${#configs[@]} == 0 )); then
        echo "未找到任何 kubeconfig 文件" >&2
        return 1
    fi
    
    # 输出配置列表
    echo "可用的 Kubernetes 配置:"
    echo
    
    for config in "${configs[@]}"; do
        local name=$(basename "$config" .kubeconfig)
        local formatted_name=$(printf "%-${max_length}s" "$name")
        local file_path="${kube_dir}/${config}"
        
        # 判断前缀和后缀
        local prefix="  "
        local suffix=""
        local use_color=false
        
        # > 表示当前激活的配置
        if [ "$current_name" = "$name" ]; then
            prefix="> "
            use_color=true
        fi
        
        # * 表示 config 软链接指向的配置
        if [ -n "$config_link_name" ] && [ "$config_link_name" = "$name" ]; then
            suffix=" *"
        fi
        
        # 输出
        if [ "$use_color" = true ]; then
            _kck_log_info "${prefix}${formatted_name} ${file_path}${suffix}"
        else
            echo "${prefix}${formatted_name} ${file_path}${suffix}"
        fi
    done

    if [ -z "$current_name" ]; then
        _kck_get_current_name --log
    fi

}

# 切换到指定的 kubeconfig
_kck_switch() {
    local kube_dir="${HOME}/.kube"
    local kubeconfig_default="${kube_dir}/config"
    local set_default=false
    local target_name

    if [ "$1" = "--set-default" ] || [ "$1" = "-d" ]; then
        set_default=true
        target_name="$2"
    else
        target_name="$1"
    fi



    # 检查参数
    if [ -z "$target_name" ]; then
        _kck_help
        return 1
    fi
    
    # 检查是否需要设置默认配置
    if [ "$2" = "--set-default" ]; then
        set_default=true
    fi
    
    # 查找目标配置文件
    local target_file=""
    
    if [ "$target_name" = "config" ] &&  [-f "${kube_dir}/config.kubeconfig" ]; then
        target_file="${kube_dir}/config.kubeconfig"
    elif [ -f "${kube_dir}/${target_name}.kubeconfig" ]; then
        target_file="${kube_dir}/${target_name}.kubeconfig"
    elif [ "$target_name" = "config" ] && [ -f "$kubeconfig_default" ]; then
        target_file="$kubeconfig_default"
    else
        echo "错误: 找不到配置 '${target_name}'" >&2
        echo "使用 kck_list 查看可用配置" >&2
        return 1
    fi
    
    # 设置环境变量
    export KUBECONFIG="$target_file"
    _kck_log_info "已设置环境变量 KUBECONFIG: ${target_file}"
    
    # 如果需要，同时修改默认软链接
    if [ "$set_default" = true ]; then
        if [ ! "$target_file" = "$kubeconfig_default" ]; then
            if [ -L "$kubeconfig_default" ] || [ ! -e "$kubeconfig_default" ]; then
                ln -sf "$target_file" "$kubeconfig_default"
                _kck_log_info "已设置默认配置软链接: ${target_name}"
            else
                echo "警告: ${kubeconfig_default} 是普通文件，无法创建软链接" >&2
                echo "请手动备份并删除该文件，然后重试" >&2
                return 1
            fi
        else
            _kck_log_info "目标配置就是默认配置文件，无需创建软链接"
        fi
    fi
}

# 显示当前激活的配置
_kck_current() {
    local kubeconfig="${KUBECONFIG:-${HOME}/.kube/config}"
    
    if [ ! -e "$kubeconfig" ]; then
        _kck_log_error "错误: 当前配置文件 $kubeconfig 不存在" >&2
        return 1
    fi
    
    # 获取配置名称
    local name
    if [ -L "$kubeconfig" ]; then
        local target=$(readlink "$kubeconfig")
        name=$(basename "$target" .kubeconfig)
    else
        name=$(basename "$kubeconfig" .kubeconfig)
    fi
    
    # 显示完整信息：名称和完整路径
    _kck_log_info "${name} ${kubeconfig}"
}

# 主函数：统一的入口点
kck() {
    local first_arg="$1"
    local second_arg="$2"
    
    # 无参数：显示配置列表
    if [ $# -eq 0 ]; then
        _kck_list
        return $?
    fi
    
    # 处理选项参数
    case "$first_arg" in
        --list|-l)
            _kck_list
            return $?
            ;;
        --current|-c)
            _kck_current
            return $?
            ;;
        --help|-h)
            _kck_help
            return 0
            ;;
        --set-default|-d)
            _kck_switch "$first_arg" "$second_arg"
            return 0
            ;;
        -*)
            echo "错误: 未知选项 '$first_arg'" >&2
            echo "使用 'kck --help' 查看帮助信息" >&2
            return 1
            ;;
        *)
            _kck_switch "$first_arg"
            ;;
    esac
}
