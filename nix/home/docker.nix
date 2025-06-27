{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "docker-rm" ''
      docker images |
      ${fzf}/bin/fzf --multi --header-lines=1 --accept-nth=3 |
      ${findutils}/bin/xargs docker rmi "$@"
    '')
  ];
}
