{pkgs, ...}: {
  imports = [
    ./chat.nix
    ./clojure.nix
    ./common.nix
    ./dev.nix
    ./emacs.nix
    ./fonts.nix
    ./gh.nix
    ./kitty.nix
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
    delta
    dive
    doctl
    graphviz
    hyperfine
    jless
    mdsh
    procs
    scrot
    sysz
    screenkey
    trash-cli
    xclip
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science

    chafa # show images in terminal using half blocks

    #ffmpeg
    #imagemagick
    gifsicle
    gifski

    #ponymix

    pinentry-emacs
    sqlite
    restic

    zk
  ];
}
