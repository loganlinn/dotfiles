{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../accounts.nix
    ../age-op.nix
    ../btop.nix
    ../direnv.nix
    ../eza.nix
    ../fzf.nix
    ../git
    ../gpg.nix
    ../nix-path.nix
    ../readline.nix
    ../ripgrep.nix
    ../secrets.nix
    ../security.nix
    ../shell
    ../xdg.nix
    ./darwin.nix
    ./linux.nix
  ];

  home.packages =
    with pkgs;
    [
      as-tree
      bc
      binutils
      bkt
      cmake
      coreutils-full
      curl
      dig
      doggo
      dua
      dust
      duf
      envsubst
      file
      gh
      gawk
      gnugrep
      gnumake
      gnused
      gnutar
      gnutls
      gzip
      inetutils
      just
      lsof
      moreutils
      nix-output-monitor
      pik
      procs
      pstree
      repgrep
      rlwrap
      sd
      sops
      stow
      tre-command
      tree
      trurl
      unzip
      wget
      xh
      zip
    ]
    ++ (lib.catAttrs "package" (lib.attrValues config.my.shellScripts));

  home.sessionVariables = config.my.environment.variables;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.local/share/cargo/bin"
    "$HOME/go/bin"
  ];

  programs.home-manager.enable = true;
  programs.man.enable = true;
  programs.fd.enable = true;
  programs.btop.enable = true;
  programs.direnv.enable = true;
  programs.jq.enable = true;
  programs.eza.enable = !config.programs.lsd.enable;

  xdg.enable = true;
}
