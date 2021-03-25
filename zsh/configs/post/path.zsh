# prefer gnu tools
if (( $+commands[brew] )); then
  path=($(brew --prefix)/opt/{{coreutils,gawk,gnu-indent,gnu-sed,gnu-tar,grep,make}/libexec/gnubin,curl/bin} $path)
fi

path=(
  ~/bin
  ~/.local/bin
  ~/.pyenv/bin
  ~/.cargo/bin
  ~/.krew/bin
  ~/.arkade/bin
  ~/.bash-my-aws
  ~/go/bin
  $path
)

path+=(/usr/local/{s,}bin)
