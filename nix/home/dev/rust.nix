{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    rustup
    jetbrains.rust-rover
    # cargo-cross
  ];

  home.sessionVariables = lib.optionalAttrs config.xdg.enable {
    RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";
  };

  home.sessionPath = lib.optional config.xdg.enable "$CARGO_HOME/bin";
}
