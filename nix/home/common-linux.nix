{ config, lib, pkgs, ... }:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.keyboard = {
      layout = "us";
      options = [ "ctrl:nocaps" "compose:ralt" ];
    };

    home.packages = with pkgs; [
      cached-nix-shell
      sysz
      trash-cli
      xdg-utils
      handlr # better xdg-utils
      (writeShellScriptBin ''capslock'' ''${xdotool} key Caps_Lock'')
      (writeShellScriptBin ''CAPSLOCK'' ''${xdotool} key Caps_Lock'') # just in case ;)
    ];
  };
}
