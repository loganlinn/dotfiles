{ config, lib, ... }:
with lib;
let
  cfg = config.my.astronvim;
in
{
  options.my.astronvim = {
    enable = mkEnableOption "astronvim";

    configRepo = mkOption {
      type = types.str;
      description = "The URI of the remote to be cloned to nvim config directory";
      default = "https://github.com/AstroNvim/AstroNvim.git";
    };

    userConfigRepo = mkOption {
      type = types.nullOr types.str;
      description = "The URI of the remote to be cloned to nvim user config directory";
      # default = "https://github.com/${config.my.github.username}/AstroNvim_user.git";
      default = "https://github.com/${config.my.github.username}/AstroNvim_user.git";
    };
  };

  config = mkIf cfg.enable {

    home.activation.astronvim = mkIf (cfg.configRepo != null) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! [[ -d ${config.xdg.configHome}/nvim ]]; then
          run git clone $VERBOSE_ARG --depth 1 "${cfg.configRepo}" "${config.xdg.configHome}/nvim"
          if [[ -d ${config.xdg.dataHome}/nvim ]]; then
            run mv $VERBOSE_ARG "${config.xdg.dataHome}/nvim" "${config.xdg.dataHome}/nvim~"
          fi
          if [[ -d ${config.xdg.stateHome}/nvim ]]; then
            run mv $VERBOSE_ARG "${config.xdg.stateHome}/nvim" "${config.xdg.stateHome}/nvim~"
          fi
        fi
      ''
    );

    home.activation.astronvimUser = mkIf (cfg.userConfigRepo != null) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! [[ -d ${config.xdg.configHome}/astronvim ]]; then
          run git clone $VERBOSE_ARG --depth 1 "${cfg.userConfigRepo}" "${config.xdg.configHome}/astronvim/lua/user"
        fi
      ''
    );
  };
}
