{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./dev.nix
    ./fonts.nix
    ./gh.nix
    ./neovim.nix
    ./pretty.nix
    ./zsh.nix
  ];


  # home.packages = with pkgs; [
  #   nodePackages_latest.graphite-cli
  #   alejandra
  #   babashka
  #   cargo
  #   clj-kondo
  #   clojure
  #   clojure-lsp
  #   cue
  #   cuelsp
  #   delta
  #   direnv
  #   k9s
  #   kubectl
  #   m-cli
  #   qemu
  #   rcm
  #   ripgrep
  #   rlwrap
  #   rnix-lsp
  #   shellcheck
  #   tmux
  #   # visualvm # error: collision between `/nix/store/fl966iylvy7c443j6p2b12ifx8bn0rdy-visualvm-2.1.4/LICENSE.txt' and `/nix/store/w98d37wz9kn4p6qmhhq7spvxc66phmnk-victor-mono-1.5.4/LICENSE.txt'
  #   zsh
  # ];

  home.stateVersion = "22.11";
}
