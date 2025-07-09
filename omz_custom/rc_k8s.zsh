export KUBECONFIG="${HOME}/.kube/config"


if [ -d "HOME/.krew/bin" ];then
  export PATH="$HOME/.krew/bin:$PATH"
fi

[ -f "${HOME}/.helmrc" ]  && source "${HOME}/.helmrc"

alias k='kubectl'
alias kct='kubectl-ctx'
alias kns='kubectl-ns'
alias kk='kubectl kustomize'
alias kaf='kubectl apply -f'
alias kak='kubectl apply -k'
alias kz='kustomize'
alias kc='kubectl calico'
alias ks='kubectl -n kube-system'
alias krew='kubectl-krew'

if which kubectl > /dev/null 2>&1; then
  shell_name="$(basename $SHELL)"
  if [ "$shell_name" = "zsh" ]; then
    source <(kubectl completion zsh)
  fi
  if [ "$shell_name" = "bash" ]; then
    source  <(kubectl completion bash)
    complete -o default -F __start_kubectl k
  fi
fi