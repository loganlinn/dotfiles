function gs {
  if (( $# )) && [[ ! -e $1 ]]; then
    env GITHUB_TOKEN="$GIT_SPICE_GITHUB_TOKEN" command gs "$@"
  else
    local max_lines=${LINES:-$(tput lines)}
    max_lines=$((max_lines - 5))

    local status_output=$(git -c color.status=always status)
    local status_lines=$(<<<"$status_output" wc -l | tr -d ' ')

    echo -e "$status_output"

    if [[ $status_lines -gt $max_lines ]]; then
      <<<"$status_output" ${PAGER:-less -R}
    fi
  fi
}

