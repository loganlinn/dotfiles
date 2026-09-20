#!/usr/bin/env bats
# shellcheck disable=SC2154 # Bats defines these variables.

bats_require_minimum_version 1.5.0

setup() {
  REAL_PANDOC=$(command -v pandoc || true)
  REAL_PYTHON=$(command -v python3)
  REAL_RG=$(command -v rg)
  MDPREVIEW="${BATS_TEST_DIRNAME}/../bin/mdpreview"
  TEST_DIR="${BATS_TEST_TMPDIR}/mdpreview"
  mkdir -p "$TEST_DIR"
  TEST_DIR=$(cd "$TEST_DIR" && pwd -P)
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
header=''
while (($#)); do
  case $1 in
  -o)
    out=$2
    shift
    ;;
  -H)
    header=$2
    shift
    ;;
  esac
  shift
done
{
  if [[ -n $header ]]; then cat "$header"; fi
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
  ln -s "$TEST_DIR/bin/open" "$TEST_DIR/bin/xdg-open"
  ln -s "$REAL_PYTHON" "$TEST_DIR/bin/python3"
  ln -s "$REAL_RG" "$TEST_DIR/bin/rg"

  PATH="$TEST_DIR/bin:/usr/bin:/bin"
  TMPDIR="$TEST_DIR/tmp"
  HOME="$TEST_DIR/home"
  XDG_CACHE_HOME="$TEST_DIR/cache"
  export HOME PATH TMPDIR XDG_CACHE_HOME
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
      "$REAL_PYTHON" "$MDPREVIEW" missing.md "$flag"

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
  [ "$output" = "$output_path" ]
  grep -Fqx -- '--' "$PANDOC_ARGS_FILE"
  [ "$(tail -n 1 "$PANDOC_ARGS_FILE")" = "$TEST_DIR/-notes.with.dots.md" ]
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
  [ "$(tail -n 1 "$PANDOC_ARGS_FILE")" = "$TEST_DIR/--help" ]
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

@test "embeds the default theme in the output" {
  run "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  grep -Fq -- '--bg:' "$output_path"
  grep -Fqx -- '-s' "$PANDOC_ARGS_FILE"
  grep -Fqx -- 'highlighting-css=' "$PANDOC_ARGS_FILE"
}

@test "renders dashed section dividers as rules while preserving pipe tables" {
  [[ -n $REAL_PANDOC ]] || skip 'Pandoc is required for the rendering regression.'
  ln -sf "$REAL_PANDOC" "$TEST_DIR/bin/pandoc"

  run "$MDPREVIEW" <<'EOF'
# Table of contents

- [Alpha](#alpha)
- [Beta](#beta)

-----
# <a name="alpha">Alpha</a>

Alpha documentation.

## `read!`
``` clojure
(read! client)
```

-----
# <a name="beta">Beta</a>

Beta documentation.

## `write!`
``` clojure
(write! client)
```

-----

| Operation | Result |
| --- | --- |
| read | value |
EOF

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  [ "$(grep -c '<hr' "$output_path")" -eq 3 ]
  grep -Fq '<h1 id="alpha"><a name="alpha">Alpha</a></h1>' "$output_path"
  grep -Fq '<h1 id="beta"><a name="beta">Beta</a></h1>' "$output_path"
  grep -Fq '(read! client)' "$output_path"
  grep -Fq '(write! client)' "$output_path"
  [ "$(grep -c '<table' "$output_path")" -eq 1 ]
  grep -Fq '<th>Operation</th>' "$output_path"
  grep -Fq '<td>value</td>' "$output_path"
}

@test "links a custom theme file by absolute URL" {
  printf 'body { color: red; }\n' >"$TEST_DIR/custom.css"
  printf '# Heading\n' >"$TEST_DIR/notes.md"
  cd "$TEST_DIR"

  run "$MDPREVIEW" --theme custom.css notes.md

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "file://$TEST_DIR/custom.css" ]
  [ "$(tail -n 1 "$PANDOC_ARGS_FILE")" = "$TEST_DIR/notes.md" ]
}

@test "resolves a named theme from the XDG config directory" {
  XDG_CONFIG_HOME="$TEST_DIR/config"
  export XDG_CONFIG_HOME
  mkdir -p "$XDG_CONFIG_HOME/mdpreview/themes"
  printf 'body { color: blue; }\n' >"$XDG_CONFIG_HOME/mdpreview/themes/ocean.css"

  run "$MDPREVIEW" --theme ocean <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "file://$XDG_CONFIG_HOME/mdpreview/themes/ocean.css" ]
}

@test "uses MDPREVIEW_THEME when --theme is not set" {
  XDG_CONFIG_HOME="$TEST_DIR/config"
  MDPREVIEW_THEME=ocean
  export MDPREVIEW_THEME XDG_CONFIG_HOME
  mkdir -p "$XDG_CONFIG_HOME/mdpreview/themes"
  printf 'body { color: blue; }\n' >"$XDG_CONFIG_HOME/mdpreview/themes/ocean.css"

  run "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "file://$XDG_CONFIG_HOME/mdpreview/themes/ocean.css" ]
}

@test "--theme overrides MDPREVIEW_THEME" {
  printf 'body { color: blue; }\n' >"$TEST_DIR/environment.css"
  printf 'body { color: red; }\n' >"$TEST_DIR/command-line.css"
  MDPREVIEW_THEME="$TEST_DIR/environment.css"
  export MDPREVIEW_THEME

  run "$MDPREVIEW" --theme "$TEST_DIR/command-line.css" <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "file://$TEST_DIR/command-line.css" ]
}

@test "uses HOME for named themes when XDG_CONFIG_HOME is not set" {
  mkdir -p "$HOME/.config/mdpreview/themes"
  printf 'body { color: green; }\n' >"$HOME/.config/mdpreview/themes/forest.css"

  run "$MDPREVIEW" --theme forest.css <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "file://$HOME/.config/mdpreview/themes/forest.css" ]
}

@test "accepts --theme=FILE after the input file" {
  printf 'body { color: red; }\n' >"$TEST_DIR/custom.css"

  run "$MDPREVIEW" - "--theme=$TEST_DIR/custom.css" <<<'# Heading'

  [ "$status" -eq 0 ]
  [ "$(pandoc_arg_after -c)" = "file://$TEST_DIR/custom.css" ]
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
  for flag in --unknown --version --watch -x; do
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

@test "previews a directory recursively" {
  mkdir -p "$TEST_DIR/docs/nested"
  printf '# Nested\n' >"$TEST_DIR/docs/nested/notes.md"
  run --separate-stderr "$MDPREVIEW" "$TEST_DIR/docs"

  [ "$status" -eq 0 ]
  [[ $stderr == *"Scanning $TEST_DIR/docs"* ]]
  [[ $stderr == *'Found 1 Markdown file.'* ]]
  [[ $stderr == *'[1/1] Rendering nested/notes.md'* ]]
  [[ $stderr == *"Preview ready: $output"* ]]
  [[ $stderr == *'Opening preview in the browser.'* ]]
  grep -F 'nested/notes.md' "$output"
  grep -F '<main># Nested' "${output%/*}/pages/nested/notes.md.html"
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
  run --separate-stderr "$MDPREVIEW" - </dev/null

  assert_usage_error
  [[ $stderr == *'empty'* ]]
}

@test "reports an invalid cache directory" {
  mkdir -p "$HOME"
  printf 'not a directory' >"$HOME/Library"
  printf 'not a directory' >"$XDG_CACHE_HOME"

  run --separate-stderr "$MDPREVIEW" <<<'# Heading'

  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ $stderr == mdpreview:* ]]
  [[ $stderr == *'cache directory'* ]]
  [[ $stderr != *'mktemp:'* ]]
  [ ! -e "$PANDOC_ARGS_FILE" ]
  [ ! -e "$OPEN_PATH_FILE" ]
}

@test "reports missing Pandoc with an install instruction" {
  printf '# Heading\n' >"$TEST_DIR/notes.md"

  run --separate-stderr /usr/bin/env PATH="$TEST_DIR/no-commands" \
    "$REAL_PYTHON" "$MDPREVIEW" "$TEST_DIR/notes.md"

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
  log_path=${stderr##*$'\nFull error log: '}
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
