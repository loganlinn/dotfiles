# @name conda-shell
# @decription setup current shell to use anaconda
conda-shell() {
  __pyenv_version=$(pyenv whence conda)
  __conda_home="$HOME/.pyenv/versions/$__pyenv_version"
  __conda_setup="$("$__conda_home/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"

  pyenv shell "$__pyenv_version"

  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "$__conda_home/etc/profile.d/conda.sh" ]; then
          source "$__conda_home/etc/profile.d/conda.sh"
      else
          export PATH="$__conda_home/bin:$PATH"
      fi
  fi
  unset __conda_setup
  unset __conda_home
  unset __pyenv_version
}
