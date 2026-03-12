#!/usr/bin/env bash
set -euo pipefail

# Ensure Nix tools available
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"

usage() {
  cat <<-EOF
		Usage: ${0##*/} [OPTIONS]
		Show CPU/memory usage for kitty tabs, windows, and processes.

		Options:
		  --json         Output raw JSON
		  --sort=MODE    Sort by: cpu, mem, tab (default: tab)
		  --top=N        Show only top N consumers
		  -h, --help     Show this help
	EOF
}

OUTPUT_JSON=false
SORT_MODE=tab
TOP_N=0

while [[ $# -gt 0 ]]; do
  case $1 in
  --json) OUTPUT_JSON=true ;;
  --sort=*) SORT_MODE="${1#--sort=}" ;;
  --top=*) TOP_N="${1#--top=}" ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo >&2 "Unknown option: $1"
    exit 1
    ;;
  esac
  shift
done

# Collect kitty window data with all PIDs
collect_kitty_data() {
  kitty @ ls | jq '[.[].tabs[] | {
		tab_id: .id,
		tab_title: .title,
		is_active: (.windows | any(.is_active)),
		windows: [.windows[] | {
			id,
			title,
			cwd,
			is_active,
			shell_pid: .pid,
			fg_procs: (.foreground_processes // [])
		}]
	}]'
}

# Extract all unique PIDs (shell + foreground processes)
extract_all_pids() {
  jq -r '.[].windows[] | .shell_pid, (.fg_procs[]?.pid // empty)' | sort -u
}

# Get process stats for all PIDs in one call
get_process_stats() {
  local pids="$1"
  [[ -z "$pids" ]] && return
  # ps output: pid, %cpu, %mem, rss (KB), command
  ps -p "$pids" -o pid=,pcpu=,pmem=,rss=,comm= 2>/dev/null || true
}

# Convert KB to human-readable
format_mem() {
  local kb=$1
  if ((kb >= 1048576)); then
    printf "%.1fG" "$(echo "scale=1; $kb / 1048576" | bc)"
  elif ((kb >= 1024)); then
    printf "%.0fM" "$(echo "scale=0; $kb / 1024" | bc)"
  else
    printf "%dK" "$kb"
  fi
}

# Build lookup table: pid -> {cpu, mem, rss, comm}
build_stats_lookup() {
  local ps_output="$1"
  echo "$ps_output" | awk '{
		pid=$1; cpu=$2; mem=$3; rss=$4; comm=$5
		printf "{\"pid\":%d,\"cpu\":%.1f,\"mem\":%.1f,\"rss\":%d,\"comm\":\"%s\"}\n", pid, cpu, mem, rss, comm
	}' | jq -s 'map({(.pid|tostring): .}) | add // {}'
}

# Enrich kitty data with process stats
enrich_data() {
  local kitty_json="$1"
  local stats_lookup="$2"

  echo "$kitty_json" | jq --argjson stats "$stats_lookup" '
		def get_stat(pid): $stats[pid|tostring] // {cpu:0,mem:0,rss:0,comm:"?"};

		[.[] | . as $tab | {
			tab_id,
			tab_title,
			is_active,
			windows: [.windows[] | . as $win |
				($win.fg_procs | map(.pid)) as $fg_pids |
				{
					id,
					title,
					cwd,
					is_active,
					shell: (get_stat($win.shell_pid) + {pid: $win.shell_pid}),
					fg_procs: [.fg_procs[] | get_stat(.pid) + {pid: .pid, cmdline: .cmdline}]
				} |
				# Compute window totals
				.total_cpu = ([.shell.cpu] + [.fg_procs[].cpu] | add) |
				.total_rss = ([.shell.rss] + [.fg_procs[].rss] | add)
			]
		} |
		# Compute tab totals
		.total_cpu = ([.windows[].total_cpu] | add) |
		.total_rss = ([.windows[].total_rss] | add)
		]
	'
}

# Sort enriched data
sort_data() {
  local data="$1"
  local mode="$2"

  case "$mode" in
  cpu)
    echo "$data" | jq 'sort_by(-.total_cpu)'
    ;;
  mem)
    echo "$data" | jq 'sort_by(-.total_rss)'
    ;;
  *)
    echo "$data"
    ;;
  esac
}

# Render human-readable output
render_output() {
  local data="$1"

  echo "$data" | jq -r '.[] | @base64' | while read -r tab_b64; do
    tab=$(echo "$tab_b64" | base64 -d)

    tab_title=$(echo "$tab" | jq -r '.tab_title')
    tab_cpu=$(echo "$tab" | jq -r '.total_cpu')
    tab_rss=$(echo "$tab" | jq -r '.total_rss')
    tab_active=$(echo "$tab" | jq -r '.is_active')

    tab_mem_fmt=$(format_mem "$tab_rss")
    active_marker=""
    [[ "$tab_active" == "true" ]] && active_marker=" ◀"

    printf "\033[1mTAB: %s [%.1f%% | %s]%s\033[0m\n" "$tab_title" "$tab_cpu" "$tab_mem_fmt" "$active_marker"

    echo "$tab" | jq -r '.windows[] | @base64' | while read -r win_b64; do
      win=$(echo "$win_b64" | base64 -d)
      win_active=$(echo "$win" | jq -r '.is_active')

      # Shell process
      shell_pid=$(echo "$win" | jq -r '.shell.pid')
      shell_comm=$(echo "$win" | jq -r '.shell.comm')
      shell_cpu=$(echo "$win" | jq -r '.shell.cpu')
      shell_rss=$(echo "$win" | jq -r '.shell.rss')
      shell_mem_fmt=$(format_mem "$shell_rss")

      printf "  %-30s %5.1f%%  %6s\n" "$shell_comm ($shell_pid)" "$shell_cpu" "$shell_mem_fmt"

      # Foreground processes
      echo "$win" | jq -r '.fg_procs[] | @base64' | while read -r proc_b64; do
        proc=$(echo "$proc_b64" | base64 -d)
        proc_pid=$(echo "$proc" | jq -r '.pid')
        proc_comm=$(echo "$proc" | jq -r '.comm')
        proc_cpu=$(echo "$proc" | jq -r '.cpu')
        proc_rss=$(echo "$proc" | jq -r '.rss')
        proc_mem_fmt=$(format_mem "$proc_rss")

        fg_marker=""
        [[ "$win_active" == "true" ]] && fg_marker="  ◀"
        printf "    %-28s %5.1f%%  %6s%s\n" "$proc_comm ($proc_pid)" "$proc_cpu" "$proc_mem_fmt" "$fg_marker"
      done
    done
    echo
  done

  # Summary
  summary=$(echo "$data" | jq '{
		total_cpu: ([.[].total_cpu] | add),
		total_rss: ([.[].total_rss] | add)
	}')
  sum_cpu=$(echo "$summary" | jq -r '.total_cpu')
  sum_rss=$(echo "$summary" | jq -r '.total_rss')
  sum_mem_fmt=$(format_mem "$sum_rss")

  printf "─%.0s" {1..45}
  printf "\n\033[1mTOTAL: %.1f%% CPU | %s RSS\033[0m\n" "$sum_cpu" "$sum_mem_fmt"
}

main() {
  # Collect data
  kitty_data=$(collect_kitty_data)

  # Extract all PIDs
  all_pids=$(echo "$kitty_data" | extract_all_pids | tr '\n' ',' | sed 's/,$//')

  # Get process stats
  ps_output=$(get_process_stats "$all_pids")

  # Build lookup and enrich
  stats_lookup=$(build_stats_lookup "$ps_output")
  enriched=$(enrich_data "$kitty_data" "$stats_lookup")

  # Sort
  sorted=$(sort_data "$enriched" "$SORT_MODE")

  # Apply --top filter
  if ((TOP_N > 0)); then
    sorted=$(echo "$sorted" | jq ".[0:$TOP_N]")
  fi

  # Output
  if $OUTPUT_JSON; then
    echo "$sorted" | jq .
  else
    render_output "$sorted"
  fi
}

main
