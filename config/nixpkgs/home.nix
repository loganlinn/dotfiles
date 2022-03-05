{ config, pkgs, ... }:

{

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "logan";
  home.homeDirectory = "/home/logan";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  home.packages = with pkgs; [
    asciinema
    bat
    bottom
    broot
    delta
    doctl
    du-dust
    entr
    fd
    fzf
    gifsicle
    hyperfine
    ijq
    lsd
    mdsh
    neofetch
    nixfmt
    procs
    restic
    rlwrap
    trash-cli
    sd
    shellharden
    zoxide
  ];

  # Things to try next: (ideas from: https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/misc)
    # asdf-vm
    # bat-extras
    # direnv
    # ical2org
    # mcfly
    # lsd

}
