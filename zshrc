export PROXY_IP="127.0.0.1"

export GO111MODULE=auto
export GO_VERSION=1.20.14
export NODE_VERSION=22.16.0

export ZSH="$HOME/.oh-my-zsh"
export OMT="${HOME}/Projects/dingtianwei/oh-my-terminal"
export ZSH_CUSTOM="${OMT}/omz_custom"

zstyle ':omz:update' mode disabled
export DISABLE_MAGIC_FUNCTIONS=true
export ZSH_THEME=robbyrussell
# export CASE_SENSITIVE="true"


# shellcheck disable=SC2034
plugins=(git)
plugins=($plugins zsh-autosuggestions history-substring-search zsh-syntax-highlighting)
plugins=($plugins "fzf")
plugins=($plugins "autojump")
plugins=($plugins "terraform")
plugins=($plugins "terragrunt")
plugins=($plugins "kck")
plugins=($plugins "1password" "vagrant")

if [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
    echo "oh my zsh Not found"
else
    source "$ZSH/oh-my-zsh.sh"
fi


[ -f "${OMT}/oh-my-zsh.sh" ] && source "${OMT}/oh-my-zsh.sh"