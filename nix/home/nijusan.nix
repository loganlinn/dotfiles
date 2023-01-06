{pkgs, ...}: {
  imports = [
    ./_1password.nix
    ./browser.nix
    ./common.nix
    ./dev.nix
    ./emacs.nix
    ./fonts.nix
    ./gh.nix
    ./git.nix
    ./graphical.nix
    ./kitty
    ./neovim.nix
    ./pretty.nix
    ./rofi.nix
    ./sync.nix
    ./vpn.nix
    ./vscode.nix
    ./xdg.nix
    ./zsh.nix
  ];

  programs.librewolf.enable = true;

  services.syncthing.tray = {
    enable = true;
    package = pkgs.syncthingtray;
  };

  home.username = "logan";
  home.homeDirectory = "/home/logan";

  home.packages = with pkgs; [
    ark        # Graphical file compression/decompression utility
    blender    # 3D Creation/Animation/Publishing System
    doctl      # DigitalOcean CLI
    obsidian
    slack
    trash-cli
    vlc
  ];

  home.stateVersion = "22.11";
}
