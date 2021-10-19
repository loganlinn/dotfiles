if [ -z "$ENV" ] && [ -n "$PATH" ]; then
  case $- in
    *l*) ;;
    *) . ~/.profile >/dev/null ;;
  esac
fi

# see: https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME"/.local/state}

if [[ -e ~/.zshenv.local ]]; then . ~/.zshenv.local; fi
if [[ -e ~/.cargo/env ]]; then . ~/.cargo/env; fi
if [[ -e ~/.nix-profile/etc/profile.d/nix.sh ]]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
