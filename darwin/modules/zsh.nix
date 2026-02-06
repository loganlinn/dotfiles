{
  config,
  lib,
  pkgs,
  ...
}: {
  home-manager.sharedModules = lib.singleton (
    {pkgs, ...}: {
      programs.zsh = {
        shellAliases = {};
        initExtra = ''
          pbtee() { tee >(pbcopy); }
          pbcopyenv() { printenv "$@" | pbcopy; }
          pbpasteenv() { export "''${1?}"="$(pbpaste)"; }
          pbpastecd() { local f=$(pbpaste); [[ ! -f $f ]] || f=$(dirname "$f"); cd "$f"; }
          pbpastejq() { pbpaste | jq "$@"; }
          pbjq() { local d; if d=$(pbpaste | jq "$@"); then pbcopy <<<"$d"; fi; }
          cdd() { cd "$(dirname "$1")"; }
          cddd() { cd "$(dirname "$(dirname "$1")")"; }
          opened() { open "$(dirname "''${1?}")"; }
        '';
      };
    }
  );
}
