{pkgs, ...}: {
  imports = [
    ../../home/common.nix
    ../../home/dev.nix
    ../../home/emacs.nix
    ../../home/fonts.nix
    ../../home/gh.nix
    ../../home/git.nix
    ../../home/pretty.nix
    ../../home/rofi.nix
    ../../home/sync.nix
    ../../home/zsh.nix
    ../../home/xdg.nix
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
