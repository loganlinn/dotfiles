#!/usr/bin/env bats

msg() { printf >&3 '## msg: %s\n' "$*"; }

setup() {
  load 'test_helper/bats-support/load' # this is required by bats-assert!
  load 'test_helper/bats-assert/load'

  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"

  load "$DIR/../bin/src-get"
}

@test "executable" {
  run command -v src-get
  assert_success
}

@test "loadable" {
  run src-home
  assert_success
}

@test "src-home default" {
  unset SRC_HOME
  run src-home
  assert_output "$HOME/src"
}

@test "src-home repescts SRC_HOME" {
  SRC_HOME=/tmp run src-home
  assert_output "/tmp"
}

@test "src-repo supports github http url" {
  run src-repo 'https://github.com/owner/repo.git'
  assert_output 'https://github.com/owner/repo.git'
}

@test "src-repo supports github webapp url" {
  run src-repo 'https://github.com/owner/repo'
  assert_output 'https://github.com/owner/repo'
}

@test "src-repo supports github implicit http url" {
  run src-repo 'github.com/owner/repo'
  assert_output 'https://github.com/owner/repo'
}

@test "src-repo supports github repo slug" {
  run src-repo owner/repo
  assert_output "https://github.com/owner/repo"
}

@test "src-repo supports gitlab git url" {
  run src-repo "git@gitlab.com:owner/repo.git"
  assert_output "git@gitlab.com:owner/repo.git"
}

@test "src-repo supports gitlab https url" {
  run src-repo "https://gitlab.com/owner/repo.git"
  assert_output "https://gitlab.com/owner/repo.git"
}

@test "src-repo supports gitlab implicit https url" {
  run src-repo "gitlab.com/owner/repo"
  assert_output "https://gitlab.com/owner/repo"
}

@test "src-repo supports sr.ht ssh url" {
  run src-repo 'git@git.sr.ht:~user/repo'
  assert_output 'git@git.sr.ht:~user/repo'
}

@test "src-repo is idempotent" {
  a=$(src-repo owner/repo)
  b=$(src-repo "$a")
  [ "$a" = "$b" ]
}

@test "src-get changes zsh to an existing repo" {
  export SRC_HOME="$BATS_TEST_TMPDIR/src"
  local repo_dir="$SRC_HOME/github.com/owner/repo"
  git init -q "$repo_dir"

  run zsh -c '
    source "$1"
    export SRC_HOME=$2
    export SRC_GET_NO_HISTORY=1
    src-get --no-path owner/repo
    print -r -- "$PWD"
  ' _ "$DIR/../bin/src-get" "$SRC_HOME"

  assert_success
  assert_output "$repo_dir"
}

@test "src-get rejects multiple repos" {
  export SRC_HOME="$BATS_TEST_TMPDIR/src"
  export SRC_GET_NO_HISTORY=1
  mkdir -p "$SRC_HOME/github.com/owner/one" "$SRC_HOME/github.com/owner/two"

  run src-get --no-path owner/one owner/two

  assert_failure
  assert_output "src-get: expected one repository, got 2"
}

@test "src-dir supports github webapp url" {
  SRC_HOME=/tmp run src-dir 'https://github.com/owner/repo'
  assert_output "/tmp/github.com/owner/repo"
}

@test "src-dir supports github http url" {
  run src-dir 'https://github.com/owner/repo.git'
  assert_output "$HOME/src/github.com/owner/repo"
}

@test "src-dir supports implicit http url" {
  SRC_HOME=/tmp run src-dir 'github.com/owner/repo'
  assert_output "/tmp/github.com/owner/repo"
}

@test "src-dir supports git ssh urls" {
  run src-dir 'git@git.sr.ht:~llinn/dotfiles'
  assert_output "$HOME/src/git.sr.ht/~llinn/dotfiles"
}

@test "src-dir respects SRC_HOME" {
  SRC_HOME=/tmp run src-dir 'git@git.sr.ht:~llinn/dotfiles'
  assert_output "/tmp/git.sr.ht/~llinn/dotfiles"
}

@test "src-dir supports gitlab git url" {
  run src-dir "git@gitlab.com:owner/repo.git"
  assert_output "$HOME/src/gitlab.com/owner/repo"
}

@test "src-dir supports gitlab https url" {
  run src-dir "https://gitlab.com/owner/repo.git"
  assert_output "$HOME/src/gitlab.com/owner/repo"
}

@test "src-dir supports gitlab implicit https url" {
  run src-dir "gitlab.com/owner/repo"
  assert_output "$HOME/src/gitlab.com/owner/repo"
}
