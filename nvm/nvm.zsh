# Defer initialization of nvm until nvm, node or a node-dependent command is
# run. Ensure this block is only run once if .bashrc gets sourced multiple times
# by checking whether __init_nvm is a function.
# [ source: https://www.growingwiththeweb.com/2018/01/slow-nvm-init.html ]
if [ -s "$HOME/.nvm/nvm.sh" ] && [ ! "$(whence -w __init_nvm)" = "__init_nvm: function" ]; then
  export NVM_DIR="$HOME/.nvm"
  declare -a __node_commands=('nvm' 'node' 'npm' 'npx' 'yarn' 'gulp' 'grunt' 'webpack' 'lerna' 'oclif' 'serverless')
  function __init_nvm() {
    for i in "${__node_commands[@]}"; do unalias $i; done
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    unset __node_commands
    unset -f __init_nvm
  }
  for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done
fi
