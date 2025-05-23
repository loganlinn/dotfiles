{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  writeKittyBin = name: args:
    pkgs.writeShellScriptBin name ''
      exec kitty ${escapeShellArgs (map toString (toList args))} "$@"
    '';

  scratchCommand = direction: let
    width = 42;
    height = 72;
  in
    concatStringsSep ", " [
      "floating enable"
      "resize set width ${toString width} ppt height ${toString height} ppt"
      "move position center"
      (optionalString (direction != null)
        "move ${direction} ${toString (width / 2 + 2)} ppt")
      "move scratchpad"
      "scratchpad show"
    ];
in {
  config = mkIf config.programs.kitty.enable {
    home.packages = [
      (writeKittyBin "kitty-floating" ["--class" "kitty-floating"])
      (writeKittyBin "kitty-left" ["--name" "kitty-left"])
      (writeKittyBin "kitty-right" ["--name" "kitty-right"])
      (writeKittyBin "kitty-scratch" ["--name" "kitty-scratch"])
    ];

    xsession.windowManager.i3.config = {
      terminal = "kitty"; # intentionally avoiding store path here

      window.commands = [
        {
          criteria.class = "kitty-floating";
          command = "floating enable, move position center";
        }
        {
          criteria.title = "^kitty-left$";
          command = scratchCommand "left";
        }
        {
          criteria.title = "^kitty-right$";
          command = scratchCommand "right";
        }
        {
          criteria.title = "^kitty-scratch$";
          command = scratchCommand null;
        }
      ];
    };
  };
}
