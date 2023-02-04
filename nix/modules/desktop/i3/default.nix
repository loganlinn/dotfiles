{ config, lib, pkgs, ... }:

with lib;

let

  i3wmCfg = config.xsession.windowManager.i3;
  cfg = config.modules.desktop.i3;

in
{
  options.modules.desktop.i3 = { enable = mkEnableOption "i3 window manager"; };

  config = mkIf cfg.enable {

    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        config = import ./i3-config.nix { inherit config lib pkgs; };
      };
    };

    home.packages = with pkgs;
      [
        i3-layout-manager
        (writeShellApplication {
          name = "i3-draw";
          runtimeInputs = [ i3wmCfg.package hacksaw ];
          text = ''
            hacksaw -n | {
                IFS=+x read -r w h x y

                w=$((w + w % 2))
                h=$((h + h % 2))

                i3-msg -q floating enable
                i3-msg -q resize set width "$w" px height "$h" px
                i3-msg -q move position "$x" px "$y" px
            }
          '';
        })
      ] ++ (
        # Create shell script for each i3-msg message type
        # i.e. `i3-config`, `i3-marks`, `i3-outputs`, etc
        forEach [ "config" "marks" "outputs" "tree" "workspaces" ] (type:
          writeShellApplication {
            name = "i3-${type}";
            runtimeInputs = [ i3wmCfg.package ];
            text = ''
              exec i3-msg -t get_${type} "$@"
            '';
          })
      );
  };
}
