# shellcheck disable=SC2148
#------------------ ALIAS ---------------------#

PATH="${HOME}/.local/bin:${PATH}"

OMT_SCRIPT_D="${OMT}/lib/script.d"
if [ -d "$OMT_SCRIPT_D" ]; then
    for script_file in $(find "$OMT_SCRIPT_D" -type f -name '*.sh');do
        # TODO refactor with sh syntax
        eval "alias ${script_file:t:r}=${script_file}"
    done
fi

unset DINGT0X_SCRIPT_D
unset script_file


alias tmp="cd ${HOME}/tmp"
alias t="cd ${HOME}/tmp"
alias lt='lsof -n -P -i TCP -s TCP:LISTEN'
alias omt="cd \${OMT}"

if command trash > /dev/null 2>&1; then
  alias rm='trash -vF'
fi



export LSCOLORS="Exfxcxdxbxegedabagacad"



