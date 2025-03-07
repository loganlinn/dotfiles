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

    flakeDirectory = mkOpt pathStr "${cfg.user.home}/.dotfiles";
    flakeRepository = mkOpt str "https://github.com/loganlinn/dotfiles";

    environment.variables = mkOpt (attrsOf str) { };

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
    my = {
      pubkeys.ssh.ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpyxX1xNYCJHLpTQAEorumej3kyNWlknnhQ/QqkhdN ${cfg.email}";

      pubkeys.ssh.rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/IGTiUT57yPpsCHcSo0FUUBY7uTZL87vdr7EqE+fS+6FQFZbhXuzy63Y13+ssN1Cbwy7hE3I4u0HgaXnhe8Ogr+buvBYqcSCajbN8j2vVVy/WUuGRPKyczk0bZpL1V7LUt98jBMnctirVeY0YoBgEk9POWHZ4NTTK0Bsr2WAwpWUkdYPcHpEIW+ABNX4YqxZdq7ETMy18ELfE/IJz04/+9rGHvpsDLL2SXDJCj+hxofW28SaqncOv/GvTN9gpkQGpUfHbxMyHz8Xj3faiguCN70dFEUb1FVL5ilxePSp/hOYx039idGT+K5oojutT6gH8p1K2uQ12rO+auvmKVSrh ${cfg.email}";

      user = {
        openssh.authorizedKeys.keys = attrValues cfg.pubkeys.ssh;
        packages = with pkgs; [
          curl
          jq
          fd
          ripgrep
          gh
        ];
      };

      environment.variables = {
        DOTFILES_DIR = cfg.flakeDirectory;
        DISABLE_TELEMETRY = "1";
        DOCKER_SCAN_SUGGEST = "false";
        DOTNET_CLI_TELEMETRY_OPTOUT = "true";
        DO_NOT_TRACK = "1";
        FLAKE_CHECKER_NO_TELEMETRY = "true";
        NIX_INSTALLER_DIAGNOSTIC_ENDPOINT = "";
        TELEMETRY_DISABLED = "1";
      };

      # userDirs = mkDefault {
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

      fonts = {
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
          package = pkgs.nerd-fonts.victor-mono;
          name = "Victor Mono";
          size = mkDefault (if isLinux then 10 else 12);
        };

        terminal = mkDefault {
          package = pkgs.nerd-fonts.victor-mono;
          name = "Victor Mono";
          size = mkDefault (if isLinux then 11 else 12);
        };

        packages = with pkgs; [
          cfg.fonts.mono.package
          cfg.fonts.sans.package
          cfg.fonts.serif.package
          cfg.fonts.terminal.package

          cascadia-code
          dejavu_fonts
          monaspace
          nerd-fonts.dejavu-sans-mono
          nerd-fonts.fira-code
          nerd-fonts.fira-mono
          nerd-fonts.jetbrains-mono
          nerd-fonts.symbols-only
          nerd-fonts.victor-mono
          noto-fonts
          noto-fonts-emoji
          open-sans
          recursive
          victor-mono
        ];
      };

      nix.settings = rec {
        warn-dirty = mkDefault false;
        show-trace = mkDefault true;
        trusted-users = [ cfg.user.name ];
        extra-substituters = [
          "https://cache.nixos.org"
          "https://wezterm.cachix.org"
          # "https://nix-community.cachix.org"
          # "https://loganlinn.cachix.org"
        ];
        extra-trusted-substituters = extra-substituters;
        extra-trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };
    };
  };
}
