{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./i3.nix
    ./picom.nix
  ];

  config = mkIf config.xsession.windowManager.i3.enable {
    xsession.enable = true;
    services.picom.enable = true;
    home.packages = with pkgs;
      [
        i3-layout-manager
        (writeShellScriptBin "i3-layout-manager" ''
          exec ${i3-layout-manager}/bin/layout_manager $@
        '')

        (pkgs.callPackage ./i3-shmlog.nix { })

        (writeShellApplication {
          name = "i3-dump-config";
          runtimeInputs = [ config.programs.jq.package or pkgs.jq ];
          text = ''
            i3-msg --raw --type get_config | jq -r '.included_configs[] | .variable_replaced_contents'
          '';
        })

        (writeShellScriptBin "rofi-i3-msg" ''
          rofi -dmenu \
            -lines 0 \
            -p 'i3-msg: ' \
            -monitor -2 \
            -theme-str 'window { border-color: @red; }' \
            -theme-str 'inputbar { children: [prompt,entry]; }' \
            -theme-str 'entry { placeholder: ""; }' \
            | xargs -r i3-msg
        '')

        (writeShellApplication {
          name = "i3-focused";
          runtimeInputs = [ config.programs.jq.package or pkgs.jq ];
          text = ''
            i3-msg -t get_tree | jq '.. | select(.focused? == true)'
          '';
        })
      ]
      ++ (
        # Create shell script for each i3-msg message type
        # i.e. i3-config, i3-marks, i3-outputs, i3-tree, i3-workspaces
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
