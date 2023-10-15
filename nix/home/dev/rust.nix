{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup
  ] ++ (lib.optional pkgs.stdenv.isLinux jetbrains.rust-rover);

  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [
    "${config.xdg.dataHome}/cargo/bin"
  ];
}
