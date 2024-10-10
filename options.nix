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
in
{
  options.my = with types; {
    email = mkOpt (nullOr str) "logan@loganlinn.com";
    homepage = mkOpt str "https://loganlinn.com";

    user = {
      name = mkOpt str "logan";
      description = mkOpt str "Logan Linn";
      shell = mkOpt (either str package) pkgs.zsh;
      packages = mkOpt (listOf package) [ ];
      openssh.authorizedKeys.keys = mkOpt (listOf str) [ ];
      signingkey = mkOpt str "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpyxX1xNYCJHLpTQAEorumej3kyNWlknnhQ/QqkhdN";
    };

    github.username = mkOpt str "loganlinn";

    authorizedKeys = mkOpt (listOf str) [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa logan@loganlinn.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/IGTiUT57yPpsCHcSo0FUUBY7uTZL87vdr7EqE+fS+6FQFZbhXuzy63Y13+ssN1Cbwy7hE3I4u0HgaXnhe8Ogr+buvBYqcSCajbN8j2vVVy/WUuGRPKyczk0bZpL1V7LUt98jBMnctirVeY0YoBgEk9POWHZ4NTTK0Bsr2WAwpWUkdYPcHpEIW+ABNX4YqxZdq7ETMy18ELfE/IJz04/+9rGHvpsDLL2SXDJCj+hxofW28SaqncOv/GvTN9gpkQGpUfHbxMyHz8Xj3faiguCN70dFEUb1FVL5ilxePSp/hOYx039idGT+K5oojutT6gH8p1K2uQ12rO+auvmKVSrh logan@loganlinn.com"
    ];

    fonts =
      let
        defaultFontSize = if pkgs.stdenv.isLinux then 10 else 12;
      in
      {
        serif = mkOpt fontType {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
          size = defaultFontSize;
        };

        sans = mkOpt fontType {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
          size = defaultFontSize;
        };

        mono = mkOpt fontType {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans Mono";
          size = defaultFontSize;
        };

        terminal = mkOpt fontType {
          package = cfg.nerdfonts.package;
          name = "FiraCode Nerd Font Light";
          size = 11;
        };

        # see: https://github.com/NixOS/nixpkgs/tree/nixos-unstable/pkgs/data/fonts
        packages = mkOpt (listOf package) (
          with pkgs;
          [
            cfg.fonts.serif.package
            cfg.fonts.sans.package
            cfg.fonts.mono.package
            cfg.fonts.terminal.package
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
          ]
        );
      };

    nerdfonts.fonts = mkOpt (listOf str) [
      # "AnonymousPro"
      "DejaVuSansMono"
      "FiraCode"
      "FiraMono"
      # "Go-Mono"
      # "Hack"
      # "Hasklig"
      # "FantasqueSansMono"
      # "IBMPlexMono"
      # "Inconsolata"
      "Iosevka"
      "JetBrainsMono"
      # "LiberationMono"
      # "Lilex"
      # "Meslo"
      "NerdFontsSymbolsOnly"
      "Noto"
      # "OpenDyslexic"
      # "ProFont"
      # "RobotoMono"
      "SourceCodePro"
      "SpaceMono"
      "Terminus"
      "Ubuntu"
      "UbuntuMono"
      "VictorMono"
    ];

    nerdfonts.package = mkOption {
      type = package;
      readOnly = true;
      default = pkgs.nerdfonts.override { inherit (cfg.nerdfonts) fonts; };
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
    my.nix.settings = {
      warn-dirty = mkDefault false;
      show-trace = mkDefault true;
      trusted-users = [ cfg.user.name ];
      trusted-substituters = [
        "https://loganlinn.cachix.org"
        # "https://hyprland.cachix.org"
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
