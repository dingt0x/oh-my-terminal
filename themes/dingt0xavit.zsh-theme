# ===== Prompt Configuration =====
autoload -U colors && colors

# 更健壮的 git_prompt_info 函数
function dingt0x_git_prompt_info() {
  local ref dirty
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    ref=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
    if [[ -n "$(git status --porcelain --ignore-submodules 2>/dev/null)" ]]; then
      dirty="%F{red} ✗%f"
    else
      dirty="%F{green} ✔%f"
    fi
    echo "%F{blue}(%F{green}${ref}%F{blue})${dirty}"
  fi
}

# 更可靠的 SSH 检测
if [[ -n "$SSH_CONNECTION" ]]; then
  local_ip=$(echo $SSH_CONNECTION | awk '{print $3}')
  dingt0x_hostname="%F{red}[${local_ip}]%f "
else
  hostname=""
fi

# 设置 PROMPT 变量（关键修复）
setopt PROMPT_SUBST  # 允许在提示符中使用变量和函数
PROMPT='${dingt0x_hostname}%F{cyan}%~%f $(dingt0x_git_prompt_info)'
PROMPT+=$'\n'
PROMPT+='%(?.%F{green}$%f.%F{red}$%f) '

# 可选：右侧提示显示时间
# RPROMPT='%F{yellow}%*%f'
