{ pkgs, ... }: {
  imports = [
    ../nix/home/common.nix
    ../nix/home/dev
    ../nix/home/emacs
    ../nix/home/git
    ../nix/home/pretty.nix
    ../nix/home/sync.nix
    ../nix/home/xdg.nix
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
    gnome.sushi # Nautalius file previews
    gcolor3 # Color picker
    gnome-feeds # RSS/Atom reader
  ];

  home.file.".xinitrc".text = ''
    setxkbmap us -option ctrl:nocaps &
  '';
}
