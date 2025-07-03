# shellcheck disable=SC2148
#------------------ ALIAS ---------------------#

PATH="${HOME}/.local/bin:${PATH}"

DINGT0X_SCRIPT_D="${OMT}/script.d"
if [ -d "$DINGT0X_SCRIPT_D" ]; then
    for script_file in $(find "$DINGT0X_SCRIPT_D" -type f -name '*.sh');do
#        filename_with_ext=$(basename "$dingt0x_script")  # => "example.txt"
#        filename_without_ext="${filename_with_ext%.*}"
        eval "alias ${script_file:t:r}=${script_file}"
    done
fi

unset DINGT0X_SCRIPT_D
unset script_file


alias tmp="cd ${HOME}/tmp"
alias t="cd ${HOME}/tmp"
alias lt='lsof -n -P -i TCP -s TCP:LISTEN'

if command trash > /dev/null 2>&1; then
  alias rm='trash -vF'
fi






