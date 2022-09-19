#!/usr/bin/env sh
set -e

download_dir=$(xdg-user-dir DOWNLOAD)
package_file=$download_dir/code_stable_amd64.deb

mkdir -p "$download_dir"
set -x
curl -fL "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o "$package_file" 
sudo dpkg -i "$package_file"
rm "$package_file"
set +x
exit 0
