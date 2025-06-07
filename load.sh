#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf "\033[31m%s\033[0m\n" "错误: 请使用 'source <file>' 或 '. <file>' 加载此文件，而不是直接执行" >&2
    exit 1
fi

if [ -z "$OMT" ]; then
    printf "\033[31m%s\033[0m\n" "OH_MY_TERMINAL PATH NOT FOUND"
    return
fi


source "${OMT}/_load.sh"

#load rc.d and function.d files
for rcfile in "${OMT}/function.d"/* "${OMT}/rc.d"/*; do
    if { [ "${rcfile: -3}" = ".rc" ] ||  [ "${rcfile: -3}" = ".sh" ]; } \
      && [ -s "$rcfile" ]  ; then
      # shellcheck source=/dev/null
      . "${rcfile}"
    fi
done


for entry_file in "${OMT}/entry"/*; do
    if [ "${entry_file: -3}" = ".sh" ] && [ -s "$entry_file" ]  ; then
       sh "${entry_file}"
    fi
done

