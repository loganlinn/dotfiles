{
  # inputs ? (with builtins; (getFlake (toString ./.)).inputs),
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  myLib = (import ./lib/extended.nix lib).my;

  inherit (pkgs.stdenv) isLinux isDarwin;

  cfg = config.my;

  mkOpt = type: default: mkOption {inherit type default;};

  pathStr = with types;
    addCheck (coercedTo path toString str) (x: isString x && builtins.substring 0 1 x == "/");
in {
  options.my = with types; {
    email = mkOpt (nullOr str) "logan@loganlinn.com";
    homepage = mkOpt str "https://loganlinn.com";
    github.username = mkOpt str "loganlinn";

    flakeDirectory = mkOpt pathStr "${cfg.user.home}/.dotfiles";
    flakeRepository = mkOpt str "https://github.com/loganlinn/dotfiles";
    environment.variables = mkOpt (attrsOf (
      coercedTo path toString (coercedTo package getExe str)
    )) {}; # see below

    # https://github.com/NixOS/nixpkgs/blob/68898dd/nixos/modules/config/users-groups.nix
    # https://github.com/nix-darwin/nix-darwin/blob/73d5958/modules/users/user.nix
    user = {
      name = mkOpt str "logan";
      description = mkOpt str "Logan Linn";
      home = mkOpt str (
        if isDarwin
        then "/Users/${cfg.user.name}"
        else "/home/${cfg.user.name}"
      );
      shell = mkOpt (either str package) pkgs.zsh;
      packages = mkOpt (listOf package) [];
      openssh.authorizedKeys.keys = mkOpt (listOf str) [];
    };

    # https://github.com/nix-community/home-manager/blob/ef3b2a6/modules/misc/xdg-user-dirs.nix
    userDirs = mkOpt (types.submodule {
      options = {
        # Well-known directory list from
        # https://gitlab.freedesktop.org/xdg/xdg-user-dirs/blob/master/man/user-dirs.dirs.xml
        desktop = mkOpt (nullOr pathStr) "${cfg.user.home}/Desktop";
        documents = mkOpt (nullOr pathStr) "${cfg.user.home}/Documents";
        download = mkOpt (nullOr pathStr) "${cfg.user.home}/Downloads";
        music = mkOpt (nullOr pathStr) "${cfg.user.home}/Music";
        pictures = mkOpt (nullOr pathStr) "${cfg.user.home}/Pictures";
        publicShare = mkOpt (nullOr pathStr) "${cfg.user.home}/Public";
        templates = mkOpt (nullOr pathStr) "${cfg.user.home}/Templates";
        videos = mkOpt (nullOr pathStr) "${cfg.user.home}/Videos";

        # Non-standard directories
        code = mkOpt (nullOr pathStr) "${cfg.user.home}/src";
        notes = mkOpt (nullOr pathStr) "${cfg.user.home}/Notes";
        screenshots = mkOpt (nullOr pathStr) "${cfg.user.home}/Pictures/Screenshots";
      };
      freeformType = nullOr pathStr;
    }) {};

    pubkeys.ssh = mkOpt (attrsOf str) {};

    fonts = {
      serif = mkOption {type = myLib.types.font;};
      sans = mkOption {type = myLib.types.font;};
      mono = mkOption {type = myLib.types.font;};
      terminal = mkOption {type = myLib.types.font;};
      packages = mkOpt (listOf package) [];
    };

    shellInitExtra = mkOption {
      type = types.lines;
      description = "Extra commands that should be added to <filename>.zshrc</filename> and <filename>.zshrc</filename>.";
      default = "";
    };

    shellScripts = let
      shellScriptModule = pkgs.callPackage ./lib/shellScriptModule.nix {};
      shellScriptType = types.coercedTo types.str (text: {inherit text;}) shellScriptModule;
    in
      mkOption {
        description = ''
          See https://nixos.org/manual/nixpkgs/unstable/#trivial-builder-writeShellApplication
        '';
        type = attrsOf shellScriptType;
        # ({pkgs, ...}: {
        #   options = {
        #     copy = mkOpt shellScriptType (
        #       if isDarwin
        #       then (writeShellScriptBin "copy" ''exec pbcopy'')
        #       else (writeShellScriptBin "copy" ''exec ${pkgs.xclip}/bin/xclip -sel clip'')
        #     );
        #     pasta = mkOpt shellScriptType (
        #       if isDarwin
        #       then (writeShellScriptBin "pasta" ''exec pbpaste "$@"'')
        #       else (writeShellScriptBin "copy" ''exec ${pkgs.xclip}/bin/xclip -o -sel clip'')
        #     );
        #   };
        #   freeformType = shellScriptType;
        # });
        default = {};
      };

    nix.registry = mkOption {
      type = myLib.types.nix-registry;
      default = {};
    };

    nix.settings = mkOption {
      type = let
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

    # homeModules = mkOpt (listOf raw) [ ];
    # nixosModules = mkOpt (listOf raw) [ ];
    # darwinModules = mkOpt (listOf raw) [ ];
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
      environment.variables =
        {
          DISABLE_TELEMETRY = "1";
          DOCKER_SCAN_SUGGEST = "false";
          DOTFILES_DIR = cfg.flakeDirectory;
          DOTNET_CLI_TELEMETRY_OPTOUT = "true";
          DO_NOT_TRACK = "1";
          FLAKE_CHECKER_NO_TELEMETRY = "true";
          NIX_INSTALLER_DIAGNOSTIC_ENDPOINT = "";
          TELEMETRY_DISABLED = "1";
        }
        // optionalAttrs isDarwin {
          # Since home-managers xdg-user-dirs module does not support darwin
          XDG_NOTES_DIR = toString cfg.userDirs.notes;
          XDG_SCREENSHOTS_DIR = toString cfg.userDirs.screenshots;
          XDG_CODE_DIR = toString cfg.userDirs.code;
        };
      # shellScripts = {
      #   copy = mkDefault (
      #     if isDarwin
      #     then ''exec pbcopy''
      #     else ''exec ${pkgs.xclip}/bin/xclip -sel clip''
      #   );
      #   pasta = mkDefault (
      #     if isDarwin
      #     then ''exec pbpaste''
      #     else ''exec ${pkgs.xclip}/bin/xclip -o -sel clip''
      #   );
      # };
      fonts = {
        serif = mkDefault {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
          size = mkDefault (
            if isLinux
            then 10
            else 12
          );
        };
        sans = mkDefault {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
          size = mkDefault (
            if isLinux
            then 10
            else 12
          );
        };
        mono = mkDefault {
          package = pkgs.nerd-fonts.victor-mono;
          name = "Victor Mono";
          size = mkDefault (
            if isLinux
            then 10
            else 12
          );
        };
        terminal = mkDefault {
          package = pkgs.nerd-fonts.victor-mono;
          name = "Victor Mono";
          size = mkDefault (
            if isLinux
            then 11
            else 12
          );
        };
        packages = with pkgs; [
          # cfg.fonts.mono.package
          # cfg.fonts.sans.package
          # cfg.fonts.serif.package
          # cfg.fonts.terminal.package
          #
          # cascadia-code
          # dejavu_fonts
          # monaspace
          # nerd-fonts.dejavu-sans-mono
          # nerd-fonts.fira-code
          # nerd-fonts.fira-mono
          # nerd-fonts.jetbrains-mono
          # nerd-fonts.symbols-only
          nerd-fonts.victor-mono
          # noto-fonts
          # noto-fonts-emoji
          # open-sans
          # recursive
          victor-mono
        ];
      };
      nix.settings = rec {
        warn-dirty = mkDefault false;
        show-trace = mkDefault true;
        trusted-users = [cfg.user.name];
        extra-substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://wezterm.cachix.org"
        ];
        extra-trusted-substituters = extra-substituters;
        extra-trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
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
