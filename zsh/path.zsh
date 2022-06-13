# prefer gnu tools
if (( $+commands[brew] )); then
  path=($(brew --prefix)/opt/{{coreutils,gawk,gnu-indent,gnu-sed,gnu-tar,grep,make}/libexec/gnubin,curl/bin} $path)
fi

if (( $+commands[go] )); then
  path=($(go env GOPATH)/bin $path)
fi

fpath=(
  ~/.zsh/completion
  ~/.zsh/functions
  ~/.asdf/completions
  ~/.nix-profile/share/zsh/site-functions
  $fpath
)

