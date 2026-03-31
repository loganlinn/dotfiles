#!/usr/bin/env bash
set -euo pipefail

# Claude Sessions Source for Television
# Outputs tab-separated: status|title|duration|idle|model|lines|session_id

export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

NOW=$(date +%s)
SESSIONS_JSON=/tmp/claude_sessions_tv.json

# Collect session data from kitty
kitty @ ls 2>/dev/null | jq --argjson now "$NOW" '
[
  .[] as $os_window |
  $os_window.tabs[] as $tab |
  $tab.windows[] |
  select(.user_vars.CLAUDE_SESSION_ID | type == "string" and length > 0) |
  (.created_at / 1000000000 | floor) as $created_epoch |
  ($now - $created_epoch) as $duration_secs |
  {
    session_id: (.user_vars.CLAUDE_SESSION_ID | .[0:8]),
    full_session_id: .user_vars.CLAUDE_SESSION_ID,
    title: .title,
    cwd: ((.user_vars.CLAUDE_SESSION | fromjson? // {}).cwd // .cwd),
    duration: (if $duration_secs >= 3600 then "\($duration_secs / 3600 | floor)h\(($duration_secs % 3600) / 60 | floor)m"
               elif $duration_secs >= 60 then "\($duration_secs / 60 | floor)m"
               else "\($duration_secs)s" end),
    active: .is_active,
    focused: .is_focused,
    awaiting_permission: ((.user_vars.CLAUDE_USER_PROMPT | fromjson? // {}).notification_type == "permission_prompt"),
    kitty_window_id: .id,
    kitty_tab_id: $tab.id,
    os_window_id: $os_window.id,
    session_transcript_path: ((.user_vars.CLAUDE_SESSION | fromjson? // {}).transcript_path // null),
    created_at: (.created_at / 1000000000 | strftime("%Y-%m-%d %H:%M"))
  }
] | sort_by(.created_at) | reverse
' >"$SESSIONS_JSON"

# Enrich with transcript stats
enrich_sessions() {
  local tmp
  tmp=$(mktemp)
  jq -c '.[]' "$SESSIONS_JSON" | while read -r session; do
    transcript=$(echo "$session" | jq -r '.session_transcript_path // empty')
    if [[ -n "$transcript" && -f "$transcript" ]]; then
      lines=$(wc -l <"$transcript" | tr -d ' ')
      last_ts=$(tail -20 "$transcript" | jq -r 'select(.timestamp) | .timestamp' 2>/dev/null | tail -1)
      model=$(grep -o '"model":"[^"]*"' "$transcript" | tail -1 | sed 's/"model":"//;s/"//' | sed 's/claude-//;s/-[0-9]*$//')
      if [[ -n "$last_ts" ]]; then
        last_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${last_ts%%.*}" +%s 2>/dev/null || echo "")
        if [[ -n "$last_epoch" ]]; then
          idle_secs=$((NOW - last_epoch))
          if ((idle_secs >= 3600)); then
            idle="$((idle_secs / 3600))h$((idle_secs % 3600 / 60))m"
          elif ((idle_secs >= 60)); then
            idle="$((idle_secs / 60))m"
          else
            idle="${idle_secs}s"
          fi
        else
          idle="-"
        fi
      else
        idle="-"
      fi
      echo "$session" | jq -c --arg lines "$lines" --arg idle "$idle" --arg model "$model" --arg last_epoch "${last_epoch:-0}" \
        '. + {transcript_lines: ($lines | tonumber), idle: $idle, model: $model, last_activity_epoch: ($last_epoch | tonumber)}'
    else
      echo "$session" | jq -c '. + {transcript_lines: 0, idle: "-", model: "-", last_activity_epoch: 0}'
    fi
  done | jq -s 'sort_by(.last_activity_epoch) | reverse' >"$tmp"
  mv "$tmp" "$SESSIONS_JSON"
}
enrich_sessions

# Output formatted: status  title (truncated)  duration  idle  model  lines  │session_id
# Session ID after │ delimiter for extraction
jq -r '.[] |
  (if .awaiting_permission then "⏳" elif .focused then "🔵" elif .active then "🟢" else "⚪" end) as $status |
  (.title | if length > 30 then .[0:27] + "..." else . end) as $title |
  "\($status)  \($title)│\(.duration)│↻\(.idle)│\(.model // "-")│\(.transcript_lines)L│\(.session_id)"
' "$SESSIONS_JSON" | column -t -s'│'
