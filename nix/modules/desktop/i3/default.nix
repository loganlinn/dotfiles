{ config, lib, pkgs, ... }@ctx:

with lib;

let

  cfg = config.modules.desktop.i3;

in
{
  imports = [ ./i3.nix ];

  options.modules.desktop.i3 = {
    enable = mkEnableOption "i3 window manager";
  };

  config = mkIf cfg.enable {

    xsession.enable = true;

    xsession.windowManager.i3.enable = true;

    home.packages = with pkgs;
      [
        i3-layout-manager
        (pkgs.callPackage ../../../pkgs/i3-balance-workspace.nix { })
        (writeShellApplication {
          name = "i3-next-workspace";
          runtimeInputs = [ pkgs.jq ];
          text = ''
            function next_workspace_num() {
              local i=1
              while read -r ws; do
                if (( i != ws )); then
                  echo $i
                  return
                fi
                i=$((i+1))
              done < <(i3-msg -t get_workspaces | jq '.[] | .num')
              echo $i
            }

            i3-msg workspace "$(next_workspace_num)"
          '';
        })
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
