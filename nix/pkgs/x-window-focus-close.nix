{ writeShellApplication
, xdotool
, xorg
, yad
}:

writeShellApplication {
  name = "x-window-focus-close";
  runtimeInputs = [ xdotool xorg.xprop yad ];
  text = ''
    eval "$(xdotool getwindowfocus getwindowgeometry --shell)"
    eval "$(xprop -id "$WINDOW" -f WM_CLASS 8s '=$1\n' -notype WM_CLASS)"
    if yad --image "dialog-question" \
      --align=center \
      --button=yad-no:1 \
      --button=yad-yes:0 \
      --on-top \
      --focus-field=0 \
      --geometry="400x48+$((X + WIDTH / 2 - 200))+$((Y + HEIGHT / 2 - 48))" \
      --text "Close ''${WM_CLASS}?"; then
      xdotool windowclose "$WINDOW"
    fi
  '';
}
