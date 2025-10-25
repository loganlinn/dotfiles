function git-status {
    local max_lines=${LINES:-$(tput lines)}
    max_lines=$((max_lines - 5))

    local status_output=$(git -c color.status=always status)
    local status_lines=$(wc -l <<<"$status_output" | tr -d ' ')

    echo -e "$status_output"

    if [[ $status_lines -gt $max_lines ]]; then
      less <<<"$status_output"
    fi
}

function gs {
  if (( $# )) && [[ ! -e $1 ]]; then
    env GITHUB_TOKEN="$GIT_SPICE_GITHUB_TOKEN" command gs "$@"
  else
    git-status
  fi
}

