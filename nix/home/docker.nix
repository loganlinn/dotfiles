{
  pkgs,
  lib,
  ...
}:
with lib; {
  home.packages = with pkgs; [
    oxker
    (writeShellScriptBin "docker-rm" ''
      docker images |
      ${getExe fzf} --multi --header-lines=1 --accept-nth=3 |
      ${findutils}/bin/xargs docker rmi "$@"
    '')
  ];
}
