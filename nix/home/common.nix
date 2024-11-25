{
  self,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./accounts.nix
    ./common-linux.nix
    ./common-darwin.nix
    ./fzf.nix
    ./git
    ./gpg.nix
    ./nix-path.nix
    ./ranger.nix
    ./readline.nix
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
      procs # ps alternative
      pstree
      repgrep
      rlwrap
      sd # sed alternative
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

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--type-add"
      "clj:include:clojure,edn"
      "--smart-case"
      "--hyperlink-format=kitty" # note: also supported by wezterm
      "--follow"
    ];
  };

  programs.jq.enable = true;

  programs.lsd = {
    enable = true;
    enableAliases = true;
    settings = {
      date = "relative";
    };
  };

  programs.tealdeer.enable = true; # tldr command

  xdg.enable = lib.mkDefault true;
}
