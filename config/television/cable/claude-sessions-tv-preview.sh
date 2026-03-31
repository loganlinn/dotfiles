#!/usr/bin/env bash
set -euo pipefail

# Claude Sessions Preview for Television
# Usage: claude-sessions-tv-preview.sh <session_id>

export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

SESSIONS_JSON=/tmp/claude_sessions_tv.json
session_id="$1"

if [[ ! -f "$SESSIONS_JSON" ]]; then
  echo "No session data available"
  exit 0
fi

session=$(jq -r --arg id "$session_id" '.[] | select(.session_id == $id)' "$SESSIONS_JSON")

if [[ -z "$session" || "$session" == "null" ]]; then
  echo "Session not found: $session_id"
  exit 0
fi

# Session properties table
if command -v gum &>/dev/null; then
  echo "$session" | jq -r '
    "Property,Value",
    "Session ID,\(.full_session_id)",
    "Title,\(.title)",
    "CWD,\(.cwd)",
    "Model,\(.model)",
    "Duration,\(.duration) (idle: \(.idle))",
    "Transcript,\(.transcript_lines) lines",
    "Created,\(.created_at)",
    "Status,active=\(.active) focused=\(.focused) awaiting=\(.awaiting_permission)",
    "Kitty,win=\(.kitty_window_id) tab=\(.kitty_tab_id) os=\(.os_window_id)"
  ' | gum table --print --border=rounded
else
  # Fallback without gum
  echo "$session" | jq -r '
    "─────────────────────────────────────────",
    "Session:    \(.full_session_id)",
    "Title:      \(.title)",
    "CWD:        \(.cwd)",
    "Model:      \(.model)",
    "Duration:   \(.duration) (idle: \(.idle))",
    "Transcript: \(.transcript_lines) lines",
    "Created:    \(.created_at)",
    "Status:     active=\(.active) focused=\(.focused) awaiting=\(.awaiting_permission)",
    "Kitty:      win=\(.kitty_window_id) tab=\(.kitty_tab_id) os=\(.os_window_id)",
    "─────────────────────────────────────────"
  '
fi

echo ""
echo "KEYBINDS: enter=focus  ctrl-t=transcript  ctrl-e=edit  ctrl-c=cd  ctrl-y=copy"
echo ""

transcript=$(echo "$session" | jq -r '.session_transcript_path // empty')
if [[ -n "$transcript" && -f "$transcript" ]]; then
  echo "RECENT TRANSCRIPT"
  echo "─────────────────"
  # Extract user text messages and assistant thinking/text, skip empty tool results
  jq -r '
    select(.type == "user" or .type == "assistant") |
    (.message.content | if type == "array" then
      [.[] | select(.type == "text") | .text] | join(" ")
    else
      . // ""
    end) as $text |
    select($text != "") |
    (if .type == "user" then "▶ " else "◀ " end) + ($text | .[0:200])
  ' "$transcript" 2>/dev/null | tail -25
else
  echo "(no transcript available)"
fi
