#!/usr/bin/env bash
set -euo pipefail

# Claude Sessions Actions for Television
# Usage: claude-sessions-tv-action.sh <action> <session_id>

export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

SESSIONS_JSON=/tmp/claude_sessions_tv.json
action="${1:-}"
session_id="${2:-}"

if [[ -z "$session_id" || ! -f "$SESSIONS_JSON" ]]; then
  echo >&2 "No session data or session_id"
  exit 1
fi

get_field() {
  jq -r --arg id "$1" --arg field "$2" '.[] | select(.session_id == $id) | .[$field] // empty' "$SESSIONS_JSON"
}

case "$action" in
focus)
  window_id=$(get_field "$session_id" "kitty_window_id")
  [[ -n "$window_id" ]] && kitty @ focus-window -m id:"$window_id"
  ;;
transcript)
  transcript=$(get_field "$session_id" "session_transcript_path")
  if [[ -n "$transcript" && -f "$transcript" ]]; then
    if command -v bat &>/dev/null; then
      bat --language=json "$transcript"
    else
      less "$transcript"
    fi
  else
    echo "No transcript available"
    read -r -p "Press enter..."
  fi
  ;;
tail)
  transcript=$(get_field "$session_id" "session_transcript_path")
  if [[ -n "$transcript" && -f "$transcript" ]]; then
    tail -f "$transcript" | jq -r '
      select(.type == "human" or .type == "assistant" or .type == "user") |
      if .type == "human" or .type == "user" then
        "\n▶ USER:\n" + (.message.content // "" | if type == "array" then .[0].text // "" else . end)
      else
        "\n◀ CLAUDE:\n" + (.message.content // "" | if type == "array" then .[0].text // "" else . end)
      end
    '
  else
    echo "No transcript available"
    read -r -p "Press enter..."
  fi
  ;;
edit)
  transcript=$(get_field "$session_id" "session_transcript_path")
  if [[ -n "$transcript" && -f "$transcript" ]]; then
    ${EDITOR:-vim} "$transcript"
  else
    echo "No transcript available"
    read -r -p "Press enter..."
  fi
  ;;
cd)
  cwd=$(get_field "$session_id" "cwd")
  [[ -n "$cwd" && -d "$cwd" ]] && kitty @ launch --type=tab --cwd="$cwd"
  ;;
copy)
  full_id=$(get_field "$session_id" "full_session_id")
  if command -v pbcopy &>/dev/null; then
    echo -n "$full_id" | pbcopy
    echo "Copied: $full_id"
  elif command -v xclip &>/dev/null; then
    echo -n "$full_id" | xclip -selection clipboard
    echo "Copied: $full_id"
  fi
  sleep 0.3
  ;;
json)
  jq --arg id "$session_id" '.[] | select(.session_id == $id)' "$SESSIONS_JSON" | jless
  ;;
*)
  echo >&2 "Unknown action: $action"
  exit 1
  ;;
esac
