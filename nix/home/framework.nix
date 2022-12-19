{pkgs, ...}: {
  imports = [
    ./common.nix
    ./dev.nix
    ./emacs.nix
    ./fonts.nix
    ./gh.nix
    ./git.nix
    # ./kitty.nix
    ./neovim.nix
    ./pretty.nix
    ./rofi.nix
    ./sync.nix
    ./zsh.nix
    ./xdg.nix
  ];

  home = {
    username = "logan";
    homeDirectory = "/home/logan";
    stateVersion = "22.05";
  };


  home.packages = with pkgs; [
    _1password
    asciinema
    doctl
    scrot
    screenkey
    trash-cli
    xclip
    #ffmpeg
    #imagemagick
    #gifsicle
    #gifski
    #ponymix
    restic
    gnome.sushi                 # Nautalius file previews
    gcolor3                     # Color picker
    gnome-feeds                 # RSS/Atom reader
  ];

}
