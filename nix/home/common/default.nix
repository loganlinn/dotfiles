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
    ../fzf.nix
    ../git
    ../gpg.nix
    ../nix-path.nix
    ../readline.nix
    ../ripgrep.nix
    ../secrets.nix
    ../security.nix
    ../shell
    ./darwin.nix
    ./linux.nix
  ];

  home.packages =
    with pkgs;
    [
      bc
      binutils
      cmake
      coreutils-full # installs gnu versions
      curl
      dig
      dogdns # dig on steroids
      du-dust # du alternative
      duf # df alternative
      envsubst
      file
      flake-root # nb: via overlay
      gawk
      gnugrep
      gnumake
      gnused
      gnutar
      gnutls
      gzip
      just
      lsof
      moreutils
      pik # pkill, interactively
      procs # ps alternative
      pstree
      repgrep
      rlwrap
      sd # sed alternative
      sops
      tree
      trurl
      unzip
      wget
      xh # httpie alternative
      zf
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

  programs.less = {
    enable = true;
    keys = '''';
  };

  programs.man.enable = true;

  programs.fd.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "onedark";
      theme_background = false;
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        warn_timeout = "10s";
      };
      whitelist = {
        prefix = [
          "~/src/github.com/loganlinn"
        ];
      };
    };
  };

  programs.jq.enable = true;

  programs.eza = {
    enable = !config.programs.lsd.enable;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    colors = "auto";
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--time-style=relative"
      "--hyperlink"
      "--color-scale=all"
      "--color-scale-mode=gradient"
    ];
  };

  xdg.enable = true;
}
