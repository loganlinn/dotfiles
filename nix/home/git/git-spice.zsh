function gs {
  if [[ -n ${1-} ]] && [[ ! -e $1 ]]; then
    (
      if [[ -n $GIT_SPICE_GITHUB_TOKEN ]]; then
        export GITHUB_TOKEN="$GIT_SPICE_GITHUB_TOKEN"
      fi
      command git spice "$@"
    )
  else
    git status
  fi
}
