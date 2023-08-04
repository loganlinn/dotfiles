{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.my;

in
{
  options.my = mkOption {
    type = with types; submodule {
      options = {
        name = mkOption {
          type = str;
          default = "Logan";
        };
        user.name = mkOption {
          type = str;
          default = "logan";
        };
        shell = mkOption {
          type = either str package;
          default = pkgs.zsh;
        };
        email = mkOption {
          type = nullOr str;
          default = "logan@loganlinn.com";
        };
        github.user = mkOption {
          type = str;
          default = "loganlinn";
        };
        homepage = mkOption {
          type = str;
          default = "https://loganlinn.com";
        };

        authorizedKeys = mkOption {
          type = listOf str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa nijusan@loganlinn.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwurIVpZjNpRjFva/8loWMCZobZQ3FSATVLC8LX2TDB sumaho@loganlinn.com"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/IGTiUT57yPpsCHcSo0FUUBY7uTZL87vdr7EqE+fS+6FQFZbhXuzy63Y13+ssN1Cbwy7hE3I4u0HgaXnhe8Ogr+buvBYqcSCajbN8j2vVVy/WUuGRPKyczk0bZpL1V7LUt98jBMnctirVeY0YoBgEk9POWHZ4NTTK0Bsr2WAwpWUkdYPcHpEIW+ABNX4YqxZdq7ETMy18ELfE/IJz04/+9rGHvpsDLL2SXDJCj+hxofW28SaqncOv/GvTN9gpkQGpUfHbxMyHz8Xj3faiguCN70dFEUb1FVL5ilxePSp/hOYx039idGT+K5oojutT6gH8p1K2uQ12rO+auvmKVSrh logan@loganlinn.com"
          ];
        };
        publicKeys = mkOption {
          type = attrsOf str;
          default = {};
        };

        fonts = mkOption {
          type = attrsOf lib.hm.types.fontType;
          default = let defaultFontSize = if pkgs.stdenv.isLinux then 10 else 12; in {
            serif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Serif";
              size = defaultFontSize;
            };
            sans = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans";
              size = defaultFontSize;
            };
            mono = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans Mono";
              size = defaultFontSize;
            };
            terminal = {
              package = cfg.nerdfonts.package;
              name = "FiraCode Nerd Font Light";
              size = 11;
            };
          };
        };

        fontPackages = mkOption {
          type = listOf package;
          default = with pkgs; [
            # TODO Apple Fonts (SF Pro, SF Mono, SF Compact, SF Arabic, NY)
            dejavu_fonts
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
            ubuntu_font_family
            victor-mono

          ];
        };

        nerdfonts.fonts = mkOption {
          type = listOf str;
          default = [
            "AnonymousPro"
            "DejaVuSansMono"
            "FiraCode"
            "FiraMono"
            "Go-Mono"
            "Hack"
            "Hasklig"
            "FantasqueSansMono"
            "IBMPlexMono"
            "Inconsolata"
            "Iosevka"
            "JetBrainsMono"
            "LiberationMono"
            "Lilex"
            "Meslo"
            "NerdFontsSymbolsOnly"
            "Noto"
            "OpenDyslexic"
            "ProFont"
            "RobotoMono"
            "SourceCodePro"
            "SpaceMono"
            "Terminus"
            "Ubuntu"
            "UbuntuMono"
            "VictorMono"
          ];
        };
        nerdfonts.package = mkOption {
          type = package;
          readOnly = true;
          default = pkgs.nerdfonts.override { inherit (cfg.nerdfonts) fonts; };

        };
      };

      config = {
        fontPackages = [
          cfg.nerdfonts.package
        ];
      };
    };
  };
}
