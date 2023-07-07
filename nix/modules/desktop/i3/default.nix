{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.i3;
in
{
  imports = [
    ./config.nix
    ./picom.nix
  ];

  options.modules.desktop.i3 =
    let
      mkStrOptDefault = default: mkOption { type = types.str; inherit default; };
      execType = with types; oneOf [ path str package ];
    in
    {
      keysyms.mod = mkStrOptDefault "Mod4";
      keysyms.alt = mkStrOptDefault "Mod1";
      keysyms.mouseButtonLeft = mkStrOptDefault "button1";
      keysyms.mouseButtonMiddle = mkStrOptDefault "button2";
      keysyms.mouseButtonRight = mkStrOptDefault "button3";
      keysyms.mouseWheelUp = mkStrOptDefault "button4";
      keysyms.mouseWheelDown = mkStrOptDefault "button5";
      keysyms.mouseWheelLeft = mkStrOptDefault "button6";
      keysyms.mouseWheelRight = mkStrOptDefault "button7";

      editor.exec = mkOption {
        type = execType;
      };

      terminal.exec = mkOption {
        type = execType;
        default = "kitty";
      };

      processManager.exec = mkOption {
        type = types.str;
        default =
          if config.programs.btop.enable
          then "${cfg.terminal.exec} --class ProcessManager ${config.programs.btop.package}/bin/btop"
          else if config.programs.bottom.enable
          then "${cfg.terminal.exec} --class ProcessManager ${config.programs.bottom.package}/bin/btm"
          else if config.programs.htop.enable
          then "${cfg.terminal.exec} --class ProcessManager ${config.programs.htop.package}/bin/htop"
          else "${cfg.terminal.exec} --class ProcessManager ${config.programs.proc.package}/bin/top";
      };
    };

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
      ] ++ (
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
