{pkgs, ...}: {
  imports = [
    ./common.nix
    ./dev.nix
    ./emacs.nix
    ./gh.nix
    ./git.nix
    ./fonts.nix
    ./neovim.nix
    ./pretty.nix
    ./zsh.nix
  ];

  home.username = "logan";
  home.homeDirectory = "/home/logan";
  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    trash-cli
  ];
}
