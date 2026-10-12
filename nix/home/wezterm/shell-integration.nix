{
  config,
  lib,
  ...
}: let
  shellIntegration = ''
    if [[ "''${TERM_PROGRAM-}" == "WezTerm" ]]; then
      source "${config.programs.wezterm.package}/etc/profile.d/wezterm.sh"
    fi
  '';
in {
  config = lib.mkIf config.programs.wezterm.enable {
    # Home Manager's automatic integration also runs in other terminals.
    programs.wezterm = {
      enableBashIntegration = false;
      enableZshIntegration = false;
    };

    programs.bash.initExtra = lib.mkIf config.programs.bash.enable (lib.mkAfter shellIntegration);
    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable (lib.mkAfter shellIntegration);
  };
}
