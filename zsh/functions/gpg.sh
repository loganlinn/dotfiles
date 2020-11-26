#!/usr/bin/env sh

gpg_restart() {
  pkill gpg
  pkill pinentry
  pkill ssh-agent
  eval "$(gpg-agent --daemon --enable-ssh-support)"
}
