{pkgs, ...}: {
  imports = [
    ./common.nix
    ./dev.nix
    ./emacs.nix
    ./fonts.nix
    ./gh.nix
    # ./kitty.nix
    ./neovim.nix
    ./pretty.nix
    ./rofi.nix
    ./sync.nix
  ];

  home = {
    username = "logan";
    homeDirectory = "/home/logan";
    stateVersion = "22.05";
  };

  xdg.userDirs.enable = true;
  xdg.mimeApps.enable = true;
  xdg.desktopEntries = {
    # TODO Chromium profiles
  };

  home.packages = with pkgs; [
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
    zk
  ];
}
