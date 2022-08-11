# aliases.zsh
#

alias sudo='nocorrect sudo '

# Expose zsh's `run-help` function for getting help on built-ins.
# First, remove the crappy standard alias run-help=man
(( ! $+aliases[run-help] )) || unalias run-help
autoload -Uz run-help

# Usage:
#   zmv [OPTIONS] oldpattern newpattern
# where oldpattern contains parenthesis surrounding patterns which will
# be replaced in turn by $1, $2, ... in newpattern.  For example,
#   zmv '(*).lis' '$1.txt'
# renames 'foo.lis' to 'foo.txt', 'my.old.stuff.lis' to 'my.old.stuff.txt',
# and so on.  Something simpler (for basic commands) is the -W option:
#   zmv -W '*.lis' '*.txt'
# This does the same thing as the first command, but with automatic conversion
# of the wildcards into the appropriate syntax.  If you combine this with
# noglob, you don't even need to quote the arguments.  For example,
#   alias mmv='noglob zmv -W'
#   mmv *.c.orig orig/*.c
autoload -U zmv
alias zcp='zmv -C'
alias zln='zmv -L'
alias mmv='noglob zmv -W'

#################
## Suffix aliases

if autoload -Uz is-at-least 2>/dev/null && is-at-least 4.2.0; then
  alias -s 1="man -l"
  alias -s 2="man -l"
  alias -s 3="man -l"
  alias -s 4="man -l"
  alias -s 5="man -l"
  alias -s 6="man -l"
  alias -s 7="man -l"

  alias -s jar="java -jar"
  alias -s war="java -jar"
  alias -s deb="sudo dpkg -i"
  alias -s gpg="gpg"

  alias -s config=bat
  alias -s json=jq
  alias -s md=glow
  alias -s org=emacs
  alias -s plist="plutil -p"
  alias -s properties=bat
  alias -s toml=bat
  alias -s txt=bat
  alias -s yaml=bat
  alias -s yml=bat

  alias -s {app, dmg, gif, htm, html, jpg, jpeg, png, gif, mng, pdf, tiff, tif, ttf, xls, xlsx, xpm}=xdg-open

  # archives
  alias -s {zip, tar, tar.gz, tgz, tar.bz2, tb2, tbz, tbz2, tz2}=xdg-open

  # audio + video
  alias -s {ape avi flv m4a mkv mov mp3 mpeg mpg ogg ogm rm wav webm}=${commands[mplayer]:-xdg-open}

  alias -s Dockerfile="docker build - < "
fi
