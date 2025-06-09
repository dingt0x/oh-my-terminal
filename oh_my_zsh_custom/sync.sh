#!/bin/bash

custom_cwd=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"|| exit 1
    pwd -P
)

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

for theme_file in "${custom_cwd}/themes"/*; do
    if [ "${theme_file: -5}" = "theme" ] && [ -s "$theme_file" ]  ; then
        theme_name="$(basename $theme_file)"

        source="$theme_file"
        dst="${ZSH_CUSTOM}/themes/${theme_name}"
        if diff -q "$source" "$dst"; then
            continue
        fi


        echo "Sync $theme_name"
        rm -f "${ZSH_CUSTOM}/themes/${theme_name}"
        cp -f "$theme_file" "${ZSH_CUSTOM}/themes/${theme_name}"
    fi
done