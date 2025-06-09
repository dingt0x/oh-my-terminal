# linux 初始化
1. 安装keepassxc
    ```bash
    sudo apt install keepassxc
    ```
2. 安装基础软件包
    ```bash
    sudo apt update
    for p in vim wget git; do
        sudo apt install -y $p
    done
    ```
3.  Install zsh
    ```bash
    sudo apt instal zsh
    ```
4. 安装oh-my-zsh
    ```bash
    wget -O /tmp/install.sh https://gh-proxy.com/raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh
    #sed -i 's|REMOTE=${REMOTE:-https://github.com/${REPO}.git}|REMOTE=${REMOTE:-https://gh-proxy.com/github.com/${REPO}.git}|' \ 
   #    /tmp/install.sh
   export REPO=${REPO:-ohmyzsh/ohmyzsh}
   export REMOTE=https://gh-proxy.com/github.com/${REPO}.git
   sh /tmp/install.sh
   ```