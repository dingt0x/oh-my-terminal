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
${OMT}/lib/load/_load_path.sh
"
load_(){
    local load_file
    echo "$load_files" | while read -r load_file; do
        if [ "${load_file:0:1}" = "" ] || [ "${load_file:0:1}" = "#" ]; then
             continue
        fi

        if [ -f "$load_file" ] && [ -s "$load_file" ]; then
            # shellcheck source=/dev/null
            source "$load_file"
        fi
    done
}
load_

unset load_files



#load rc.d and function.d files

#if [ -d "${OMT}/lib/function.d" ] ; then
#    for rcfile in "${OMT}/lib/function.d"/*; do
#    if { [ "${rcfile: -3}" = ".rc" ] ||  [ "${rcfile: -2}" = "sh" ]; } \
#      && [ -s "$rcfile" ]  ; then
#      # shellcheck source=/dev/null
#      . "${rcfile}"
#    fi
#    done
#    unset rcfile
#fi
#
#
#if [ -d "${OMT}/lib/rc.d" ] ; then
#    for rcfile in  "${OMT}/lib/rc.d"/*; do
#    if { [ "${rcfile: -3}" = ".rc" ] ||  [ "${rcfile: -2}" = "sh" ]; } \
#      && [ -s "$rcfile" ]  ; then
#      # shellcheck source=/dev/null
#      . "${rcfile}"
#    fi
#    done
#    unset rcfile
#fi
#


if [ -z "$omt_plugins" ]; then
    omt_plugins=()
fi

#load_omt_plugins(){
#    local to_source=()
#    local fpath_prev=$fpath
#    local plugin
#    local file
#    for plugin in "${omt_plugins[@]}"; do
#        if test -f "${ZSH_CUSTOM}/plugins/${plugin}/${plugin}.plugin.zsh"; then
#            to_source=("${ZSH_CUSTOM}/plugins/${plugin}/${plugin}.plugin.zsh" $to_source)
#            if test -f "${ZSH_CUSTOM}/plugins/${plugin}/_${plugin}"; then
#                fpath=("${ZSH_CUSTOM}/plugins/${plugin}" $fpath)
#            fi
#        else
#          echo "[oh-my-terminal] plugin '$plugin' not found"
#        fi
#    done
#
#    if [ ! "${fpath[1]}" = "${fpath_prev[1]}" ]; then
#        zsh-defer compinit
#    fi
#
#    for file in "${to_source[@]}"; do
#        zsh-defer . "$file"
#    done
#}
#
#load_omt_plugins


#if [ -d "${OMT}/lib/commons" ] ; then
#    for rcfile in  "${OMT}/lib/commons"/*; do
#    if { [ "${rcfile: -3}" = ".rc" ] ||  [ "${rcfile: -2}" = "sh" ]; } \
#      && [ -s "$rcfile" ]  ; then
#      # shellcheck source=/dev/null
#      . "${rcfile}"
#    fi
#    done
#    unset rcfile
#fi

for entry_file in "${OMT}/lib/entry"/*; do
    if [ "${entry_file: -3}" = ".sh" ] && [ -s "$entry_file" ]  ; then
       # bash "${entry_file}" &|
       (sh "${entry_file}" &)
    fi
done
unset entry_file
