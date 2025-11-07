#!/usr/bin/env sh

kitty @ focus-window "$@" 2>/dev/null || kitty @ launch --type=window "$@"
