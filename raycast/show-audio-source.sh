#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Show audio source
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔊
# @raycast.packageName System

# Documentation:
# @raycast.author Logan Linn
# @raycast.authorURL https://github.com/loganlinn

# Uses https://github.com/deweller/switchaudio-osx

if ! hash SwitchAudioSource; then
  echo >&2 "Please install SwitchAudioSource via 'brew install switchaudio-osx' or by visiting 'https://github.com/deweller/switchaudio-osx'"
  exit 127
fi

SwitchAudioSource -c
