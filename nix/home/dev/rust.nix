{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  home.packages = with pkgs; [
    openssl
    pkg-config
    rustup
    # (fenix.complete.withComponents [
    #   # https://rust-lang.github.io/rustup/concepts/components.html
    #   "cargo"
    #   "clippy"
    #   "rust-docs"
    #   "rust-src"
    #   "rustc"
    #   "rustfmt"
    # ])
    # rust-analyzer-nightly
  ];

  home.sessionVariables = {
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
  };

  home.sessionPath = [
    "${config.xdg.dataHome}/cargo/bin"
  ];
}
