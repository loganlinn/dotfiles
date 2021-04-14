{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    bat
    coreutils
    curl
    cmake
    fd
    fzf
    git
    glab
    gnupg
    gnused
    gnuplot
    grpcurl
    helmfile
    jq
    kitty
    lsd
    neovim
    pinentry_mac
    plantuml
    rcm
    rlwrap
    shellcheck
    shellharden
    silver-searcher
    tmux
    tree
    wget
    yq
  ];

  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.defaults.dock = {
    autohide = true;
    expose-group-by-app = false;
    mru-spaces = false;
    tilesize = 48;
  };
}
