#!/usr/bin/env bash

: "${GRAALVM_RELEASE:=latest}"
: "${GRAALVM_ROOT:=${XDG_DATA_HOME:-$HOME/.local/share}/graalvm}"
: "${GRAALVM_INSTALL_JAVA:=java11}"  # TODO inspect system
: "${GRAALVM_INSTALL_OS:=linux}" # TODO inspect system
: "${GRAALVM_INSTALL_ARCH:=amd64}" # TODO inspect system

export GRAALVM_11_ROOT="$GRAALVM_ROOT"/graalvm-ce-java11

latest_release_info() {
  curl -s https://api.github.com/repos/graalvm/graalvm-ce-builds/releases/latest 
}

asset_name_regex() {
  printf '%s-%s-%s.+\.tar\.gz' \
    "${GRAALVM_INSTALL_JAVA?}" \
    "${GRAALVM_INSTALL_OS}" \
    "${GRAALVM_INSTALL_ARCH}"
}

select_download_urls() {
  jq -r --arg asset_name_regex "$(asset_name_regex)" '
    .assets[] |
      select(.name | test($asset_name_regex)) |
        .browser_download_url'
}

download_urls() {
  xargs curl -sSL --remote-name-all
}

create_env() {
  local output_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/graalvm

  mkdir -p "$output_dir"
  cat - <<EOF > "$output_dir"/env
#!/bin/sh

GRAALVM_VERSION=21.3.0
GRAALVM_HOME="$HOME/.local/opt/graalvm-ce-java11-${GRAALVM_VERSION}"

# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
*:"$GRAALVM_HOME/bin":*) ;;
*) PATH="$GRAALVM_HOME/bin:$PATH" ;;
esac

export PATH GRAALVM_HOME
EOF
}

latest_release_info | select_download_urls | download_urls

# curl -L -o "$release_url" "/tmp" "graalvm-archive.tar.gz"
# mkdir $GRAALVM_ROOT
# tar -xzf "/tmp/graalvm-archive.tar.gz" -C $GRAALVM_ROOT
#
# # Set environment variable for GraalVM root
# setEtcEnvironmentVariable "GRAALVM_11_ROOT" $GRAALVM_11_ROOT
#
# # Install Native Image
# $GRAALVM_11_ROOT/bin/gu install native-image
#
# invoke_tests "Tools" "GraalVM"
