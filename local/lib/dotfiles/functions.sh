#!/usr/bin/env bash

function command_exists {
  local -r cmd="$1"
  type "$cmd" > /dev/null 2>&1
}

function download_url_to_file {
  local -r url="$1"
  local -r file="$2"
  local -r tmp_path=$(mktemp "/tmp/gruntwork-bootstrap-download-XXXXXX")
  local -r no_sudo="$3"

  echo "Downloading $url to $tmp_path"
  if command_exists "curl"; then
    local -r status_code=$(curl -L -s -w '%{http_code}' -o "$tmp_path" "$url")
    assert_successful_status_code "$status_code" "$url"

    echo "Moving $tmp_path to $file"
    maybe_sudo "$no_sudo" mv -f "$tmp_path" "$file"
  else
    echo "ERROR: curl is not installed. Cannot download $url."
    exit 1
  fi
}

function assert_successful_status_code {
  local -r status_code="$1"
  local -r url="$2"

  if [[ "$status_code" == "200" ]]; then
    echo "Got expected status code 200"
  elif string_starts_with "$url" "file://" && [[ "$status_code" == "000" ]]; then
    echo "Got expected status code 000 for local file URL"
  else
    echo "ERROR: Expected status code 200 but got $status_code when downloading $url"
    exit 1
  fi
}

function string_starts_with {
  local -r str="$1"
  local -r prefix="$2"

  [[ "$str" == "$prefix"* ]]
}

function string_contains {
  local -r str="$1"
  local -r contains="$2"

  [[ "$str" == *"$contains"* ]]
}

# http://stackoverflow.com/a/2264537/483528
function to_lower_case {
  tr '[:upper:]' '[:lower:]'
}

function get_os_name {
  uname | to_lower_case
}

function get_os_arch {
  uname -m
}

function get_os_arch_gox_format {
  local -r arch=$(get_os_arch)

  if string_contains "$arch" "64"; then
    echo "amd64"
  elif string_contains "$arch" "386"; then
    echo "386"
  elif string_contains "$arch" "686"; then
    echo "386" # Not a typo; 686 is also 32-bit and should work with 386 binaries
  elif string_contains "$arch" "arm"; then
    echo "arm"
  fi
}

function download_and_install {
  local -r url="$1"
  local -r install_path="$2"
  local -r no_sudo="$3"

  download_url_to_file "$url" "$install_path" "$no_sudo"
  maybe_sudo "$no_sudo" chmod 0755 "$install_path"
}

