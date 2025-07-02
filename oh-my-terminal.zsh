#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf "\033[31m%s\033[0m\n" "错误: 请使用 'source <file>' 或 '. <file>' 加载此文件，而不是直接执行" >&2
    exit 1
fi


if [ -z "$OMT" ]; then
    printf "\033[31m%s\033[0m\n" "OMT NOT FOUND"
    return
fi


[[ -n "$OMT_CUSTOM" ]] || OMT_CUSTOM="$OMT/custom"
[[ -n "$OMT_CACHE_DIR" ]] || OMT_CACHE_DIR="$HOME/.cache/oh-my-terminal"
[[ -d "$OMT_CACHE_DIR/completions" ]] || mkdir -p "$OMT_CACHE_DIR/completions"


fpath=($OMT/{functions,completions} $OMT_CUSTOM/{functions,completions} $fpath)



autoload -U compaudit compinit zrecompile

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

SHORT_HOST="dingt0x-omt"
ZSH_COMPDUMP="${HOME}/.cache/.zcompdump-${SHORT_HOST}-20250701"

zcompdump_revision="#omz revision: $(builtin cd -q "$OMT"; git rev-parse HEAD 2>/dev/null)"
zcompdump_fpath="#omz fpath: $fpath"

# Delete the zcompdump file if OMZ zcompdump metadata changed
if ! command grep -q -Fx "$zcompdump_revision" "$ZSH_COMPDUMP" 2>/dev/null \
   || ! command grep -q -Fx "$zcompdump_fpath" "$ZSH_COMPDUMP" 2>/dev/null; then
  command rm -f "$ZSH_COMPDUMP"
  zcompdump_refresh=1
fi


if [[ "$ZSH_DISABLE_COMPFIX" != true ]]; then
  source "$OMT/lib/compfix.zsh"
  # Load only from secure directories
  compinit -i -d "$ZSH_COMPDUMP"
  # If completion insecurities exist, warn the user
  handle_completion_insecurities &|
else
  # If the user wants it, load from all found directories
  compinit -u -d "$ZSH_COMPDUMP"
fi

if (( $zcompdump_refresh )) \
  || ! command grep -q -Fx "$zcompdump_revision" "$ZSH_COMPDUMP" 2>/dev/null; then
  # Use `tee` in case the $ZSH_COMPDUMP filename is invalid, to silence the error
  # See https://github.com/ohmyzsh/ohmyzsh/commit/dd1a7269#commitcomment-39003489
  tee -a "$ZSH_COMPDUMP" &>/dev/null <<EOF

$zcompdump_revision
$zcompdump_fpath
EOF
fi

unset zcompdump_revision zcompdump_fpath zcompdump_refresh

# zcompile the completion dump file if the .zwc is older or missing.
if command mkdir "${ZSH_COMPDUMP}.lock" 2>/dev/null; then
  zrecompile -q -p "$ZSH_COMPDUMP"
  command rm -rf "$ZSH_COMPDUMP.zwc.old" "${ZSH_COMPDUMP}.lock"
fi




for plugin in "${plugins[@]}"; do
  if is_plugin "$OMT_CUSTOM" "$plugin"; then
     source "$OMT_CUSTOM/plugins/${plugin}.plugin.zsh."
  elif is_plugin "$ZSH" "$plugin"; then
     source "$OMT/plugins/${plugin}.plugin.zsh."
  fi
done
unset plugin




# Load the theme
is_theme() {
  local base_dir=$1
  local name=$2
  builtin test -f "$base_dir/$name.zsh-theme"
}

OMT_THEME=${ZSH_THEME:-"dingt0xavit"}

if [[ -n "$OMT_THEME" ]]; then
  if is_theme "$OMT_CUSTOM" "$OMT_THEME"; then
    # shellcheck disable=SC1090
    source "$OMT_CUSTOM/$OMT_THEME.zsh-theme"
  elif is_theme "$OMT_CUSTOM/themes" "$OMT_THEME"; then
    # shellcheck disable=SC1090
    source "$OMT_CUSTOM/themes/$OMT_THEME.zsh-theme"
  elif is_theme "$OMT/themes" "$OMT_THEME"; then
    # shellcheck disable=SC1090
    source "$OMT/themes/$OMT_THEME.zsh-theme"
  else
    echo "[oh-my-zsh] theme '$OMT_THEME' not found"
  fi
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



for entry_file in "${OMT}/entry"/*; do
    if [ "${entry_file: -3}" = ".sh" ] && [ -s "$entry_file" ]  ; then
       bash "${entry_file}"
    fi
done

unset entry_file

