{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  lib' = import ./lib/extended.nix lib;

  inherit (lib'.my.types) fontType;

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

    pubkeys.ssh = mkOpt (attrsOf str) { };

    user.name = mkOpt str "logan";
    user.description = mkOpt str "Logan Linn";
    user.home = mkOpt (nullOr pathStr) null;
    user.shell = mkOpt (either str package) pkgs.zsh;
    user.packages = mkOpt (listOf package) [ ];
    user.openssh.authorizedKeys.keys = mkOpt (listOf str) [ ];

    github.username = mkOpt str "loganlinn";

    # homeModules = mkOpt (listOf raw) [ ];
    # nixosModules = mkOpt (listOf raw) [ ];
    # darwinModules = mkOpt (listOf raw) [ ];

    # userDirs = mkOpt (with types; attrsOf (nullOr pathType)) { };

    fonts = {
      serif = mkOption { type = fontType; };
      sans = mkOption { type = fontType; };
      mono = mkOption { type = fontType; };
      terminal = mkOption { type = fontType; };
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

  config =
    let
      inherit (pkgs.stdenv) isLinux isDarwin;
    in
    {
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
          size = if isLinux then 10 else 12;
        };

        sans = mkDefault {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
          size = if isLinux then 10 else 12;
        };

        mono = mkDefault {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans Mono";
          size = if isLinux then 10 else 12;
        };

        terminal = mkDefault {
          package = cfg.fonts.nerdfonts.package;
          name = "FiraCode Nerd Font Light";
          size = 11;
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
          "repl-flake"
        ];
        auto-optimise-store = true;
      };
    };
}
