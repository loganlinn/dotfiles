#!/usr/bin/env bats

setup() {
  MVLN="${BATS_TEST_DIRNAME}/../bin/mvln"
  TMPDIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMPDIR"
}

# --- usage / argument validation ---

@test "shows usage with --help" {
  run "$MVLN" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "fails with no arguments" {
  run "$MVLN"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error:" ]]
}

@test "fails with unknown option" {
  run "$MVLN" --bogus
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error: unknown option" ]]
}

@test "fails with too many arguments" {
  run "$MVLN" a b c
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error: too many arguments" ]]
}

# --- forward mode ---

@test "forward: moves file and creates symlink" {
  echo "hello" > "$TMPDIR/src.txt"

  run "$MVLN" "$TMPDIR/src.txt" "$TMPDIR/dst.txt"
  [ "$status" -eq 0 ]

  # dst is a regular file with correct content
  [ -f "$TMPDIR/dst.txt" ]
  [ "$(cat "$TMPDIR/dst.txt")" = "hello" ]

  # src is now a symlink pointing to dst
  [ -L "$TMPDIR/src.txt" ]
  [ "$(readlink -f "$TMPDIR/src.txt")" = "$(readlink -f "$TMPDIR/dst.txt")" ]
}

@test "forward: creates parent directories" {
  echo "deep" > "$TMPDIR/src.txt"

  run "$MVLN" "$TMPDIR/src.txt" "$TMPDIR/a/b/c/dst.txt"
  [ "$status" -eq 0 ]
  [ -d "$TMPDIR/a/b/c" ]
  [ -f "$TMPDIR/a/b/c/dst.txt" ]
  [ -L "$TMPDIR/src.txt" ]
}

@test "forward: fails if source does not exist" {
  run "$MVLN" "$TMPDIR/nonexistent" "$TMPDIR/dst"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error:" ]]
  [[ "$output" =~ "does not exist" ]]
}

@test "forward: fails if destination exists without --force" {
  echo "src" > "$TMPDIR/src.txt"
  echo "dst" > "$TMPDIR/dst.txt"

  run "$MVLN" "$TMPDIR/src.txt" "$TMPDIR/dst.txt"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error:" ]]
  [[ "$output" =~ "already exists" ]]
}

@test "forward: --force overwrites existing destination" {
  echo "src" > "$TMPDIR/src.txt"
  echo "dst" > "$TMPDIR/dst.txt"

  run "$MVLN" -f "$TMPDIR/src.txt" "$TMPDIR/dst.txt"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR/dst.txt")" = "src" ]
  [ -L "$TMPDIR/src.txt" ]
}

@test "forward: dry-run does not modify filesystem" {
  echo "keep" > "$TMPDIR/src.txt"

  run "$MVLN" -n "$TMPDIR/src.txt" "$TMPDIR/dst.txt"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "[dry run]" ]]

  # nothing changed
  [ -f "$TMPDIR/src.txt" ]
  [ ! -e "$TMPDIR/dst.txt" ]
  [ ! -L "$TMPDIR/src.txt" ]
}

@test "forward: fails when source is already a symlink to destination" {
  echo "real" > "$TMPDIR/dst.txt"
  ln -s "$TMPDIR/dst.txt" "$TMPDIR/src.txt"

  run "$MVLN" -f "$TMPDIR/src.txt" "$TMPDIR/dst.txt"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "already a symlink" ]]

  # nothing destroyed
  [ -L "$TMPDIR/src.txt" ]
  [ -f "$TMPDIR/dst.txt" ]
  [ "$(cat "$TMPDIR/dst.txt")" = "real" ]
}

@test "forward: symlink content is readable through original path" {
  echo "content" > "$TMPDIR/src.txt"

  "$MVLN" "$TMPDIR/src.txt" "$TMPDIR/dst.txt"

  [ "$(cat "$TMPDIR/src.txt")" = "content" ]
}

# --- reverse mode ---

@test "reverse: replaces symlink with target and leaves symlink at target" {
  echo "real" > "$TMPDIR/target.txt"
  ln -s "$TMPDIR/target.txt" "$TMPDIR/link.txt"

  run "$MVLN" -r "$TMPDIR/link.txt"
  [ "$status" -eq 0 ]

  # link is now a regular file
  [ -f "$TMPDIR/link.txt" ]
  [ ! -L "$TMPDIR/link.txt" ]
  [ "$(cat "$TMPDIR/link.txt")" = "real" ]

  # target is now a symlink pointing to link
  [ -L "$TMPDIR/target.txt" ]
  [ "$(readlink -f "$TMPDIR/target.txt")" = "$(readlink -f "$TMPDIR/link.txt")" ]
}

@test "reverse: roundtrip forward then reverse restores original state" {
  echo "original" > "$TMPDIR/file.txt"
  local file_abs
  file_abs="$(cd "$TMPDIR" && pwd)/file.txt"

  # forward: file.txt -> archive/file.txt, file.txt becomes symlink
  "$MVLN" "$TMPDIR/file.txt" "$TMPDIR/archive/file.txt"
  [ -L "$TMPDIR/file.txt" ]
  [ -f "$TMPDIR/archive/file.txt" ]

  # reverse: file.txt becomes real file again, archive/file.txt becomes symlink
  "$MVLN" -r "$TMPDIR/file.txt"
  [ -f "$TMPDIR/file.txt" ]
  [ ! -L "$TMPDIR/file.txt" ]
  [ -L "$TMPDIR/archive/file.txt" ]
  [ "$(cat "$TMPDIR/file.txt")" = "original" ]
  [ "$(cat "$TMPDIR/archive/file.txt")" = "original" ]
}

@test "reverse: fails if argument is not a symlink" {
  echo "regular" > "$TMPDIR/file.txt"

  run "$MVLN" -r "$TMPDIR/file.txt"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error:" ]]
  [[ "$output" =~ "not a symbolic link" ]]
}

@test "reverse: fails on broken symlink" {
  ln -s "$TMPDIR/nonexistent" "$TMPDIR/broken.txt"

  run "$MVLN" -r "$TMPDIR/broken.txt"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error:" ]]
  [[ "$output" =~ "broken symlink" ]]
}

@test "reverse: fails with too many arguments" {
  run "$MVLN" -r a b
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error: --reverse takes exactly one argument" ]]
}

@test "reverse: fails with no arguments" {
  run "$MVLN" -r
  [ "$status" -eq 1 ]
  [[ "$output" =~ "error:" ]]
}

@test "reverse: dry-run does not modify filesystem" {
  echo "real" > "$TMPDIR/target.txt"
  ln -s "$TMPDIR/target.txt" "$TMPDIR/link.txt"

  run "$MVLN" -r -n "$TMPDIR/link.txt"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "[dry run]" ]]

  # nothing changed
  [ -L "$TMPDIR/link.txt" ]
  [ -f "$TMPDIR/target.txt" ]
  [ ! -L "$TMPDIR/target.txt" ]
}

@test "reverse: works with relative symlink targets" {
  echo "content" > "$TMPDIR/real.txt"
  ln -s "real.txt" "$TMPDIR/alias.txt"

  run "$MVLN" -r "$TMPDIR/alias.txt"
  [ "$status" -eq 0 ]

  [ -f "$TMPDIR/alias.txt" ]
  [ ! -L "$TMPDIR/alias.txt" ]
  [ -L "$TMPDIR/real.txt" ]
  [ "$(cat "$TMPDIR/alias.txt")" = "content" ]
  [ "$(cat "$TMPDIR/real.txt")" = "content" ]
}
