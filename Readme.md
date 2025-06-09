# oh-my-terminal


## 环境组件安装

### krew 安装
```bash
Install krew : https://krew.sigs.k8s.io/docs/user-guide/setup/install/
install plugin
- ns
(
  export gh_proxy="https://gh-proxy.com/"
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "${gh_proxy}https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```

### zsh-autosuggestions
```bash
$(
# mkdir -p ${HOME}/.zsh/
# cd  ${HOME}/.zsh/
cd ~/.oh-my-zsh/custom/plugins/
git clone --depth 1 ${gh_proxy}https://github.com/zsh-users/zsh-autosuggestions
)
```

### zsh-history-substring-search
```bash
$(
# mkdir -p ${HOME}/.zsh/
# cd  ${HOME}/.zsh/
cd ~/.oh-my-zsh/custom/plugins/
git clone --depth 1 ${gh_proxy}https://github.com/zsh-users/zsh-history-substring-search
)
```

### zsh-syntax-highlighting
```bash
$(
# mkdir -p ${HOME}/.zsh/
# cd  ${HOME}/.zsh/
cd ~/.oh-my-zsh/custom/plugins/
git clone --depth 1 ${gh_proxy}https://github.com/zsh-users/zsh-syntax-highlighting
)

```

### fzf
```bash
repo="https://github.com/junegunn/fzf.git"
git clone --depth 1 "${gh_proxy}${repo}" ~/.oh-my-zsh/custom/plugins/fzf
# exec ~/zsh/fzf/./install or script as follows
~/.oh-my-zsh/custom/plugins/fzf/install --bin
cat << 'EOF' > ~/.fzf.zsh
# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/dingtianwei/.zsh/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/dingtianwei/.oh-my-zsh/custom/plugins/fzf/bin"
fi
source <(fzf --zsh)
EOF

```

###  auto-jump

```bash
brew install auto-jump
# or 
sudo apt install autojump
```

###  iterm2_shell_integration.zsh

```bash
curl -L https://iterm2.com/shell_integration/zsh -o ${HOME}/.iterm2_shell_integration.zsh
```

### miniconda3

```bash
# install 
curl -s https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh 
```
