{pkgs, ...}: {
  imports = [
    ./common.nix
    ./dev.nix
    ./chromium.nix
    ./emacs.nix
    ./gh.nix
    ./git.nix
    ./fonts.nix
    ./kitty.nix
    ./neovim.nix
    ./pretty.nix
    # ./rofi.nix
    # ./sync.nix
    ./zsh.nix
    # ./code-server.nix
  ];

  home.username = "logan";
  home.homeDirectory = "/home/logan";

  home.packages = with pkgs; [
    _1password
    _1password-gui
    doctl
    trash-cli
    firefox
    slack
  ];

  home.stateVersion = "22.11";
}
