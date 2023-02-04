{ config, lib, pkgs, ... }@ctx:

with lib;

let

  cfg = config.modules.desktop.i3;

in
{
  options.modules.desktop.i3 = {

    enable = mkEnableOption "i3 window manager";

  };

  config = mkIf cfg.enable {

    xsession.enable = true;

    xsession.windowManager.i3 = import ./i3.nix ctx;

    # i3 scripts
    home.packages = with pkgs;
      [
        i3-layout-manager
        (import ../../../pkgs/i3-balance-workspace.nix pkgs)
      ] ++ (
        # Create shell script for each i3-msg message type
        # i.e. `i3-config`, `i3-marks`, `i3-outputs`, etc
        forEach [ "config" "marks" "outputs" "tree" "workspaces" ] (type:
          writeShellApplication {
            name = "i3-${type}";
            runtimeInputs = [ ];
            text = ''
              exec i3-msg -t get_${type} "$@"
            '';
          })
      );
  };
}
