{ config, lib, pkgs, ... }:

let

  rofi-network-manager = pkgs.fetchFromGitHub {
    owner = "P3rf";
    repo = "rofi-network-manager";
    rev = "19a3780fa3ed072482ac64a4e73167d94b70446b";
    hash = "sha256-sK4q+i6wfg9k/Zjszy4Jf0Yy7dwaDebTV39Fcd3/cQ0=";
  };

in
{
  home.packages = with pkgs; [
    networkmanager
    networkmanagerapplet
    qrencode
    (writeShellScriptBin "rofi-network-manager" ''
      export NOTIFICATIONS=true
      exec ${rofi-network-manager}/rofi-network-manager.sh "$@"
    '')
  ];
}
