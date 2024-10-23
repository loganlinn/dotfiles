{
  inputs ? (with builtins; (getFlake (toString ./.)).inputs),
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  myLib = (import ./lib/extended.nix lib).my;

  inherit (pkgs.stdenv) isLinux isDarwin;

  cfg = config.my;

  mkOpt = type: default: mkOption { inherit type default; };

  pathStr =
    with types;
    coercedTo path toString str
    // {
      check = x: isString x && builtins.substring 0 1 x == "/";
    };
in
{
  options.my = with types; {
    email = mkOpt (nullOr str) "logan@loganlinn.com";
    homepage = mkOpt str "https://loganlinn.com";
    github.username = mkOpt str "loganlinn";

    user = {
      name = mkOpt str "logan";
      description = mkOpt str "Logan Linn";
      home = mkOpt str (if isDarwin then "/Users/${cfg.user.name}" else "/home/${cfg.user.name}");
      shell = mkOpt (either str package) pkgs.zsh;
      packages = mkOpt (listOf package) [ ];
      openssh.authorizedKeys.keys = mkOpt (listOf str) [ ];
    };

    home = with lib.types; {
      file = mkOpt' attrs { } "Files to place directly in $HOME";
      configFile = mkOpt' attrs { } "Files to place in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs { } "Files to place in $XDG_DATA_HOME";
      fakeFile = mkOpt' attrs { } "Files to place in $XDG_FAKE_HOME";

      binDir = mkOpt str "${cfg.my.user.home}/.local/bin";
      cacheDir = mkOpt str "${cfg.my.user.home}/.cache";
      configDir = mkOpt str "${cfg.my.user.home}/.config";
      dataDir = mkOpt str "${cfg.my.user.home}/.local/share";
      stateDir = mkOpt str "${cfg.my.user.home}/.local/state";
      fakeDir = mkOpt str "${cfg.my.user.home}/.local/user";
    };

    pubkeys.ssh = mkOpt (attrsOf str) { };

    # homeModules = mkOpt (listOf raw) [ ];
    # nixosModules = mkOpt (listOf raw) [ ];
    # darwinModules = mkOpt (listOf raw) [ ];

    # userDirs = mkOpt (with types; attrsOf (nullOr pathType)) { };

    fonts = {
      serif = mkOption { type = myLib.types.font; };
      sans = mkOption { type = myLib.types.font; };
      mono = mkOption { type = myLib.types.font; };
      terminal = mkOption { type = myLib.types.font; };
      nerdfonts = {
        fonts = mkOpt (listOf str) [ ];
        package = mkOption {
          type = package;
          readOnly = true;
          default = pkgs.nerdfonts.override { fonts = cfg.fonts.nerdfonts.fonts; };
        };
      };
      packages = mkOpt (listOf package) [ ];
    };

    nix.registry = mkOption {
      type = myLib.types.nix-registry;
      default = { };
    };

    nix.settings = mkOption {
      type =
        let
          confAtom =
            nullOr (oneOf [
              bool
              int
              float
              str
              path
              package
            ])
            // {
              description = "Nix config atom (null, bool, int, float, str, path or package)";
            };
        in
        attrsOf (either confAtom (listOf confAtom));
    };
  };

  config = {
    my.pubkeys.ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpyxX1xNYCJHLpTQAEorumej3kyNWlknnhQ/QqkhdN ${cfg.email}";
    my.pubkeys.ssh.rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/IGTiUT57yPpsCHcSo0FUUBY7uTZL87vdr7EqE+fS+6FQFZbhXuzy63Y13+ssN1Cbwy7hE3I4u0HgaXnhe8Ogr+buvBYqcSCajbN8j2vVVy/WUuGRPKyczk0bZpL1V7LUt98jBMnctirVeY0YoBgEk9POWHZ4NTTK0Bsr2WAwpWUkdYPcHpEIW+ABNX4YqxZdq7ETMy18ELfE/IJz04/+9rGHvpsDLL2SXDJCj+hxofW28SaqncOv/GvTN9gpkQGpUfHbxMyHz8Xj3faiguCN70dFEUb1FVL5ilxePSp/hOYx039idGT+K5oojutT6gH8p1K2uQ12rO+auvmKVSrh ${cfg.email}";
    my.user = {
      openssh.authorizedKeys.keys = attrValues cfg.pubkeys.ssh;
      packages = with pkgs; [
        curl
        jq
        fd
        ripgrep
        gh
      ];
    };

    # my.userDirs = mkDefault {
    #   desktop = "Desktop";
    #   documents = "Documents";
    #   download = "Downloads";
    #   music = "Music";
    #   pictures = "Pictures";
    #   publicShare = "Public";
    #   videos = "Videos";
    #   screenshots = "Screenshots";
    #   code = "src";
    #   dotfiles = ".dotfiles";
    # };

    my.fonts = {
      serif = mkDefault {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
        size = mkDefault (if isLinux then 10 else 12);
      };

      sans = mkDefault {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
        size = mkDefault (if isLinux then 10 else 12);
      };

      mono = mkDefault {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
        size = mkDefault (if isLinux then 10 else 12);
      };

      terminal = mkDefault {
        package = cfg.fonts.nerdfonts.package;
        name = "FiraCode Nerd Font Light";
        size = mkDefault (if isLinux then 11 else 12);
      };

      nerdfonts.fonts = mkDefault [
        "DejaVuSansMono"
        "FiraCode"
        "FiraMono"
        "Iosevka"
        "JetBrainsMono"
        "NerdFontsSymbolsOnly"
        "VictorMono"
      ];

      packages = with pkgs; [
        cfg.fonts.serif.package
        cfg.fonts.sans.package
        cfg.fonts.mono.package
        cfg.fonts.terminal.package
        cfg.fonts.nerdfonts.package
        dejavu_fonts
        cascadia-code
        fira # sans
        fira-code
        fira-code-symbols
        iosevka
        material-design-icons # https://materialdesignicons.com/
        material-icons
        noto-fonts
        noto-fonts-emoji
        open-sans
        recursive
        victor-mono
      ];
    };

    my.nix.registry = {
      nixpkgs.flake = inputs.nixpkgs;
      home-manager.flake = inputs.home-manager;
    };

    my.nix.settings = {
      warn-dirty = mkDefault false;
      show-trace = mkDefault true;
      trusted-users = [ cfg.user.name ];
      trusted-substituters = [
        "https://loganlinn.cachix.org"
        "https://nix-community.cachix.org"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };
}
