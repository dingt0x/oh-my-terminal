#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf "\033[31m%s\033[0m\n" "错误: 请使用 'source <file>' 或 '. <file>' 加载此文件，而不是直接执行" >&2
    exit 1
fi

if [ -z "$OMT" ]; then
    printf "\033[31m%s\033[0m\n" "OMT NOT FOUND"
    return
fi


load_files="
${OMT}/load/_load_path.sh
"
echo "$load_files" | while read -r load_file; do
    if [ "${load_file:0:1}" = "" ] || [ "${load_file:0:1}" = "#" ]; then
         continue
    fi

    if [ -f "$load_file" ] && [ -s "$load_file" ]; then
        # shellcheck source=/dev/null
        source "$load_file"
    fi
done
unset load_file
unset load_files


#load rc.d and function.d files
for rcfile in "${OMT}/function.d"/* "${OMT}/rc.d"/* ; do
    if { [ "${rcfile: -3}" = ".rc" ] ||  [ "${rcfile: -3}" = ".sh" ] || [ "${rcfile: -4}" = ".zsh" ] ; } \
      && [ -s "$rcfile" ]  ; then
      # shellcheck source=/dev/null
      . "${rcfile}"
    fi
done
unset rcfile


is_plugin() {
  local base_dir=$1
  local name=$2
  builtin test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || builtin test -f $base_dir/plugins/$name/_$name
}



for plugin in "${plugins[@]}"; do
  if is_plugin "$ZSH_CUSTOM" "$plugin"; then
    fpath=("$ZSH_CUSTOM/plugins/$plugin" $fpath)
  elif is_plugin "$ZSH" "$plugin"; then
    fpath=("$ZSH/plugins/$plugin" $fpath)
  else
    echo "[oh-my-zsh] plugin '$plugin' not found"
  fi
done



# Load the theme
is_theme() {
  local base_dir=$1
  local name=$2
  builtin test -f $base_dir/$name.zsh-theme
}

ZSH_THEME=${ZSH_THEME:-"dingt0xavit"}

if [[ -n "$ZSH_THEME" ]]; then
  if is_theme "$ZSH_CUSTOM" "$ZSH_THEME"; then
    source "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme"
  elif is_theme "$ZSH_CUSTOM/themes" "$ZSH_THEME"; then
    source "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme"
  elif is_theme "$OMT/themes" "$ZSH_THEME"; then
    source "$OMT/themes/$ZSH_THEME.zsh-theme"
  else
    echo "[oh-my-zsh] theme '$ZSH_THEME' not found"
  fi
fi

for entry_file in "${OMT}/entry"/*; do
    if [ "${entry_file: -3}" = ".sh" ] && [ -s "$entry_file" ]  ; then
       bash "${entry_file}"
    fi
done

unset entry_file

