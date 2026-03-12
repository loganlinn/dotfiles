#!/usr/bin/env bash
set -euo pipefail
set -x

# Ensure nix-installed tools are in PATH (kitty launch uses minimal PATH)
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

# Claude Sessions Viewer for Kitty Terminal
# Mini-TUI using fzf with preview pane

NOW=$(date +%s)
SESSIONS_JSON=/tmp/claude_sessions.json
PREVIEW_SCRIPT=/tmp/claude_sessions_preview.sh

# Collect session data
kitty @ ls | jq --argjson now "$NOW" '
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

# Enrich with transcript stats (lines, last activity, model)
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

# Helper: get session field by session_id
get_field() {
  jq -r --arg id "$1" --arg field "$2" '.[] | select(.session_id == $id) | .[$field] // empty' "$SESSIONS_JSON"
}

# Create preview script (runs in fzf subprocess)
cat >"$PREVIEW_SCRIPT" <<'PREVIEW_EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

SESSIONS_JSON=/tmp/claude_sessions.json
session_id="$1"
session=$(jq -r --arg id "$session_id" '.[] | select(.session_id == $id)' "$SESSIONS_JSON")

# Session properties table using gum
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

echo ""
echo "KEYBINDS: enter=focus  t=transcript  T=tail  e=edit  c=cd  y=copy-id  j=json"
echo ""

transcript=$(echo "$session" | jq -r '.session_transcript_path // empty')
if [[ -n "$transcript" && -f "$transcript" ]]; then
  echo "RECENT TRANSCRIPT"
  echo "─────────────────"
  tail -100 "$transcript" | jq -r '
    select(.type == "human" or .type == "assistant" or .type == "user") |
    if .type == "human" or .type == "user" then
      "▶ USER: " + (.message.content // "[no content]" | if type == "array" then .[0].text // "[complex]" else . end | .[0:300])
    else
      "◀ CLAUDE: " + (.message.content // "[no content]" | if type == "array" then .[0].text // "[complex]" else . end | .[0:300])
    end
  ' 2>/dev/null | tail -30
else
  echo "(no transcript available)"
fi
PREVIEW_EOF
chmod +x "$PREVIEW_SCRIPT"

# Generate fzf input: status | title | duration | idle | model | lines | session_id(hidden)
fzf_input() {
  jq -r '.[] |
    (if .awaiting_permission then "⏳" elif .focused then "🔵" elif .active then "🟢" else "⚪" end) + "\t" +
    .title + "\t" +
    .duration + "\t" +
    "↻" + .idle + "\t" +
    (.model // "-") + "\t" +
    "\(.transcript_lines)L\t" +
    .session_id
  ' "$SESSIONS_JSON"
}

# Dispatch actions
dispatch() {
  local action="$1" session_id="$2"

  case "$action" in
  enter | "")
    # Focus kitty window
    local window_id
    window_id=$(get_field "$session_id" "kitty_window_id")
    [[ -n "$window_id" ]] && kitty @ focus-window -m id:"$window_id"
    ;;
  t)
    # Open transcript in pager
    local transcript
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
  T)
    # Tail transcript live
    local transcript
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
  e)
    # Edit transcript in $EDITOR
    local transcript
    transcript=$(get_field "$session_id" "session_transcript_path")
    if [[ -n "$transcript" && -f "$transcript" ]]; then
      ${EDITOR:-vim} "$transcript"
    else
      echo "No transcript available"
      read -r -p "Press enter..."
    fi
    ;;
  c)
    # Open cwd in new kitty tab
    local cwd
    cwd=$(get_field "$session_id" "cwd")
    [[ -n "$cwd" && -d "$cwd" ]] && kitty @ launch --type=tab --cwd="$cwd"
    ;;
  y)
    # Copy session ID to clipboard
    local full_id
    full_id=$(get_field "$session_id" "full_session_id")
    if command -v pbcopy &>/dev/null; then
      echo -n "$full_id" | pbcopy
      echo "Copied: $full_id"
    elif command -v xclip &>/dev/null; then
      echo -n "$full_id" | xclip -selection clipboard
      echo "Copied: $full_id"
    fi
    sleep 0.5
    ;;
  j)
    # View session JSON in jless
    jq --arg id "$session_id" '.[] | select(.session_id == $id)' "$SESSIONS_JSON" | jless
    ;;
  esac
}

HEADER="  ⏳=wait 🔵=focus 🟢=active │ enter=focus t=transcript T=tail e=edit c=cd y=copy j=json"

# Main loop - re-run fzf after non-exit actions
while true; do
  result=$(
    fzf_input | fzf \
      --ansi \
      --header="$HEADER" \
      --preview="$PREVIEW_SCRIPT {7}" \
      --preview-window=right:55%:wrap \
      --delimiter='\t' \
      --with-nth=1,2,3,4,5,6 \
      --tabstop=2 \
      --expect=enter,t,T,e,c,y,j \
      --bind='q:abort' \
      --bind='esc:abort'
  ) || break

  # Parse result: first line is key pressed, second line is selected item
  action=$(echo "$result" | head -1)
  selection=$(echo "$result" | tail -1)

  [[ -z "$selection" ]] && break

  session_id=$(echo "$selection" | cut -f7)

  # Actions that exit the loop
  if [[ "$action" == "enter" || "$action" == "" ]]; then
    dispatch "$action" "$session_id"
    break
  fi

  # Actions that return to fzf
  dispatch "$action" "$session_id"
done
