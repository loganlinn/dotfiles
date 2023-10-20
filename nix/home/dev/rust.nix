{ config, lib, pkgs, ... }:

with lib;

{
  # home.packages = with pkgs; [
  #   rustup
  # ];

  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [
    "${config.xdg.dataHome}/cargo/bin"
  ];
}
