#!/bin/bash

# 注释掉 set -e 来避免意外的退出
# set -e

# 颜色定义
colorReset='\033[0m'
colorBright='\033[1m'
colorCyan='\033[36m'
colorYellow='\033[33m'
colorMagenta='\033[35m'
colorRed='\033[31m'
colorBlue='\033[34m'
colorWhite='\033[37m'
colorGreen='\033[32m'

# 显示启动横幅
show_banner() {
    printf "${colorBright}${colorRed}   █████╗ ██╗  ${colorBlue}██████╗ ██████╗ ██████╗ ███████╗${colorMagenta} ██╗    ██╗██╗████████╗██╗  ██╗${colorReset}\n"
    printf "${colorBright}${colorRed}  ██╔══██╗██║ ${colorBlue}██╔════╝██╔═══██╗██╔══██╗██╔════╝${colorMagenta} ██║    ██║██║╚══██╔══╝██║  ██║${colorReset}\n"
    printf "${colorBright}${colorRed}  ███████║██║ ${colorBlue}██║     ██║   ██║██║  ██║█████╗  ${colorMagenta} ██║ █╗ ██║██║   ██║   ███████║${colorReset}\n"
    printf "${colorBright}${colorRed}  ██╔══██║██║ ${colorBlue}██║     ██║   ██║██║  ██║██╔══╝  ${colorMagenta} ██║███╗██║██║   ██║   ██╔══██║${colorReset}\n"
    printf "${colorBright}${colorRed}  ██║  ██║██║ ${colorBlue}╚██████╗╚██████╔╝██████╔╝███████╗${colorMagenta} ╚███╔███╔╝██║   ██║██╗██║  ██║${colorReset}\n"
    printf "${colorBright}${colorRed}  ╚═╝  ╚═╝╚═╝ ${colorBlue} ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝${colorMagenta}  ╚══╝╚══╝ ╚═╝   ╚═╝╚═╝╚═╝  ╚═╝${colorReset}\n"
    printf "\n"
    printf "${colorBright}${colorYellow}🚀 ${colorCyan}https://aicodewith.com${colorYellow} 🚀${colorReset}\n"
    printf "\n"
    printf "${colorBright}${colorGreen}================== Claude Code 环境安装程序 ==================${colorReset}\n"
    printf "\n"
}

# 显示步骤信息
show_step() {
    local step_num=$1
    local step_name=$2
    local description=$3
    
    printf "${colorBright}${colorCyan}┌──────────────────────────────────────────────────────────┐${colorReset}\n"
    printf "${colorBright}${colorCyan}│ ${colorYellow}步骤 ${step_num}${colorCyan}: ${colorWhite}${step_name}${colorReset}\n"
    printf "${colorBright}${colorCyan}│ ${colorWhite}${description}${colorReset}\n"
    printf "${colorBright}${colorCyan}└──────────────────────────────────────────────────────────┘${colorReset}\n"
    printf "\n"
}

# 显示成功信息
show_success() {
    local message=$1
    printf "${colorBright}${colorGreen}✅ ${message}${colorReset}\n"
}

# 显示警告信息
show_warning() {
    local message=$1
    printf "${colorBright}${colorYellow}⚠️  ${message}${colorReset}\n"
}

# 显示错误信息
show_error() {
    local message=$1
    printf "${colorBright}${colorRed}❌ ${message}${colorReset}\n"
}

# 显示进度信息
show_progress() {
    local message=$1
    printf "${colorBright}${colorBlue}🔄 ${message}${colorReset}\n"
}

# 显示启动横幅
show_banner

# 权限提示
show_step "0" "权限检查" "检查是否需要管理员权限"
if [[ "$EUID" -eq 0 ]]; then
    show_warning "检测到使用 root 权限运行"
    show_progress "将使用系统全局路径安装..."
else
    show_success "使用普通用户权限，将安装到用户目录"
fi

# 检查操作系统
show_step "1" "系统环境检查" "检查当前操作系统兼容性"
OS="$(uname)"
show_progress "检测到操作系统: $OS"

if [[ "$OS" != "Darwin" && "$OS" != "Linux" ]]; then
    show_error "仅支持 macOS 和 Linux 系统"
    exit 1
fi

show_success "操作系统检查通过"

# 函数：检查版本号是否大于等于要求的版本
version_compare() {
    printf '%s\n%s' "$1" "$2" | sort -V | head -n1
}

# 修复npm缓存权限问题的函数
fix_npm_cache_permissions() {
    show_progress "检查npm缓存权限..."
    
    # 获取当前用户的UID和GID
    local user_uid=$(id -u)
    local user_gid=$(id -g)
    
    # 获取npm缓存目录路径
    local npm_cache_dir=$(npm config get cache 2>/dev/null || echo "$HOME/.npm")
    
    show_progress "npm缓存目录: $npm_cache_dir"
    show_progress "当前用户: $user_uid:$user_gid"
    
    # 检查缓存目录是否存在
    if [ ! -d "$npm_cache_dir" ]; then
        show_progress "npm缓存目录不存在，跳过权限修复"
        return 0
    fi
    
    # 检查缓存目录的所有者
    local cache_owner=$(stat -f "%u:%g" "$npm_cache_dir" 2>/dev/null || stat -c "%u:%g" "$npm_cache_dir" 2>/dev/null)
    show_progress "缓存目录所有者: $cache_owner"
    
    # 深度检查：查找所有root用户拥有的文件
    show_progress "深度检查缓存文件权限..."
    local root_files_count=0
    
    # 检查是否有root用户拥有的文件
    if [ -d "$npm_cache_dir" ]; then
        root_files_count=$(find "$npm_cache_dir" -user root 2>/dev/null | wc -l | tr -d ' ')
        if [ "$root_files_count" -gt 0 ]; then
            show_warning "发现 $root_files_count 个root用户拥有的文件"
        else
            show_success "未发现root用户拥有的文件"
        fi
    fi
    
    # 如果目录所有者不正确或存在root文件，则修复权限
    if [ "$cache_owner" != "$user_uid:$user_gid" ] || [ "$root_files_count" -gt 0 ]; then
        show_progress "正在修复npm缓存权限..."
        show_progress "执行命令: sudo chown -R $user_uid:$user_gid \"$npm_cache_dir\""
        
        # 使用sudo修复权限
        if sudo chown -R "$user_uid:$user_gid" "$npm_cache_dir"; then
            show_success "npm缓存权限修复成功"
            
            # 再次检查验证
            local new_root_files_count=$(find "$npm_cache_dir" -user root 2>/dev/null | wc -l | tr -d ' ')
            if [ "$new_root_files_count" -eq 0 ]; then
                show_success "权限修复验证通过"
            else
                show_warning "仍有 $new_root_files_count 个root文件，可能需要手动处理"
            fi
        else
            show_error "npm缓存权限修复失败"
            return 1
        fi
    else
        show_success "npm缓存权限正常"
    fi
    
    # 清理可能损坏的缓存
    show_progress "清理npm缓存..."
    if npm cache clean --force 2>/dev/null; then
        show_success "npm缓存清理成功"
    else
        show_warning "npm缓存清理失败，尝试强制清理..."
        # 如果清理失败，尝试删除整个缓存目录重新创建
        if sudo rm -rf "$npm_cache_dir" 2>/dev/null; then
            show_success "已删除损坏的缓存目录"
            if mkdir -p "$npm_cache_dir" 2>/dev/null; then
                show_success "已重新创建缓存目录"
            fi
        else
            show_warning "无法清理缓存，但继续安装"
        fi
    fi
    
    return 0
}

# 检查和修复npm全局安装目录权限的函数
fix_npm_global_permissions() {
    show_progress "检查npm全局安装目录权限..."
    
    # 获取当前用户的UID和GID
    local user_uid=$(id -u)
    local user_gid=$(id -g)
    
    # 获取npm全局安装目录
    local npm_global_dir=$(npm config get prefix 2>/dev/null)
    if [ -z "$npm_global_dir" ]; then
        npm_global_dir="/usr/local"
    fi
    
    # 检查不同的可能路径
    local global_node_modules="$npm_global_dir/lib/node_modules"
    local global_bin="$npm_global_dir/bin"
    
    show_progress "npm全局目录: $npm_global_dir"
    show_progress "node_modules: $global_node_modules"
    show_progress "bin目录: $global_bin"
    show_progress "当前用户: $user_uid:$user_gid"
    
    # 检查是否需要修复权限
    local need_fix=false
    
    # 检查node_modules目录
    if [ -d "$global_node_modules" ]; then
        local modules_owner=$(stat -f "%u:%g" "$global_node_modules" 2>/dev/null || stat -c "%u:%g" "$global_node_modules" 2>/dev/null)
        show_progress "node_modules所有者: $modules_owner"
        if [ "$modules_owner" != "$user_uid:$user_gid" ]; then
            need_fix=true
            show_warning "node_modules目录权限不正确"
        fi
        
        # 检查现有的claude-code包权限（这是关键问题）
        local claude_package_dir="$global_node_modules/@anthropic-ai/claude-code"
        if [ -d "$claude_package_dir" ]; then
            local claude_owner=$(stat -f "%u:%g" "$claude_package_dir" 2>/dev/null || stat -c "%u:%g" "$claude_package_dir" 2>/dev/null)
            show_progress "现有claude-code包所有者: $claude_owner"
            if [ "$claude_owner" != "$user_uid:$user_gid" ]; then
                need_fix=true
                show_warning "现有claude-code包权限不正确"
            fi
            
            # 检查包内文件权限
            local root_files_in_package=$(find "$claude_package_dir" -user root 2>/dev/null | wc -l | tr -d ' ')
            if [ "$root_files_in_package" -gt 0 ]; then
                need_fix=true
                show_warning "claude-code包内发现 $root_files_in_package 个root文件"
            fi
        fi
    fi
    
    # 检查bin目录
    if [ -d "$global_bin" ]; then
        local bin_owner=$(stat -f "%u:%g" "$global_bin" 2>/dev/null || stat -c "%u:%g" "$global_bin" 2>/dev/null)
        show_progress "bin目录所有者: $bin_owner"
        if [ "$bin_owner" != "$user_uid:$user_gid" ]; then
            need_fix=true
            show_warning "bin目录权限不正确"
        fi
        
        # 检查bin目录中的claude命令
        if [ -f "$global_bin/claude" ]; then
            local claude_bin_owner=$(stat -f "%u:%g" "$global_bin/claude" 2>/dev/null || stat -c "%u:%g" "$global_bin/claude" 2>/dev/null)
            show_progress "claude命令文件所有者: $claude_bin_owner"
            if [ "$claude_bin_owner" != "$user_uid:$user_gid" ]; then
                need_fix=true
                show_warning "claude命令文件权限不正确"
            fi
        fi
    fi
    
    if [ "$need_fix" = true ]; then
        show_progress "需要修复全局安装目录权限"
        show_progress "建议的修复命令: sudo chown -R $user_uid:$user_gid \"$npm_global_dir\""
        
        printf "${colorBright}${colorYellow}❓ 是否自动修复权限？这需要sudo权限。${colorReset}\n"
        printf "${colorCyan}输入 y 自动修复，或 n 跳过修复: ${colorReset}"
        read -n 1 -r REPLY
        printf "\n"
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            show_progress "正在修复全局安装目录权限..."
            if sudo chown -R "$user_uid:$user_gid" "$npm_global_dir"; then
                show_success "全局安装目录权限修复成功"
                return 0
            else
                show_error "全局安装目录权限修复失败"
                return 1
            fi
        else
            show_progress "跳过权限修复，将尝试其他安装方式"
            return 1
        fi
    else
        show_success "npm全局安装目录权限正常"
        return 0
    fi
}

# 尝试不同的安装方式
try_install_package() {
    local package_file="$1"
    
    show_progress "尝试全局安装..."
    
    # 方法1：直接全局安装
    show_progress "方法1: 直接全局安装"
    if npm install "$package_file" -g 2>/dev/null; then
        show_success "全局安装成功!"
        return 0
    fi
    
    show_warning "直接全局安装失败，检查权限..."
    
    # 检查和修复全局安装目录权限
    if fix_npm_global_permissions; then
        show_progress "方法2: 权限修复后重试全局安装"
        if npm install "$package_file" -g; then
            show_success "权限修复后全局安装成功!"
            return 0
        fi
    fi
    
    # 方法3：使用不同的安装前缀
    show_progress "方法3: 使用用户级全局安装"
    local user_global_dir="$HOME/.npm-global"
    if [ ! -d "$user_global_dir" ]; then
        mkdir -p "$user_global_dir"
    fi
    
    if npm install "$package_file" -g --prefix "$user_global_dir"; then
        show_success "用户级全局安装成功!"
        show_warning "请将以下路径添加到你的PATH环境变量中:"
        printf "${colorCyan}export PATH=\"$user_global_dir/bin:\$PATH\"${colorReset}\n"
        show_progress "你可以将上述命令添加到 ~/.bashrc 或 ~/.zshrc 中"
        
        # 自动添加到PATH
        if [[ "$SHELL" == *"zsh"* ]]; then
            PROFILE="$HOME/.zshrc"
        else
            PROFILE="$HOME/.bashrc"
        fi
        
        if ! grep -q "$user_global_dir/bin" "$PROFILE" 2>/dev/null; then
            echo "export PATH=\"$user_global_dir/bin:\$PATH\"" >> "$PROFILE"
            show_success "已自动添加到 $PROFILE"
        fi
        
        return 0
    fi
    
    show_error "所有安装方法均失败"
    return 1
}

# 函数：检查 Node.js 版本
check_nodejs_version() {
    show_progress "正在检查 Node.js 版本..."
    
    if command -v node >/dev/null 2>&1; then
        current_version=$(node --version | sed 's/v//')
        required_version="18.19.0"
        
        show_progress "当前 Node.js 版本: v$current_version"
        show_progress "要求 Node.js 版本: >= v$required_version"
        
        if [[ "$(version_compare "$current_version" "$required_version")" == "$required_version" ]]; then
            show_success "Node.js 版本检查通过 (v$current_version >= v$required_version)"
            return 0
        else
            show_warning "Node.js 版本不满足要求 (v$current_version < v$required_version)"
            return 1
        fi
    else
        show_warning "未检测到 Node.js，需要安装"
        return 1
    fi
}

# 函数：安装 NVM
install_nvm() {
    show_step "3" "安装 NVM" "Node Version Manager - Node.js 版本管理工具"
    
    # 设置 NVM 目录
    export NVM_DIR="$HOME/.nvm"
    
    # 如果目录已存在，先删除
    if [ -d "$NVM_DIR" ]; then
        show_progress "清理现有 NVM 安装..."
        rm -rf "$NVM_DIR"
    fi
    
    # 创建 NVM 目录
    show_progress "创建 NVM 目录: $NVM_DIR"
    mkdir -p "$NVM_DIR"
    
    # 直接下载 NVM 压缩包（绕过 git clone）
    show_progress "正在下载 NVM v0.39.0..."
    if command -v curl >/dev/null 2>&1; then
        show_progress "使用 curl 下载..."
        curl -L https://github.com/nvm-sh/nvm/archive/v0.39.0.tar.gz | tar -xz -C "$NVM_DIR" --strip-components=1
    elif command -v wget >/dev/null 2>&1; then
        show_progress "使用 wget 下载..."
        wget -qO- https://github.com/nvm-sh/nvm/archive/v0.39.0.tar.gz | tar -xz -C "$NVM_DIR" --strip-components=1
    else
        show_error "需要 curl 或 wget 来下载 NVM"
        exit 1
    fi
    
    show_success "NVM 下载完成"
    
    # 重新加载环境变量
    show_progress "加载 NVM 环境..."
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # 检测 shell 类型并配置
    show_progress "检测 Shell 类型..."
    if [[ "$SHELL" == *"zsh"* ]]; then
        PROFILE="$HOME/.zshrc"
        show_progress "检测到 Zsh，配置文件: $PROFILE"
    else
        PROFILE="$HOME/.bashrc"
        show_progress "检测到 Bash，配置文件: $PROFILE"
    fi
    
    # 添加 NVM 到配置文件
    show_progress "配置环境变量到 $PROFILE..."
    if ! grep -q "NVM_DIR" "$PROFILE" 2>/dev/null; then
        echo 'export NVM_DIR="$HOME/.nvm"' >> "$PROFILE"
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$PROFILE"
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$PROFILE"
        show_success "环境变量配置完成"
    else
        show_success "环境变量已存在，跳过配置"
    fi
    
    # 配置 NVM 国内镜像
    show_progress "配置 NVM 国内镜像源..."
    export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/
    export NVM_NPM_MIRROR=https://npmmirror.com/mirrors/npm/
    
    # 永久保存配置
    if ! grep -q "NVM_NODEJS_ORG_MIRROR" "$PROFILE" 2>/dev/null; then
        echo 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/' >> "$PROFILE"
        echo 'export NVM_NPM_MIRROR=https://npmmirror.com/mirrors/npm/' >> "$PROFILE"
        show_success "镜像源配置完成"
    else
        show_success "镜像源已配置，跳过"
    fi
    
    source "$PROFILE" 2>/dev/null || true
    
    show_success "NVM 安装完成！"
}

# 函数：通过 NVM 安装 Node.js
install_nodejs_via_nvm() {
    show_step "3.1" "安装 Node.js" "通过 NVM 安装 Node.js 18.19.0"
    
    # 确保 NVM 已加载
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # 安装 Node.js 18.19.0
    show_progress "安装 Node.js 18.19.0..."
    nvm install 18.19.0
    show_success "Node.js 18.19.0 安装完成"
    
    show_progress "设置 Node.js 18.19.0 为当前版本..."
    nvm use 18.19.0
    show_success "Node.js 18.19.0 已设为当前版本"
    
    show_progress "设置 Node.js 18.19.0 为默认版本..."
    nvm alias default 18.19.0
    show_success "Node.js 18.19.0 已设为默认版本"
    
    show_success "Node.js 18.19.0 安装配置完成"
    
    # 验证安装
    show_progress "验证安装结果..."
    printf "\n${colorBright}${colorGreen}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colorReset}\n"
    printf "${colorBright}${colorCyan}📦 Node.js 版本: ${colorYellow}$(node --version)${colorReset}\n"
    printf "${colorBright}${colorCyan}📦 NPM 版本: ${colorYellow}$(npm --version)${colorReset}\n"
    printf "${colorBright}${colorCyan}🌐 NPM 镜像: ${colorYellow}$(npm config get registry)${colorReset}\n"
    printf "${colorBright}${colorCyan}📁 NPM 全局路径: ${colorYellow}$(npm config get prefix)${colorReset}\n"
    printf "${colorBright}${colorGreen}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colorReset}\n"
}

# 函数：检查并安装必要工具
install_required_tools() {
    show_step "2" "检查必要工具" "确保 curl/wget 等下载工具可用"
    
    # 检查 curl
    if ! command -v curl >/dev/null 2>&1; then
        show_warning "未找到 curl，正在安装..."
        
        if [[ "$OS" == "Darwin" ]]; then
            # macOS 通常自带 curl，如果没有则提示用户
            show_error "macOS 应该自带 curl，请检查系统环境"
            exit 1
        elif [[ "$OS" == "Linux" ]]; then
            # Linux 尝试使用包管理器安装
            if command -v apt >/dev/null 2>&1; then
                show_progress "使用 apt 安装 curl..."
                sudo apt update && sudo apt install -y curl
            elif command -v yum >/dev/null 2>&1; then
                show_progress "使用 yum 安装 curl..."
                sudo yum install -y curl
            elif command -v dnf >/dev/null 2>&1; then
                show_progress "使用 dnf 安装 curl..."
                sudo dnf install -y curl
            elif command -v pacman >/dev/null 2>&1; then
                show_progress "使用 pacman 安装 curl..."
                sudo pacman -S curl
            else
                show_error "无法识别包管理器，请手动安装 curl"
                exit 1
            fi
        fi
        
        # 再次检查
        if command -v curl >/dev/null 2>&1; then
            show_success "curl 安装成功"
        else
            show_error "curl 安装失败"
            exit 1
        fi
    else
        show_success "curl 已可用"
    fi
    
    # 检查 wget 作为备用
    if ! command -v wget >/dev/null 2>&1; then
        show_warning "wget 不可用，将依赖 curl"
    else
        show_success "wget 也可用（备用下载工具）"
    fi
}

# 函数：安装Claude Code镜像版本
install_claude_code() {
    show_step "4" "安装 Claude Code" "安装你的定制版本"
    
    # 添加权限检查与修复步骤
    show_step "4.1" "权限检查与修复" "检查并修复npm相关权限问题"
    
    # 修复npm缓存权限
    if ! fix_npm_cache_permissions; then
        show_warning "npm缓存权限修复失败，但继续尝试安装..."
    fi
    
    show_progress "清理可能存在的旧版本..."
    
    # 检测npm全局路径，决定是否需要sudo
    npm_prefix=$(npm config get prefix 2>/dev/null || echo "")
    show_progress "检测到npm全局路径: $npm_prefix"
    
    # 根据路径决定卸载方式
    if [[ "$npm_prefix" == "/usr/local" ]] || [[ "$npm_prefix" == "/usr"* ]] || [[ -z "$npm_prefix" ]]; then
        # 系统路径，需要sudo
        show_progress "使用系统路径，需要sudo权限卸载..."
        sudo npm uninstall -g @anthropic-ai/claude-code >/dev/null 2>&1 || true
        sudo npm uninstall -g claude-code >/dev/null 2>&1 || true
    else
        # 用户路径，不需要sudo
        show_progress "使用用户路径，无需sudo权限卸载..."
        npm uninstall -g @anthropic-ai/claude-code >/dev/null 2>&1 || true
        npm uninstall -g claude-code >/dev/null 2>&1 || true
    fi
    
    # 检查 which claude，如果还存在就手动删除
    if command -v claude >/dev/null 2>&1; then
        claude_path=$(which claude)
        show_progress "清理残留的 claude 命令: $claude_path"
        sudo rm -f "$claude_path" 2>/dev/null || rm -f "$claude_path" 2>/dev/null || true
    fi
    
    # 明确清理brew环境的符号链接
    show_progress "清理brew环境符号链接..."
    sudo rm -f "/opt/homebrew/bin/claude" 2>/dev/null || true
    
    # 强制清理可能残留的符号链接和缓存（用户目录）
    rm -f "$HOME/.npm-global/bin/claude" 2>/dev/null || true
    rm -rf "$HOME/.npm-global/lib/node_modules/@anthropic-ai" 2>/dev/null || true
    rm -rf "$HOME/.npm-global/lib/node_modules/claude-code" 2>/dev/null || true
    
    # 强制清理可能残留的符号链接和缓存（系统目录）
    sudo rm -f "/usr/local/bin/claude" 2>/dev/null || true
    sudo rm -rf "/usr/local/lib/node_modules/@anthropic-ai" 2>/dev/null || true
    sudo rm -rf "/usr/local/lib/node_modules/claude-code" 2>/dev/null || true
    
    # 清理homebrew目录中的残留文件（这是关键）
    if [[ "$npm_prefix" == "/opt/homebrew" ]]; then
        show_progress "检测到homebrew环境，强制清理可能的权限问题文件..."
        
        # 检查并清理可能有权限问题的claude-code包
        if [ -d "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code" ]; then
            show_progress "发现现有claude-code包，检查权限..."
            local existing_owner=$(stat -f "%u:%g" "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code" 2>/dev/null || echo "unknown")
            show_progress "现有包所有者: $existing_owner"
            
            # 如果权限不正确，使用sudo删除
            local current_user_id="$(id -u):$(id -g)"
            if [ "$existing_owner" != "$current_user_id" ]; then
                show_warning "现有包权限不正确，需要sudo权限清理"
                if sudo rm -rf "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code" 2>/dev/null; then
                    show_success "已清理权限问题的claude-code包"
                else
                    show_warning "清理失败，但继续安装"
                fi
            else
                show_progress "权限正常，使用普通权限清理"
                rm -rf "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code" 2>/dev/null || true
            fi
        fi
        
        # 清理bin目录中的claude命令
        if [ -f "/opt/homebrew/bin/claude" ]; then
            local claude_bin_owner=$(stat -f "%u:%g" "/opt/homebrew/bin/claude" 2>/dev/null || echo "unknown")
            local current_user_id="$(id -u):$(id -g)"
            if [ "$claude_bin_owner" != "$current_user_id" ]; then
                show_progress "清理权限问题的claude命令文件"
                sudo rm -f "/opt/homebrew/bin/claude" 2>/dev/null || true
            else
                rm -f "/opt/homebrew/bin/claude" 2>/dev/null || true
            fi
        fi
    fi
    
    # 恢复用户被修改的配置（修复之前脚本的错误配置）
    show_progress "恢复被修改的npm配置..."
    
    # 恢复npm prefix到默认值
    current_prefix=$(npm config get prefix 2>/dev/null || echo "")
    if [[ "$current_prefix" == "$HOME/.npm-global" ]]; then
        show_progress "检测到npm prefix被修改为用户目录，正在恢复默认设置..."
        npm config delete prefix
        show_success "npm prefix已恢复为默认值"
    fi
    
    # 清理shell配置文件中的错误配置
    show_progress "清理shell配置文件中的错误PATH配置..."
    if [[ "$SHELL" == *"zsh"* ]]; then
        PROFILE="$HOME/.zshrc"
    else
        PROFILE="$HOME/.bashrc"
    fi
    
    # 删除之前脚本添加的错误配置行
    if [ -f "$PROFILE" ]; then
        # 删除npm-global相关的PATH配置
        sed -i.bak '/\.npm-global\/bin/d' "$PROFILE" 2>/dev/null || true
        # 删除NVM镜像配置（如果用户不需要）
        sed -i.bak '/NVM_NODEJS_ORG_MIRROR/d' "$PROFILE" 2>/dev/null || true
        sed -i.bak '/NVM_NPM_MIRROR/d' "$PROFILE" 2>/dev/null || true
        show_success "shell配置文件已清理"
    fi
    
    # 清理可能创建的.npm-global目录（询问用户）
    if [ -d "$HOME/.npm-global" ]; then
        show_warning "检测到 $HOME/.npm-global 目录（之前脚本创建的）"
        show_progress "为了彻底清理，建议删除此目录"
        rm -rf "$HOME/.npm-global" 2>/dev/null || true
        show_success "已清理 .npm-global 目录"
    fi
    
    show_success "配置恢复和版本清理完成"
    
    local temp_dir="/tmp/claude-code-install"
    local package_url="https://aicodewith.com/claudecode/resources/package-download"
    local package_file="$temp_dir/claude-code.tgz"
    
    show_progress "创建临时目录..."
    mkdir -p "$temp_dir"
    
    show_progress "下载你的 Claude Code 定制版本..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -L "$package_url" -o "$package_file" --progress-bar; then
            show_success "下载完成"
        else
            show_error "下载失败"
            rm -rf "$temp_dir"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget "$package_url" -O "$package_file" --progress=bar; then
            show_success "下载完成"
        else
            show_error "下载失败" 
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        show_error "需要 curl 或 wget 来下载安装包"
        exit 1
    fi
    
    show_progress "安装 Claude Code 定制版本..."
    
    # 使用新的智能安装函数
    if try_install_package "$package_file"; then
        show_success "Claude Code 定制版本安装成功！"
        show_progress "清理临时文件..."
        rm -rf "$temp_dir"
    else
        show_error "安装失败！"
        rm -rf "$temp_dir"
        printf "\n${colorBright}${colorRed}手动安装方案：${colorReset}\n"
        printf "1. 检查网络连接\n"
        printf "2. 手动运行以下命令之一：\n"
        printf "   ${colorCyan}npm install -g https://aicodewith.com/claudecode/resources/package-download${colorReset}\n"
        printf "   ${colorCyan}npm install -g https://aicodewith.com/claudecode/resources/package-download --prefix ~/.npm-global${colorReset}\n"
        printf "3. 如果使用第二个命令，请确保 ~/.npm-global/bin 在你的PATH中\n"
        exit 1
    fi
    
    # 验证安装
    show_progress "验证安装结果..."
    
    # 首先尝试重新加载环境变量
    if [[ "$SHELL" == *"zsh"* ]]; then
        PROFILE="$HOME/.zshrc"
    else
        PROFILE="$HOME/.bashrc"
    fi
    
    # 手动加载新的PATH设置
    show_progress "尝试重新加载环境变量从: $PROFILE"
    if [ -f "$PROFILE" ]; then
        show_progress "正在加载 $PROFILE..."
        # 使用更安全的方式加载配置文件
        (source "$PROFILE") 2>/dev/null || true
        show_progress "配置文件加载完成"
    else
        show_progress "配置文件不存在: $PROFILE"
    fi
    
    # 检查命令是否可用
    show_progress "检查claude命令可用性..."
    
    # 添加详细的调试信息
    show_progress "调试信息："
    show_progress "当前PATH: $PATH"
    show_progress "npm全局目录: $(npm config get prefix 2>/dev/null || echo 'unknown')"
    
    # 测试command -v
    show_progress "测试 command -v claude..."
    claude_check_result=$(command -v claude 2>&1 || echo "NOT_FOUND")
    show_progress "command -v 结果: $claude_check_result"
    
    if command -v claude >/dev/null 2>&1; then
        show_success "Claude Code 命令验证成功"
        claude_path=$(which claude 2>/dev/null || echo "unknown")
        show_success "Claude 命令位置: $claude_path"
        
        # 测试命令是否可执行
        if [ -x "$claude_path" ]; then
            show_success "Claude 命令可执行"
        else
            show_warning "Claude 命令文件存在但不可执行"
        fi
    else
        show_progress "命令不在当前PATH中，检查可能的安装位置..."
        
        # 检查各种可能的安装位置
        possible_locations=(
            "/opt/homebrew/bin/claude"
            "/usr/local/bin/claude"
            "$HOME/.npm-global/bin/claude"
        )
        
        found_claude=false
        for location in "${possible_locations[@]}"; do
            show_progress "检查位置: $location"
            if [ -f "$location" ]; then
                show_success "找到claude命令: $location"
                found_claude=true
                
                # 显示文件信息
                show_progress "文件信息: $(ls -la "$location" 2>/dev/null || echo 'unknown')"
                
                # 如果是用户目录安装，添加到PATH
                if [[ "$location" == "$HOME/.npm-global/bin/claude" ]]; then
                    show_warning "claude安装在用户目录，正在添加到PATH..."
                    export PATH="$HOME/.npm-global/bin:$PATH"
                    
                    # 再次验证
                    if command -v claude >/dev/null 2>&1; then
                        show_success "PATH更新后命令验证成功"
                    else
                        show_warning "请重新打开终端或运行: source $PROFILE"
                    fi
                else
                    # 全局安装，应该直接可用
                    show_success "claude命令已安装到全局位置"
                    show_progress "如果命令不可用，可能需要重启终端"
                fi
                break
            else
                show_progress "位置不存在: $location"
            fi
        done
        
        if [ "$found_claude" = false ]; then
            show_error "未找到claude命令，但不影响安装完成"
            show_progress "可能的解决方案："
            show_progress "1. 重新打开终端"
            show_progress "2. 运行: source ~/.zshrc 或 source ~/.bashrc" 
            show_progress "3. 手动检查: ls -la /opt/homebrew/bin/claude"
            # 不要exit 1，让脚本继续完成
        else
            show_success "claude命令验证完成"
        fi
    fi
}


# 主流程
show_step "1.1" "Node.js 版本检查" "检查是否需要安装或更新 Node.js"
if ! check_nodejs_version; then
    show_progress "检查 NVM 是否可用..."
    if ! command -v nvm >/dev/null 2>&1; then
        # 尝试加载 NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        if ! command -v nvm >/dev/null 2>&1; then
            show_warning "NVM 未安装，需要先安装 NVM"
            # 先安装必要工具
            install_required_tools
            # 再安装 NVM
            install_nvm
        fi
    fi
    
    # 安装 Node.js
    install_nodejs_via_nvm
    
    # 再次检查 Node.js 版本
    if ! check_nodejs_version; then
        show_error "Node.js 安装失败"
        exit 1
    fi
else
    show_success "Node.js 版本检查通过，跳过安装"
    # 仍然需要检查工具
    install_required_tools
fi

# 安装 Claude Code
install_claude_code

# 显示完成横幅

printf "\n"
printf "${colorBright}${colorRed}   █████╗ ██╗  ${colorBlue}██████╗ ██████╗ ██████╗ ███████╗${colorMagenta} ██╗    ██╗██╗████████╗██╗  ██╗${colorReset}\n"
printf "${colorBright}${colorRed}  ██╔══██╗██║ ${colorBlue}██╔════╝██╔═══██╗██╔══██╗██╔════╝${colorMagenta} ██║    ██║██║╚══██╔══╝██║  ██║${colorReset}\n"
printf "${colorBright}${colorRed}  ███████║██║ ${colorBlue}██║     ██║   ██║██║  ██║█████╗  ${colorMagenta} ██║ █╗ ██║██║   ██║   ███████║${colorReset}\n"
printf "${colorBright}${colorRed}  ██╔══██║██║ ${colorBlue}██║     ██║   ██║██║  ██║██╔══╝  ${colorMagenta} ██║███╗██║██║   ██║   ██╔══██║${colorReset}\n"
printf "${colorBright}${colorRed}  ██║  ██║██║ ${colorBlue}╚██████╗╚██████╔╝██████╔╝███████╗${colorMagenta} ╚███╔███╔╝██║   ██║██╗██║  ██║${colorReset}\n"
printf "${colorBright}${colorWhite}  ╚═╝  ╚═╝╚═╝ ${colorBlue} ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝${colorMagenta}  ╚══╝╚══╝ ╚═╝   ╚═╝╚═╝╚═╝  ╚═╝${colorReset}\n"
printf "\n"
printf "${colorBright}${colorYellow}🚀 ${colorCyan}欢迎访问我们的官网: https://aicodewith.com${colorYellow} 🚀${colorReset}\n"

printf "${colorBright}${colorGreen}╔════════════════════════════════════════════════════════════════════════════════════╗${colorReset}\n"
printf "${colorBright}${colorGreen}║${colorYellow}                               🎉 安装完成！ 🎉                                     ${colorGreen}║${colorReset}\n"
printf "${colorBright}${colorGreen}╠════════════════════════════════════════════════════════════════════════════════════╣${colorReset}\n"
printf "${colorBright}${colorGreen}║                                                                                    ${colorReset}\n"
printf "${colorBright}${colorGreen}║  ${colorCyan}下一步操作：${colorReset}                                               ${colorReset}\n"
# 检查claude命令是否可用，给出相应的指导
if command -v claude >/dev/null 2>&1; then
    # 命令可用，直接可以使用
    printf "${colorBright}${colorGreen}║  ${colorYellow}1.${colorReset} ${colorWhite}运行认证命令：${colorReset}               ${colorReset}\n"
    printf "${colorBright}${colorGreen}║     ${colorCyan}claude${colorReset} ${colorMagenta}(按提示输入邮箱和密码)${colorReset}           ${colorReset}\n"
    printf "${colorBright}${colorGreen}║                                                                                    ${colorReset}\n"
    printf "${colorBright}${colorGreen}║  ${colorYellow}2.${colorReset} ${colorWhite}开始使用定制版 Claude Code！${colorReset}  ${colorReset}\n"
else
    # 命令不可用，需要重新加载环境
    printf "${colorBright}${colorGreen}║  ${colorYellow}1.${colorReset} ${colorWhite}重新加载环境变量：${colorReset}           ${colorReset}\n"
    if [[ "$SHELL" == *"zsh"* ]]; then
        printf "${colorBright}${colorGreen}║     ${colorCyan}source ~/.zshrc${colorReset}                                   ${colorReset}\n"
    else
        printf "${colorBright}${colorGreen}║     ${colorCyan}source ~/.bashrc${colorReset}                                  ${colorReset}\n"
    fi
    printf "${colorBright}${colorGreen}║                                                                                    ${colorReset}\n"
    printf "${colorBright}${colorGreen}║  ${colorYellow}2.${colorReset} ${colorWhite}或者重新打开终端${colorReset}             ${colorReset}\n"
    printf "${colorBright}${colorGreen}║                                                                                    ${colorReset}\n"
    printf "${colorBright}${colorGreen}║  ${colorYellow}3.${colorReset} ${colorWhite}运行认证命令：${colorReset}               ${colorReset}\n"
    printf "${colorBright}${colorGreen}║     ${colorCyan}claude${colorReset} ${colorMagenta}(按提示输入邮箱和密码)${colorReset}           ${colorReset}\n"
    printf "${colorBright}${colorGreen}║                                                                                    ${colorReset}\n"
    printf "${colorBright}${colorGreen}║  ${colorYellow}4.${colorReset} ${colorWhite}开始使用定制版 Claude Code！${colorReset}  ${colorReset}\n"
fi
printf "${colorBright}${colorGreen}║                                                                                    ${colorReset}\n"
printf "${colorBright}${colorGreen}╚════════════════════════════════════════════════════════════════════════════════════╝${colorReset}\n"
printf "\n"
