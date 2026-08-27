#!/usr/bin/env bats
# shellcheck disable=SC2154 # Bats defines these variables.

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
EOF
  chmod +x "$TEST_DIR/bin/open" "$TEST_DIR/bin/pandoc"

  PATH="$TEST_DIR/bin:/usr/bin:/bin"
  TMPDIR="$TEST_DIR/tmp"
  export PATH TMPDIR
  unset MDPREVIEW_THEME XDG_CONFIG_HOME
}

# Prints the pandoc argument that follows the given flag.
pandoc_arg_after() {
  grep -A1 -Fx -- "$1" "$PANDOC_ARGS_FILE" | tail -n 1
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

@test "reads Markdown from stdin" {
  run "$MDPREVIEW" <<<'# Standard input'

  [ "$status" -eq 0 ]
  output_path=$(<"$OPEN_PATH_FILE")
  [ "${output_path##*/}" = 'stdin.html' ]
  grep -Fqx -- 'pagetitle=stdin.md' "$PANDOC_ARGS_FILE"
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
  run "$MDPREVIEW" --theme nope <<<'# Heading'

  [ "$status" -eq 2 ]
  [ "$output" = 'mdpreview: unknown theme: nope' ]
  [ ! -e "$OPEN_PATH_FILE" ]
}

@test "rejects --theme without a value" {
  run "$MDPREVIEW" --theme

  [ "$status" -eq 2 ]
  [ "$output" = 'Usage: mdpreview [--theme THEME] [MARKDOWN_FILE|-]' ]
  [ ! -e "$OPEN_PATH_FILE" ]
}

@test "rejects extra arguments" {
  run "$MDPREVIEW" first.md second.md

  [ "$status" -eq 2 ]
  [ "$output" = 'Usage: mdpreview [--theme THEME] [MARKDOWN_FILE|-]' ]
  [ ! -e "$OPEN_PATH_FILE" ]
}
