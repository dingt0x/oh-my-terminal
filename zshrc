export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"
export ZSH_THEME=${ZSH_THEME:-robbyrussell}

export CC_FP=pa99word
export PROXY_IP="127.0.0.1"
export GO_VERSION=1.20.14
export GO111MODULE=auto
export DISABLE_MAGIC_FUNCTIONS=true
export CASE_SENSITIVE="true"

export OMT="${HOME}/Projects/dingtianwei/oh-my-terminal"

# autoload -Uz compinit
# compinit

# shellcheck disable=SC2034
plugins=(git iterm2 autojump fzf zsh-autosuggestions history-substring-search zsh-syntax-highlighting 1password vagrant)
export FZF_BASE="${ZSH_CUSTOM}/plugins/fzf"

if [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
    echo "oh my zsh Not found"
else
    source "$ZSH/oh-my-zsh.sh"
fi


[ -f "${OMT}/load.sh" ] && source "${OMT}/load.sh"
