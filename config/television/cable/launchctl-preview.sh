#!/usr/bin/env bash
set -euo pipefail

label="$1"
uid=$(id -u)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Try gui domain first, then user domain
output=$(launchctl print "gui/${uid}/${label}" 2>/dev/null) ||
	output=$(launchctl print "user/${uid}/${label}" 2>/dev/null) ||
	{ echo -e "${RED}Service not found${RESET}"; exit 1; }

# Parse key fields
get_value() {
	echo "$output" | grep -E "^\s+$1 = " | head -1 | sed "s/.*= //"
}

get_block() {
	# Extract a block like "arguments = { ... }"
	echo "$output" | awk -v key="$1" '
		$0 ~ "^[[:space:]]+" key " = \\{" { found=1; next }
		found && /^[[:space:]]+\}/ { found=0; next }
		found { print }
	'
}

state=$(get_value "state")
path=$(get_value "path")
type=$(get_value "type")
program=$(get_value "program")
pid=$(get_value "pid")
runs=$(get_value "runs")
last_exit=$(get_value "last exit code")
active_count=$(get_value "active count")
exit_timeout=$(get_value "exit timeout")

# Status color
case "$state" in
	running) state_color="${GREEN}${BOLD}running${RESET}" ;;
	waiting) state_color="${YELLOW}waiting${RESET}" ;;
	*) state_color="${RED}${state:-unknown}${RESET}" ;;
esac

# Header
echo -e "${BOLD}${CYAN}[service]${RESET}"
echo -e "  ${DIM}label${RESET} = ${BOLD}${label}${RESET}"
echo -e "  ${DIM}state${RESET} = ${state_color}"
[[ -n "$pid" ]] && echo -e "  ${DIM}pid${RESET} = ${MAGENTA}${pid}${RESET}"
[[ -n "$type" ]] && echo -e "  ${DIM}type${RESET} = ${type}"

echo ""
echo -e "${BOLD}${CYAN}[plist]${RESET}"
[[ -n "$path" ]] && echo -e "  ${DIM}path${RESET} = ${path}"

echo ""
echo -e "${BOLD}${CYAN}[execution]${RESET}"
[[ -n "$program" ]] && echo -e "  ${DIM}program${RESET} = ${program}"

args=$(get_block "arguments")
if [[ -n "$args" ]]; then
	echo -e "  ${DIM}arguments${RESET} = ["
	echo "$args" | while read -r arg; do
		arg=$(echo "$arg" | sed 's/^[[:space:]]*//')
		[[ -n "$arg" ]] && echo -e "    ${YELLOW}\"${arg}\"${RESET}"
	done
	echo "  ]"
fi

echo ""
echo -e "${BOLD}${CYAN}[stats]${RESET}"
[[ -n "$runs" ]] && echo -e "  ${DIM}runs${RESET} = ${runs}"
[[ -n "$last_exit" ]] && {
	if [[ "$last_exit" == "0" ]]; then
		echo -e "  ${DIM}last_exit_code${RESET} = ${GREEN}${last_exit}${RESET}"
	else
		echo -e "  ${DIM}last_exit_code${RESET} = ${RED}${last_exit}${RESET}"
	fi
}
[[ -n "$active_count" ]] && echo -e "  ${DIM}active_count${RESET} = ${active_count}"
[[ -n "$exit_timeout" ]] && echo -e "  ${DIM}exit_timeout${RESET} = ${exit_timeout}s"

# Environment
env_block=$(get_block "environment")
if [[ -n "$env_block" ]]; then
	echo ""
	echo -e "${BOLD}${CYAN}[environment]${RESET}"
	echo "$env_block" | while read -r line; do
		line=$(echo "$line" | sed 's/^[[:space:]]*//')
		if [[ "$line" =~ ^([A-Z_]+)[[:space:]]*'=>'[[:space:]]*(.*)$ ]]; then
			key="${BASH_REMATCH[1]}"
			val="${BASH_REMATCH[2]}"
			echo -e "  ${DIM}${key}${RESET} = ${val}"
		fi
	done
fi

# Keepalive/triggers
keepalive=$(echo "$output" | grep -E "keep alive" | head -1 | sed 's/.*= //' || true)
if [[ -n "$keepalive" ]]; then
	echo ""
	echo -e "${BOLD}${CYAN}[keepalive]${RESET}"
	echo -e "  ${DIM}enabled${RESET} = ${keepalive}"
fi
