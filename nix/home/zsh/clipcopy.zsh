function detect-clipboard() { # https://github.com/ohmyzsh/ohmyzsh/blob/d1c04d8a33f9127d03b69617c5367db5ceebc8a7/lib/clipboard.zsh
  emulate -L zsh
  if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} )); then
    function clipcopy() { cat "${1:-/dev/stdin}" | pbcopy; }
    function clippaste() { pbpaste; }
  elif [[ "${OSTYPE}" == (cygwin|msys)* ]]; then
    function clipcopy() { cat "${1:-/dev/stdin}" > /dev/clipboard; }
    function clippaste() { cat /dev/clipboard; }
  elif (( $+commands[clip.exe] )) && (( $+commands[powershell.exe] )); then
    function clipcopy() { cat "${1:-/dev/stdin}" | clip.exe; }
    function clippaste() { powershell.exe -noprofile -command Get-Clipboard; }
  elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} )); then
    function clipcopy() { cat "${1:-/dev/stdin}" | wl-copy &>/dev/null &|; }
    function clippaste() { wl-paste --no-newline; }
  elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} )); then
    function clipcopy() { cat "${1:-/dev/stdin}" | xsel --clipboard --input; }
    function clippaste() { xsel --clipboard --output; }
  elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} )); then
    function clipcopy() { cat "${1:-/dev/stdin}" | xclip -selection clipboard -in &>/dev/null &|; }
    function clippaste() { xclip -out -selection clipboard; }
  # elif (( ${+commands[lemonade]} )); then
  #   function clipcopy() { cat "${1:-/dev/stdin}" | lemonade copy; }
  #   function clippaste() { lemonade paste; }
  # elif (( ${+commands[doitclient]} )); then
  #   function clipcopy() { cat "${1:-/dev/stdin}" | doitclient wclip; }
  #   function clippaste() { doitclient wclip -r; }
  # elif (( ${+commands[win32yank]} )); then
  #   function clipcopy() { cat "${1:-/dev/stdin}" | win32yank -i; }
  #   function clippaste() { win32yank -o; }
  elif [[ $OSTYPE == linux-android* ]] && (( $+commands[termux-clipboard-set] )); then
    function clipcopy() { cat "${1:-/dev/stdin}" | termux-clipboard-set; }
    function clippaste() { termux-clipboard-get; }
  elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} )); then
    function clipcopy() { tmux load-buffer "${1:--}"; }
    function clippaste() { tmux save-buffer -; }
  else
    function _retry_clipboard_detection_or_fail() {
      local clipcmd="${1}"; shift
      if detect-clipboard; then
        "${clipcmd}" "$@"
      else
        print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
        return 1
      fi
    }
    function clipcopy() { _retry_clipboard_detection_or_fail clipcopy "$@"; }
    function clippaste() { _retry_clipboard_detection_or_fail clippaste "$@"; }
    return 1
  fi
}

function clipcopy clippaste {
  unfunction clipcopy clippaste
  detect-clipboard || true # let one retry
  "$0" "$@"
}

function copybuffer {
  local buf
  if test -z $BUFFER; then
    # line is empty, get the last run command from history
    buf=$(fc -ln -1)
  else
    buf=$BUFFER
  fi
  clipcopy <<<"$buf"
}

zle -N copybuffer

bindkey -M emacs "^Y" copybuffer
bindkey -M viins "^Y" copybuffer
bindkey -M vicmd "^Y" copybuffer
