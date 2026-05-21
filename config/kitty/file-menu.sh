#!/usr/bin/env bash
# Overlay menu for a file path. Invoked via mouse (@selection) or hints kitten.
set -euo pipefail

PROG=${0##*/}
PROG=${PROG%.sh}
LOG=${FILE_MENU_LOG:-${XDG_STATE_HOME:-$HOME/.local/state}/kitty/$PROG.log}
mkdir -p -- "$(dirname -- "$LOG")"
log() { printf '[%s] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >>"$LOG"; }
exec 9>>"$LOG"
BASH_XTRACEFD=9
PS4='+ '
set -x

log "==== invoked: argv=$* pwd=$PWD pid=$$ ===="
log "env: TERM=${TERM:-} KITTY_WINDOW_ID=${KITTY_WINDOW_ID:-} DISPLAY=${DISPLAY:-} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-}"
trap 'log "exit status=$?"' EXIT

# Show a fatal error in the overlay, then exit.
die() {
  log "die: $*"
  kitten ask --type=yesno --message "$*" --default=y >/dev/null 2>&1 || true
  exit 1
}

# Ensure a command is on PATH or die with overlay error.
require() {
  command -v "$1" >/dev/null 2>&1 || die "$PROG: missing required dependency '$1'${2:+ ($2)}"
}

# Pick a clipboard tool now so failures surface before the menu, not after.
pick_clipboard() {
  if command -v pbcopy >/dev/null 2>&1; then echo pbcopy; return; fi
  if [[ -n ${WAYLAND_DISPLAY:-} ]] && command -v wl-copy >/dev/null 2>&1; then echo wl-copy; return; fi
  if [[ -n ${DISPLAY:-} ]] && command -v xclip   >/dev/null 2>&1; then echo xclip;   return; fi
  if [[ -n ${DISPLAY:-} ]] && command -v xsel    >/dev/null 2>&1; then echo xsel;    return; fi
  return 1
}

require jq
require git
CLIP=$(pick_clipboard) || die "$PROG: no clipboard tool found (need pbcopy, wl-copy, xclip, or xsel)"
log "clipboard=$CLIP"

path=${1:?usage: $PROG <path>}

[[ $path = /* ]] || path=$PWD/$path
path=$(realpath -- "$path")

if [[ ! -e $path ]]; then
  kitten ask --type=yesno --message "Not found: $path" --default=n >/dev/null || true
  exit 1
fi

dir=$(dirname -- "$path")
proj=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || echo "$dir")
rel=${path#"$proj"/}

choice=$(kitten ask \
  --type=choices \
  --title "$rel" \
  --message "$(printf 'File: %s\nProj: %s' "$path" "$proj")" \
  -c 'a:copy Absolute path' \
  -c 'p:copy Project path' \
  -c 'c:copy Contents' \
  -c 'i:Insert contents' \
  -c 'w:launch Window here' \
  -c 't:launch Tab here' \
  -c 'd:git Diff' \
  -c 'g:git Add' |
  tr -d '\n')

response=$(jq -r .response <<<"$choice")
items=$(jq -r .items <<<"$choice")

log "response=$response items=$items path=$path proj=$proj rel=$rel"

notify() {
  log "notify: $*"
  kitten notify --icon=document "$PROG" "$1" 2>/dev/null || echo >&2 "$1"
}

clip() {
  case $CLIP in
    pbcopy)  pbcopy ;;
    wl-copy) wl-copy ;;
    xclip)   xclip -selection clipboard ;;
    xsel)    xsel --clipboard --input ;;
  esac
}

# Launch window/tab into the file's directory if it's a regular file.
cwd_for_launch=$path
[[ -d $cwd_for_launch ]] || cwd_for_launch=$dir

case $response in
a)
  printf %s "$path" | clip
  notify "Copied: $path"
  ;;
p)
  printf %s "$rel" | clip
  notify "Copied: $rel"
  ;;
c)
  clip <"$path"
  notify "Copied contents of $rel"
  ;;
i) kitten @ send-text --match state:parent_focused --from-file "$path" ;;
w) kitten @ launch --type=window --cwd="$cwd_for_launch" ;;
t) kitten @ launch --type=tab    --cwd="$cwd_for_launch" ;;
d) kitten @ launch --type=overlay --hold --cwd="$proj" -- git diff -- "$path" ;;
g) git -C "$proj" add -- "$path" && notify "git add $rel" ;;
*) : ;;
esac
