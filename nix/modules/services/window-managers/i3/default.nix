{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.xsession.windowManager.i3;

in
{
  # options.xsession.windowManager.i3 = { };

  config = mkIf cfg.enable {
    xsession.windowManager.i3 = mkOptionDefault {
      config = import ./i3-config.nix {
        inherit config lib pkgs;
      };
    };

    home.packages = with pkgs; [
      (import ./i3-draw.nix { inherit pkgs; })
    ];
  };
}
