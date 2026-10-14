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

setup_picker() {
  export SRC_HOME="$BATS_TEST_TMPDIR/src $1"
  export SRC_GET_HISTORY_FILE="$SRC_HOME/history"
  export CLONE_LOG="$BATS_TEST_TMPDIR/clones"
  export SRC_GIT="$BATS_TEST_TMPDIR/mock-bin/git-clone"
  export PATH="$BATS_TEST_TMPDIR/mock-bin:$PATH"
  unset SRC_GET_NO_HISTORY
  : >"$CLONE_LOG"
  mkdir -p "$BATS_TEST_TMPDIR/mock-bin"
  cat >"$BATS_TEST_TMPDIR/mock-bin/gh" <<'EOF'
#!/usr/bin/env bash
printf '%s\tpublic\n' caddyserver/caddy caddyserver/certmagic
EOF
  cat >"$BATS_TEST_TMPDIR/mock-bin/fzf" <<'EOF'
#!/usr/bin/env bash
cat
exit "${PICKER_EXIT_CODE:-0}"
EOF
  cat >"$SRC_GIT" <<'EOF'
#!/usr/bin/env bash
printf '<%s>' "$@" >>"$CLONE_LOG"
printf '\n' >>"$CLONE_LOG"
[[ ${CLONE_EXIT_CODE:-0} == 0 ]] || exit "$CLONE_EXIT_CODE"
mkdir -p -- "${!#}"
EOF
  cat >"$BATS_TEST_TMPDIR/mock-bin/zoxide" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$BATS_TEST_TMPDIR/mock-bin/"*
}

@test "src-get clones each fzf selection in bash and zsh" {
  for test_shell in bash zsh; do
    setup_picker "$test_shell"
    run "$test_shell" -c '
      source "$1"
      src-get --shallow --path caddyserver || exit
      printf "cwd=%s\n" "$PWD"
    ' _ "$DIR/../bin/src-get"

    assert_success
    assert_output "${SRC_HOME}/github.com/caddyserver/caddy
${SRC_HOME}/github.com/caddyserver/certmagic
cwd=${SRC_HOME}/github.com/caddyserver/certmagic"
    run cat "$CLONE_LOG"
    assert_output "<clone><--depth=1><--progress><--><https://github.com/caddyserver/caddy.git><${SRC_HOME}/github.com/caddyserver/caddy>
<clone><--depth=1><--progress><--><https://github.com/caddyserver/certmagic.git><${SRC_HOME}/github.com/caddyserver/certmagic>"
    run cut -f2 "$SRC_GET_HISTORY_FILE"
    assert_success
    assert_output "${SRC_HOME}/github.com/caddyserver/caddy
${SRC_HOME}/github.com/caddyserver/certmagic"

    # Existing selections should not be cloned again; --no-cd preserves the cwd.
    : >"$CLONE_LOG"
    run "$test_shell" -c '
      source "$1"
      src-get --no-cd --no-path caddyserver || exit
      printf "%s\n" "$PWD"
    ' _ "$DIR/../bin/src-get"
    assert_success
    assert_output "$PWD"
    [ ! -s "$CLONE_LOG" ]
  done
}

@test "src-get does not clone after picker cancellation in bash and zsh" {
  for test_shell in bash zsh; do
    setup_picker "$test_shell"
    export PICKER_EXIT_CODE=130
    run "$test_shell" -c 'source "$1"; src-get caddyserver' _ "$DIR/../bin/src-get"
    assert_failure 130
    assert_output ""
    [ ! -s "$CLONE_LOG" ]
    [ ! -e "$SRC_HOME" ]
  done
}

@test "src-get stops on a failed clone in bash and zsh" {
  for test_shell in bash zsh; do
    setup_picker "$test_shell"
    export CLONE_EXIT_CODE=42
    run "$test_shell" -c 'source "$1"; src-get caddyserver' _ "$DIR/../bin/src-get"
    assert_failure 42
    assert_output ""
    run cat "$CLONE_LOG"
    assert_output "<clone><--progress><--><https://github.com/caddyserver/caddy.git><${SRC_HOME}/github.com/caddyserver/caddy>"
    [ ! -e "$SRC_HOME" ]
  done
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
