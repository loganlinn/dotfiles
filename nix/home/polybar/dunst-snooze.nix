{ pkgs ? import <nixpkgs> { }
, dunst ? pkgs.dunst
, dbus ? pkgs.dbus
, ...
}:

pkgs.writeShellApplication {
  name = "dunst-snooze";
  runtimeInputs = [ dunst dbus ];
  text = ''
    case "''${1-}" in
    toggle)
      dunstctl set-paused toggle
      ;;
    esac

    if [[ $(dunstctl is-paused) = "true" ]]; then
      echo "%{B#$COLOR_PAUSED_BG}%{F#$COLOR_PAUSED_FG}   %{B- F-}"
    else
      echo "  "
    fi
  '';
}
