#!/usr/bin/env bash

_echo_info(){
    local m=${1:-""}
  echo -e "\033[0;31m _____  _     _            _
|_   _|| |   (_)          | |
  | |  | |__  _  ___  __ _| |_
  | |  | '_ \| |/ _ \/ _\` | __|
  | |  | | | | |  __/ (_| | |_
  \_/  |_| |_|_|\___|\__,_|\__| ${m}\033[0m"
}


ssh_add() {
    T_OUT="/dev/null"
    if [ "$T_DEBUG" = "true" ]; then
        T_OUT="/dev/stdout"
    fi

    if [ -f "$HOME/.ssh/id_rsa" ]; then
        if  ! ssh-add -l |grep -q "$HOME/.ssh/id_rsa"; then
            chmod 0600 "${HOME}/.ssh/id_rsa"
            ssh-add "${HOME}/.ssh/id_rsa" > "$T_OUT"
        fi
    fi

    if [ -f "$HOME/.ssh/keys/tianwei.ding/id_rsa" ]; then
        if  ! ssh-add -l |grep -q "$HOME/.ssh/keys/tianwei.ding/id_rsa"; then
            chmod 0600 "$HOME/.ssh/keys/tianwei.ding/id_rsa"
            ssh-add "$HOME/.ssh/keys/tianwei.ding/id_rsa" > "$T_OUT"
        fi
    fi
}

SSH_CONNECTION=${SSH_CONNECTION:-""}
INTELLIJ_ENVIRONMENT_READER=${INTELLIJ_ENVIRONMENT_READER:-""}
SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-""}

if [ -n "$SSH_CONNECTION" ]; then
    echo "Connection from ${SSH_CONNECTION%% *}"
    exit
fi

if [ ! -S "$SSH_AUTH_SOCK" ]; then
    echo "ssh-agent NOT found"
    _echo_info "> ssh-agent NOT found"
    exit
fi

ssh_add
