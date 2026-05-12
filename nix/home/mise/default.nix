{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.mise;
in
{
  programs.mise = {
    enable = lib.mkDefault true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  home.shellAliases = lib.mkIf cfg.enable {
    m = "mise";
    mr = "mise run";
    mx = "mise exec";
  };

  programs.zsh.initContent = lib.mkIf cfg.enable ''
    function +mise { eval "$(mise activate zsh "$@")"; }
  '';
}
