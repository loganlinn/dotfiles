function gs {
  if (($#)) && [[ ! -e $1 ]]; then
    if [[ -n $GIT_SPICE_GITHUB_TOKEN ]]; then
      env GITHUB_TOKEN="$GIT_SPICE_GITHUB_TOKEN" command gs "$@"
    else
      env -u GITHUB_TOKEN command gs "$@"
    fi
  else
    git status
    # local max_lines=${LINES:-$(tput lines)}
    # max_lines=$((max_lines - 5))

    # local status_output=$(git -c color.status=always status)
    # local status_lines=$(wc -l <<<"$status_output" | tr -d ' ')

    # echo -e "$status_output"

    # if [[ $status_lines -gt $max_lines ]]; then
    #   bat <<<"$status_output"
    # fi
  fi
}
