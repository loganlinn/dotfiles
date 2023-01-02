{pkgs, ...}: {
  imports = [
    ./browser.nix
    ./common.nix
    ./dev.nix
    ./emacs.nix
    ./fonts.nix
    ./gh.nix
    ./git.nix
    ./kitty
    ./neovim.nix
    ./pretty.nix
    ./rofi.nix
    ./sync.nix
    ./vpn.nix
    ./vscode.nix
    ./zsh.nix
    # ./code-server.nix
  ];

  home.username = "logan";
  home.homeDirectory = "/home/logan";

  home.packages = with pkgs; [
    _1password
    _1password-gui
    doctl
    firefox
    slack
    trash-cli
  ];

  home.stateVersion = "22.11";
}
