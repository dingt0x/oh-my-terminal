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

for plugin_dir in "${custom_cwd}/plugins"/*; do
    plugin=$(basename "$plugin_dir")
    dst="${ZSH_CUSTOM}/plugins/${plugin}"

    if [ -e "$dst" ]; then
        rm -rf "$dst"
    fi

    cp -r "$plugin_dir" "$dst"

    echo "Sync $plugin_dir"
done

#if [ -d "${custom_cwd}/lib" ]; then
#    dst="$ZSH_CUSTOM/lib"
#    if [ -e  "$dst" ]; then rm -rf "$dst" ;fi
#    cp -r "${custom_cwd}/lib" "$ZSH_CUSTOM/lib"
#    echo "Sync ${custom_cwd}/lib"
#fi


for rc_file in "${custom_cwd}"/*.zsh; do
    cp "${rc_file}" "$ZSH_CUSTOM/"
done