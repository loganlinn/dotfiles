#!/usr/bin/env zsh


if autoload -Uz is-at-least 2>/dev/null && is-at-least 4.2.0; then
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

  # media viewied with (xdg-)open
  alias -s {app, dmg, gif, htm, html, jpg, jpeg, png, gif, mng, pdf, tiff, tif, ttf, xls, xlsx, xpm}=open

  # archives
  alias -s zip="unzip -l"
  alias -s rar="unrar l"
  alias -s tar="tar tf"
  alias -s tar.gz="echo "
  alias -s ace="unace l"

  if (( $+command[mplayer] )); then
    for ft in ape avi flv m4a mkv mov mp3 mpeg mpg ogg ogm rm wav webm; do
      alias -s $ft=mplayer
    done
  fi
fi
