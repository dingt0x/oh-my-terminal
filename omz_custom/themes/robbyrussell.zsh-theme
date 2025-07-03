#PROMPT=$'%{$fg[cyan]%}%B%~%b%{$reset_color%} $(git_prompt_info) \n'
local hostname > /dev/null 2>&1
local local_ip > /dev/null 2>&1
if [[ -n "$SSH_CONNECTION" ]]; then
  local_ip=$(echo ${SSH_CONNECTION} | awk '{print $3}')
  hostname="%{$fg_bold[red]%}($local_ip) " 
else
  hostname=""
fi
local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"
#PROMPT=$'${hostname}%{$fg[yellow]%}%n%{$reset_color%} 🐸 %{$fg[cyan]%}%B%~%b%{$reset_color%} $(git_prompt_info)\n'
PROMPT=$'${hostname} %{$fg[cyan]%}%B%~%b%{$reset_color%} $(git_prompt_info)\n'
PROMPT+="%(?:%{$fg_bold[green]%}\$ %{$reset_color%}:%{$fg_bold[red]%}➜ %{$reset_color%})"

#PROMPT+="%(?:%{$fg_bold[green]%}➜ %{$reset_color%}:%{$fg_bold[red]%}➜ %{$reset_color%})"

# ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
# ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[green]%}"
# ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[red]%}🔞📌"
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[red]%}☄️"
# ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"


# Git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}git:(%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) %{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[blue]%})%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%})%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[blue]%})%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%})%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[blue]%})%{$fg[cyan]%}§ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[blue]%})%{$fg[white]%}◒ "
