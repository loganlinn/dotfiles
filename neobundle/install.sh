#!/bin/sh
# Standalone installer for Unixs
# Original version is created by shoma2da
# https://github.com/shoma2da/neobundle_installer

# Installation directory
BUNDLE_DIR=~/.vim/bundle
INSTALL_DIR="$BUNDLE_DIR/neobundle.vim"
echo "$INSTALL_DIR"
if [ -e "$INSTALL_DIR" ]; then
  echo "$INSTALL_DIR already exists!"
fi

NVIM_DIR=~/.config/nvim
NVIM_BUNDLE_DIR="$NVIM_DIR/bundle"
NVIM_INSTALL_DIR="$NVIM_BUNDLE_DIR/neobundle.vim"

# make bundle dir and fetch neobundle
echo "› installing neobundle (vim package manager)"
if ! [ -e "$INSTALL_DIR" ]; then
  mkdir -p "$BUNDLE_DIR"
  git clone --depth 1 https://github.com/Shougo/neobundle.vim "$INSTALL_DIR"
fi

if type nvim > /dev/null 2>&1 && ! [ -e "$NVIM_INSTALL_DIR" ]; then
  mkdir -p "$NVIM_BUNDLE_DIR"
  git clone --depth 1 https://github.com/Shougo/neobundle.vim "$NVIM_INSTALL_DIR"
fi
