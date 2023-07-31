{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.xsession.windowManager.i3;
in
{
  imports = [
    ./config.nix
    ./kitty.nix
    ./picom.nix
  ];

  options = {
    modules.desktop.i3 = {
      keysyms = mapAttrs
        (name: default: mkOption { type = types.singleLineStr; inherit default; })
        {
          mod = "Mod4";
          alt = "Mod1";
          mouseButtonLeft = "button1";
          mouseButtonMiddle = "button2";
          mouseButtonRight = "button3";
          mouseWheelUp = "button4";
          mouseWheelDown = "button5";
          mouseWheelLeft = "button6";
          mouseWheelRight = "button7";
        };
    };
  };

  config = mkIf config.xsession.windowManager.i3.enable {
    xsession.enable = true;

    services.picom.enable = true;

    programs.rofi.enable = true;
    programs.rofi.plugins = [ pkgs.rofi-calc ];

    xsession.windowManager.i3.config.startup = [
      {
        command = getExe pkgs.i3-auto-layout;
        always = true;
        notification = false;
      }
    ];

    home.packages = with pkgs; [
      i3status
      yad # display GTK+ dialogs in shell scripts (fork of zenity)
      libnotify
      ponymix
      rofi-systemd
      i3-layout-manager
      i3-auto-layout
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
