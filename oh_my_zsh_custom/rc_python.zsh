if [ -d "${HOME}/miniconda3/bin" ]; then
  if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
      . "${HOME}/miniconda3/etc/profile.d/conda.sh"
  else
      export PATH="/home/dingtianwei/miniconda3/bin:$PATH"
  fi
fi

# if command -v pyenv 1>/dev/null 2>&1; then
#   eval "$(pyenv init -)"
# fi

# if which virtualenvwrapper.sh > /dev/null; then
# if command -v virtualenvwrapper.sh  1>/dev/null 2>&1; then
#   # export WORKON_HOME="$HOME/.virtualenvs"
#   export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
#   export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
# 
#   # shellcheck source=/dev/null
#   source "$(which virtualenvwrapper.sh)"
# fi
# 
# if [ -d "${HOME}/Library/Python/3.9/bin" ]; then
#   export PATH="${HOME}/Library/Python/3.9/bin:${PATH}"
# fi

