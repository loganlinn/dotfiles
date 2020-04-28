# -*- mode: zsh; -*-

# creates
function venv-here {
  direnv status 1>/dev/null && eval "$(direnv stdlib)" || return

  cat >> .envrc << 'EOF'

layout pyenv-virtualenv $(basename $PWD)
EOF

  direnv allow .
}
