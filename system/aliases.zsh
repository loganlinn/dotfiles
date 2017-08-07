# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if which gls &>/dev/null
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
else
  alias ls="ls"
  alias l="ls -al"
  alias ll="ls -l"
fi

#alias genctags='ctags -R --sort=yes --verbose --languages=+PHP,-JavaScript --PHP-kinds=+cf --exclude=@$HOME/.ctags.exclude'
alias tmux='TERM=xterm-256color tmux'
#alias cljsbuild="lein trampoline cljsbuild $@"
alias g='gradlew'
