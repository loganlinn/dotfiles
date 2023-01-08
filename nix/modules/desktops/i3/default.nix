{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.desktops.i3;
in {
  options.modules.desktops.i3 = {
    enable = mkEnableOption "Enable i3 desktop environment";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ xfce.thunar ];

    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];

    programs.dconf.enable = true;

    services.tumbler.enable =
      mkDefault true; # thunar thumbnail support for images

    services.gvfs.enable =
      mkDefault true; # thunar mount, trash, and other functionalities

    services.xserver.enable = true;

    services.xserver.autorun = true;

    services.xserver.displayManager = {
      lightdm.enable = true;
      defaultSession = "none+xsession";
      autoLogin.enable = true;
      autoLogin.user = "logan";
    };

    services.xserver.windowManager = {
      session = singleton {
        name = "xsession";
        start = pkgs.writeScript "xsession" ''
          #!${pkgs.runtimeShell}
          if test -f "$HOME/.xsession"; then
            exec ${pkgs.runtimeShell} -c "$HOME/.xsession"
          else
            echo >&2 "No $HOME/.xsession script found!"
            echo >&2 "This window manager session expects 'xsession.enable = true' in home-manager configuration."
            echo >&2 "See for additional details: https://rycee.gitlab.io/home-manager/index.html#sec-usage-graphical"
            exit 1
          fi
        '';
      };
    };
  };
}
