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
for rcfile in "${OMT}/lib"/* "${OMT}/function.d"/* "${OMT}/rc.d"/* ; do
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
