{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in
{
  config = {
    home.packages = mkIf isLinux [
      (pkgs.writeShellApplication {
        name = "pbcopy";
        runtimeInputs = with pkgs; [ xclip ];
        text = ''xclip -in -selection clipboard'';
      })
      (pkgs.writeShellApplication {
        name = "pbpaste";
        runtimeInputs = with pkgs; [ xclip ];
        text = ''xclip -out -selection clipboard'';
      })
    ];
  };
}
