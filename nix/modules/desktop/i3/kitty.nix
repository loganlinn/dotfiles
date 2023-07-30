{ config, lib, pkgs, ... }:

with lib;

let

  writeKittyBin = name: args: pkgs.writeShellScriptBin "kitty-${name}" ''
    exec kitty ${escapeShellArgs (map toString (toList args))} "$@"
  '';

in
{
  config = mkIf config.programs.kitty.enable {

    home.packages = [
      (writeKittyBin "floating" [ "--class" "kitty-floating" ])
      (writeKittyBin "left" [ "--name" "kitty-left" "--class" "kitty-floating" ])
      (writeKittyBin "right" [ "--name" "kitty-right" "--class" "kitty-floating" ])
      (writeKittyBin "scratch" [ "--class" "kitty-scratch" "--single-instance" ])

    ];

    xsession.windowManager.i3.config = {
      terminal = "kitty"; # intentionally avoiding store path here
      window.commands = [
        {
          criteria.class = "^kitty-left";
          command = " move scratchpad, scratchpad show, resize set width 36 ppt height 66 ppt, move position center, move left 20 ppt";
        }
        {
          criteria.class = "^kitty-right";
          command = "move scratchpad, scratchpad show, resize set width 36 ppt height 66 ppt, move position center, move right 20 ppt";
        }
      ];
    };
  };
}
