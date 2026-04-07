#!/usr/bin/env bats

setup() {
  GIT_SHUNT="${BATS_TEST_DIRNAME}/../bin/git-shunt"
  TEST_REPO="$(mktemp -d)"
  cd "$TEST_REPO"
  git init --quiet
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "initial" >file.txt
  git add file.txt
  git commit --quiet -m "initial commit"
}

teardown() {
  rm -rf "$TEST_REPO"
}

@test "shows usage with --help" {
  run "$GIT_SHUNT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "usage: git shunt" ]]
}

@test "fails without branch argument" {
  run "$GIT_SHUNT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "branch name required" ]]
}

@test "fails with nothing staged" {
  run "$GIT_SHUNT" side-branch
  [ "$status" -eq 1 ]
  [[ "$output" =~ "nothing staged to commit" ]]
}

@test "fails with unknown option" {
  run "$GIT_SHUNT" --bogus side-branch
  [ "$status" -eq 1 ]
  [[ "$output" =~ "unknown option" ]]
}

@test "commits staged changes to new branch" {
  echo "new content" >new.txt
  git add new.txt

  run "$GIT_SHUNT" side-branch
  [ "$status" -eq 0 ]
  [[ "$output" =~ "created side-branch" ]]

  # new branch exists and contains the file
  git show side-branch:new.txt | grep -q "new content"

  # current branch is unchanged
  [ "$(git branch --show-current)" = "main" ]
  ! git show HEAD:new.txt 2>/dev/null

  # staged changes are cleared
  git diff --cached --quiet
}

@test "files remain in working tree after shunt" {
  echo "wip" >wip.txt
  git add wip.txt

  "$GIT_SHUNT" side-branch
  [ -f wip.txt ]
}

@test "custom commit message with -m" {
  echo "x" >x.txt
  git add x.txt

  "$GIT_SHUNT" -m "my message" side-branch
  run git log -1 --format=%s side-branch
  [ "$output" = "my message" ]
}

@test "custom base with -b" {
  # create a second commit on main
  echo "second" >second.txt
  git add second.txt
  git commit --quiet -m "second commit"
  local first_sha
  first_sha=$(git rev-parse HEAD~1)

  echo "shunted" >shunted.txt
  git add shunted.txt

  "$GIT_SHUNT" -b "$first_sha" side-branch

  # parent of side-branch tip should be the first commit
  run git rev-parse side-branch~1
  [ "$output" = "$first_sha" ]
}

@test "does not modify HEAD commit" {
  local head_before
  head_before=$(git rev-parse HEAD)

  echo "extra" >extra.txt
  git add extra.txt

  "$GIT_SHUNT" side-branch

  [ "$(git rev-parse HEAD)" = "$head_before" ]
}

@test "shunted commit contains only staged changes" {
  # modify existing tracked file (don't stage)
  echo "modified" >file.txt
  # add a new file (stage this one)
  echo "staged" >staged.txt
  git add staged.txt

  "$GIT_SHUNT" side-branch

  # side-branch should have staged.txt
  git show side-branch:staged.txt | grep -q "staged"

  # side-branch should have original file.txt (not the unstaged modification)
  run git show side-branch:file.txt
  [ "$output" = "initial" ]
}
