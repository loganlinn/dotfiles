#!/usr/bin/env bats
# shellcheck disable=SC2154 # Bats defines these variables.

bats_require_minimum_version 1.5.0

setup() {
  MDPREVIEW="${BATS_TEST_DIRNAME}/../bin/mdpreview"
  TEST_DIR="${BATS_TEST_TMPDIR}/mdpreview"
  PANDOC_ARGS_FILE="$TEST_DIR/pandoc-args"
  OPEN_PATH_FILE="$TEST_DIR/open-path"
  export OPEN_PATH_FILE PANDOC_ARGS_FILE

  mkdir -p "$TEST_DIR/bin" "$TEST_DIR/tmp"
  cat >"$TEST_DIR/bin/pandoc" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$@" >"$PANDOC_ARGS_FILE"
if [[ ${MDPREVIEW_TEST_PANDOC_STATUS:-0} != 0 ]]; then
  printf 'Cannot convert this document.\nInternal conversion details.\n' >&2
  exit "$MDPREVIEW_TEST_PANDOC_STATUS"
fi
input=${!#}
out=''
while (($#)); do
  case $1 in
  -o)
    out=$2
    shift
    ;;
  esac
  shift
done
{
  printf '<main>'
  cat -- "$input"
  printf '</main>'
} >"$out"
EOF
  cat >"$TEST_DIR/bin/open" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$1" >"$OPEN_PATH_FILE"
if [[ ${MDPREVIEW_TEST_OPEN_STATUS:-0} != 0 ]]; then
  printf 'No browser is available.\nInternal browser details.\n' >&2
  exit "$MDPREVIEW_TEST_OPEN_STATUS"
fi
EOF
  chmod +x "$TEST_DIR/bin/open" "$TEST_DIR/bin/pandoc"

  PATH="$TEST_DIR/bin:/usr/bin:/bin"
  TMPDIR="$TEST_DIR/tmp"
  export PATH TMPDIR
  unset MDPREVIEW_THEME XDG_CONFIG_HOME
  unset MDPREVIEW_TEST_OPEN_STATUS MDPREVIEW_TEST_PANDOC_STATUS
}

# Prints the pandoc argument that follows the given flag.
pandoc_arg_after() {
  grep -A1 -Fx -- "$1" "$PANDOC_ARGS_FILE" | tail -n 1
}

assert_usage_error() {
  [ "$status" -eq 2 ]
  [ -z "$output" ]
  [[ $stderr == mdpreview:* ]]
  [[ $stderr == *'Usage: mdpreview '* ]]
  [[ $stderr == *'mdpreview --help'* ]]
  [ ! -e "$PANDOC_ARGS_FILE" ]
  [ ! -e "$OPEN_PATH_FILE" ]
}

@test "shows help without Pandoc, file validation, or temporary files" {
  for flag in -h --help; do
    run --separate-stderr /usr/bin/env \
      PATH="$TEST_DIR/no-commands" \
      TMPDIR="$TEST_DIR/no-such-directory" \
      MDPREVIEW_THEME="$TEST_DIR/no-such-theme" \
      /bin/bash "$MDPREVIEW" missing.md "$flag"

    [ "$status" -eq 0 ]
    [ -z "$stderr" ]
    [[ $output == *'Usage: mdpreview '* ]]
    [[ $output == *'--help'* ]]
    [[ $output == *'--theme'* ]]
    [[ $output == *'MDPREVIEW_THEME'* ]]
    [[ $output == *'XDG_CONFIG_HOME'* ]]
    [[ $output == *'stdin'* || $output == *'standard input'* ]]
    [ ! -e "$PANDOC_ARGS_FILE" ]
    [ ! -e "$OPEN_PATH_FILE" ]
  done
}

@test "previews an option-like file name" {
  printf '# Heading\n' >"$TEST_DIR/-notes.with.dots.md"
  cd "$TEST_DIR"

  run "$MDPREVIEW" -notes.with.dots.md

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  [ "${output_path##*/}" = '-notes.with.dots.html' ]
  [ "$(pandoc_arg_after -o)" = "$output_path" ]
  grep -Fqx -- '--' "$PANDOC_ARGS_FILE"
  [ "$(tail -n 1 "$PANDOC_ARGS_FILE")" = '-notes.with.dots.md' ]
  grep -Fqx -- 'pagetitle=-notes.with.dots.md' "$PANDOC_ARGS_FILE"
  grep -F '<main># Heading' "$output_path"
}

@test "uses -- to preview a file named after an option" {
  printf '# Heading\n' >"$TEST_DIR/--help"
  cd "$TEST_DIR"

  run "$MDPREVIEW" -- --help

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  [ "${output_path##*/}" = '--help.html' ]
  [ "$(tail -n 1 "$PANDOC_ARGS_FILE")" = '--help' ]
  grep -F '<main># Heading' "$output_path"
}

@test "reads Markdown from stdin" {
  run "$MDPREVIEW" <<<'# Standard input'

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  [ "${output_path##*/}" = 'stdin.html' ]
  grep -Fqx -- 'pagetitle=stdin.md' "$PANDOC_ARGS_FILE"
  grep -F '<main># Standard input' "$output_path"
}

@test "reads Markdown from explicit stdin" {
  run "$MDPREVIEW" - <<<'# Standard input'

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  [ "${output_path##*/}" = 'stdin.html' ]
  grep -F '<main># Standard input' "$output_path"
}

@test "links the embedded default theme next to the output" {
  run "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  theme_path=$(pandoc_arg_after -c)
  [ "$theme_path" = "${output_path%/*}/mdpreview.css" ]
  grep -Fq -- '--bg:' "$theme_path"
  grep -Fqx -- '-s' "$PANDOC_ARGS_FILE"
  grep -Fqx -- 'highlighting-css=' "$PANDOC_ARGS_FILE"
}

@test "links a custom theme file by absolute path" {
  printf 'body { color: red; }\n' >"$TEST_DIR/custom.css"
  printf '# Heading\n' >"$TEST_DIR/notes.md"
  cd "$TEST_DIR"

  run "$MDPREVIEW" --theme custom.css notes.md

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "$TEST_DIR/custom.css" ]
  [ "$(tail -n 1 "$PANDOC_ARGS_FILE")" = 'notes.md' ]
}

@test "resolves a named theme from the XDG config directory" {
  XDG_CONFIG_HOME="$TEST_DIR/config"
  export XDG_CONFIG_HOME
  mkdir -p "$XDG_CONFIG_HOME/mdpreview/themes"
  printf 'body { color: blue; }\n' >"$XDG_CONFIG_HOME/mdpreview/themes/ocean.css"

  run "$MDPREVIEW" --theme ocean <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "$XDG_CONFIG_HOME/mdpreview/themes/ocean.css" ]
}

@test "uses MDPREVIEW_THEME when --theme is not set" {
  XDG_CONFIG_HOME="$TEST_DIR/config"
  MDPREVIEW_THEME=ocean
  export MDPREVIEW_THEME XDG_CONFIG_HOME
  mkdir -p "$XDG_CONFIG_HOME/mdpreview/themes"
  printf 'body { color: blue; }\n' >"$XDG_CONFIG_HOME/mdpreview/themes/ocean.css"

  run "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "$XDG_CONFIG_HOME/mdpreview/themes/ocean.css" ]
}

@test "--theme overrides MDPREVIEW_THEME" {
  printf 'body { color: blue; }\n' >"$TEST_DIR/environment.css"
  printf 'body { color: red; }\n' >"$TEST_DIR/command-line.css"
  MDPREVIEW_THEME="$TEST_DIR/environment.css"
  export MDPREVIEW_THEME

  run "$MDPREVIEW" --theme "$TEST_DIR/command-line.css" <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "$TEST_DIR/command-line.css" ]
}

@test "uses HOME for named themes when XDG_CONFIG_HOME is not set" {
  HOME="$TEST_DIR/home"
  export HOME
  mkdir -p "$HOME/.config/mdpreview/themes"
  printf 'body { color: green; }\n' >"$HOME/.config/mdpreview/themes/forest.css"

  run "$MDPREVIEW" --theme forest.css <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "$HOME/.config/mdpreview/themes/forest.css" ]
}

@test "accepts --theme=FILE after the input file" {
  printf 'body { color: red; }\n' >"$TEST_DIR/custom.css"

  run "$MDPREVIEW" - "--theme=$TEST_DIR/custom.css" <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "$TEST_DIR/custom.css" ]
}

@test "rejects a theme that is not a file" {
  XDG_CONFIG_HOME="$TEST_DIR/config"
  export XDG_CONFIG_HOME

  run --separate-stderr "$MDPREVIEW" --theme nope <<<'# Heading'

  assert_usage_error
  [[ $stderr == *'Theme not found'* ]]
  [[ $stderr == *'nope'* ]]
  [[ $stderr == *"$XDG_CONFIG_HOME/mdpreview/themes"* ]]
}

@test "rejects --theme without a value" {
  run --separate-stderr "$MDPREVIEW" --theme

  assert_usage_error
  [[ $stderr == *'--theme'* ]]
}

@test "rejects empty theme values" {
  run --separate-stderr "$MDPREVIEW" --theme ''

  assert_usage_error
  [[ $stderr == *'--theme'* ]]

  run --separate-stderr "$MDPREVIEW" --theme=

  assert_usage_error
  [[ $stderr == *'--theme'* ]]
}

@test "rejects an option in place of a theme value" {
  for flag in --help --; do
    run --separate-stderr "$MDPREVIEW" --theme "$flag"

    assert_usage_error
    [[ $stderr == *'--theme'* ]]
  done
}

@test "rejects extra arguments" {
  run --separate-stderr "$MDPREVIEW" first.md second.md

  assert_usage_error
  [[ $stderr == *'second.md'* ]]
}

@test "rejects an empty input path" {
  run --separate-stderr "$MDPREVIEW" ''

  assert_usage_error
  [[ $stderr == *'empty'* ]]
}

@test "rejects unknown options" {
  for flag in --unknown --version -x; do
    run --separate-stderr "$MDPREVIEW" "$flag"

    assert_usage_error
    [[ $stderr == *'Unknown option'* ]]
    [[ $stderr == *"$flag"* ]]
  done
}

@test "rejects a missing input file" {
  run --separate-stderr "$MDPREVIEW" "$TEST_DIR/missing.md"

  assert_usage_error
  [[ $stderr == *'not found'* ]]
  [[ $stderr == *"$TEST_DIR/missing.md"* ]]
}

@test "rejects a directory as input" {
  run --separate-stderr "$MDPREVIEW" "$TEST_DIR"

  assert_usage_error
  [[ $stderr == *'directory'* ]]
  [[ $stderr == *"$TEST_DIR"* ]]
}

@test "rejects an unreadable input file" {
  printf '# Heading\n' >"$TEST_DIR/unreadable.md"
  chmod 000 "$TEST_DIR/unreadable.md"
  if [[ -r $TEST_DIR/unreadable.md ]]; then
    skip 'This account can read files with mode 000.'
  fi

  run --separate-stderr "$MDPREVIEW" "$TEST_DIR/unreadable.md"
  chmod 600 "$TEST_DIR/unreadable.md"

  assert_usage_error
  [[ $stderr == *'read'* ]]
  [[ $stderr == *"$TEST_DIR/unreadable.md"* ]]
}

@test "rejects empty stdin" {
  run --separate-stderr "$MDPREVIEW" </dev/null

  assert_usage_error
  [[ $stderr == *'empty'* ]]

  run --separate-stderr "$MDPREVIEW" - </dev/null

  assert_usage_error
  [[ $stderr == *'empty'* ]]
}

@test "reports an invalid temporary directory" {
  TMPDIR="$TEST_DIR/missing-directory"
  export TMPDIR

  run --separate-stderr "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ $stderr == mdpreview:* ]]
  [[ $stderr == *'temporary directory'* ]]
  [[ $stderr == *"$TMPDIR"* ]]
  [[ $stderr != *'mktemp:'* ]]
  [ ! -e "$PANDOC_ARGS_FILE" ]
  [ ! -e "$OPEN_PATH_FILE" ]
}

@test "reports missing Pandoc with an install instruction" {
  printf '# Heading\n' >"$TEST_DIR/notes.md"

  run --separate-stderr /usr/bin/env PATH="$TEST_DIR/no-commands" \
    /bin/bash "$MDPREVIEW" "$TEST_DIR/notes.md"

  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ $stderr == mdpreview:* ]]
  [[ $stderr == *'pandoc'* || $stderr == *'Pandoc'* ]]
  [[ $stderr == *'Install'* || $stderr == *'install'* ]]
  [[ $stderr != *'hash:'* ]]
  [ ! -e "$OPEN_PATH_FILE" ]
}

@test "saves Pandoc errors and does not open the browser" {
  MDPREVIEW_TEST_PANDOC_STATUS=23
  export MDPREVIEW_TEST_PANDOC_STATUS

  run --separate-stderr "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ $stderr == mdpreview:* ]]
  output_path=$(pandoc_arg_after -o)
  log_path=${output_path%/*}/pandoc.log
  [[ $stderr == *"$log_path"* ]]
  grep -Fqx 'Cannot convert this document.' "$log_path"
  grep -Fqx 'Internal conversion details.' "$log_path"
  [[ $stderr != *'Internal conversion details.'* ]]
  [ ! -e "$OPEN_PATH_FILE" ]
}

@test "saves browser errors and reports the HTML path" {
  MDPREVIEW_TEST_OPEN_STATUS=24
  export MDPREVIEW_TEST_OPEN_STATUS

  run --separate-stderr "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ $stderr == mdpreview:* ]]
  output_path=$(<"$OPEN_PATH_FILE")
  log_path=${output_path%/*}/open.log
  [[ $stderr == *"$output_path"* ]]
  [[ $stderr == *"$log_path"* ]]
  grep -F '<main># Heading' "$output_path"
  grep -Fqx 'No browser is available.' "$log_path"
  grep -Fqx 'Internal browser details.' "$log_path"
  [[ $stderr != *'Internal browser details.'* ]]
}
