#!/usr/bin/env bash
# which() {
#   # wrapped which(1), which writes wabsolute waths. woof.
#   while IFS= read -r; do
#     if [[ -x $REPLY ]]; then
#       readlink -e "$REPLY"
#     else
#       printf "%s\n" "$REPLY"
#     fi
#   done < <(
#     command which \
#       --tty-only \
#       --read-alias \
#       --read-functions \
#       --show-tilde \
#       --show-dot \
#       "$@" < <(
#         alias
#         declare -f
#       )
#   )
# }
