{
  config,
  lib,
  pkgs,
  ...
}: {
  home-manager.sharedModules = lib.singleton (
    {pkgs, ...}: {
      home.shellAliases = {
        pbj = "pbpipe jq";
        pbedit = "pbpipe vipe";
        pwdc = "pwd | pbcopy";
        cdp = ''cd -- "$(pbp)"'';
        uuidc = "uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\\n' | pbcopy";
      };

      programs.zsh = {
        initContent = ''
          pbtee() { tee >(pbcopy); }
          pbcopyenv() { printenv "$@" | pbcopy; }
          pbpasteenv() { export "''${1?}"="$(pbpaste)"; }
          pbpastecd() { local f=$(pbpaste); [[ ! -f $f ]] || f=$(dirname "$f"); cd "$f"; }
          pbpastejq() { pbpaste | jq "$@"; }
          pbjq() { local d; if d=$(pbpaste | jq "$@"); then pbcopy <<<"$d"; fi; }
          cdd() { cd "$(dirname "$1")"; }
          cddd() { cd "$(dirname "$(dirname "$1")")"; }
          opened() { open "$(dirname "''${1?}")"; }

          function pbpipe() {
            emulate -L zsh
            setopt pipe_fail
            local output
            output=$(pbpaste | "$@") || return
            if [[ -z $output ]]; then
              printf >&2 "error: '%s': output was empty, clipboard not modified.\n" "$*"
              return 1
            fi
            <<<"$output" pee pbcopy cat
          }

          function copyenv() {
            printenv "$@" | pbcopy
          }
          compdef copyenv=printenv

          function copyexport() {
            export -p "$@" | pbcopy
          }
          compdef copyexport=export
        '';
      };
    }
  );
}
