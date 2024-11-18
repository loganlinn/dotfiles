{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.git-town ];
  programs.zsh.initExtraBeforeCompInit = ''
    source <(git-town completions zsh)
  '';
}
