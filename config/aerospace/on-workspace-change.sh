#!/usr/bin/env bash

# $AEROSPACE_FOCUSED_WORKSPACE
# $AEROSPACE_PREV_WORKSPACE

# Configuration variables
: "${DATE_FORMAT:=%Y-%m-%d %H:%M:%S}"

log() { printf '[%s] %s\n' "$(date +"$DATE_FORMAT")" "$*"; }

is_workspace_empty() {
  test 0 -eq "$(aerospace list-windows --workspace "${1:-focused}" --count)"
}
