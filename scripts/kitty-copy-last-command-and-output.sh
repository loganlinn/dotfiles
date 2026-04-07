#!/bin/sh
# Prepend last command to its output and write to stdout.
# Invoked by kitty: launch --stdin-source=@last_cmd_output --type=clipboard
# Kitty handles the clipboard; this script just transforms stdin→stdout.
set -eu

output=$(cat)
cmd=$(kitten @ ls 2>/dev/null \
  | jq -r '[.[].tabs[].windows[] | select(.is_focused)] | first | .last_reported_cmdline // empty') || true

if [ -n "${cmd:-}" ]; then
  printf '$ %s\n%s\n' "$cmd" "$output"
else
  printf '%s\n' "$output"
fi
