{
  self,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./age-op.nix
    ./accounts.nix
    ./common-linux.nix
    ./common-darwin.nix
    ./fzf.nix
    ./git
    ./gpg.nix
    ./nix-path.nix
    # ./ranger.nix
    ./readline.nix
    ./ripgrep.nix
    ./secrets.nix
    ./security.nix
    ./shell
  ];

  home.packages =
    with pkgs;
    [
      # neofetch
      # pinentry
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
      just
      gawk
      gnugrep
      gnumake
      gnused
      gnutar
      gnutls
      gzip
      lsof
      moreutils
      pik # pkill, interactively
      procs # ps alternative
      pstree
      repgrep
      rlwrap
      sd # sed alternative
      trurl
      sops
      tree
      unzip
      wget
      xh # httpie alternative
      zip
    ]
    ++ (lib.catAttrs "package" (lib.attrValues config.my.shellScripts));

  my.shellScripts.dotfiles = {
    runtimeInputs = [ pkgs.just ];
    text = ''exec just --justfile "${config.my.flakeDirectory}/justfile" "$@"'';
  };

  home.shellAliases.switch = "dotfiles switch";

  home.sessionVariables = config.my.environment.variables;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.local/share/cargo/bin"
    # "$HOME/.dotfiles/bin"
    # "$HOME/.krew/bin"
    "$HOME/go/bin"
  ];

  programs.home-manager.enable = true;

  programs.less.enable = true;
  programs.less.keys = '''';

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

  programs.lsd = {
    enable = false;
    enableAliases = true;
    settings = {
      date = "relative";
      hyperlink = "auto";
      sorting.dir-grouping = "first";
      header = true;
      icons.separator = " ";
      indicators = true;
      blocks = [
        "permission"
        "user"
        "group"
        "size"
        "date"
        "git"
        "name"
      ];
    };
  };

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

  programs.tealdeer.enable = true; # tldr command

  xdg.enable = true;
}
