{ config, pkgs, lib, ... }:

with lib;

let
  lib' = import ./lib/extended.nix lib;

  inherit (lib'.my.types) fontType;

  cfg = config.my;

  mkOpt = type: default: mkOption { inherit type default; };

  defaultFontSize = if pkgs.stdenv.isLinux then 10 else 12;
in {
  options.my = with types; {
    email = mkOpt (nullOr str) "logan@loganlinn.com";
    homepage = mkOpt str "https://loganlinn.com";
    user.name = mkOpt str "logan";
    user.signingkey = mkOpt str "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpyxX1xNYCJHLpTQAEorumej3kyNWlknnhQ/QqkhdN";
    user.shell = mkOpt (either str package) pkgs.zsh;
    user.groups = mkOpt (listOf str) [];
    github.username = mkOpt str "loganlinn";
    authorizedKeys = mkOpt (listOf str) [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa nijusan@loganlinn.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwurIVpZjNpRjFva/8loWMCZobZQ3FSATVLC8LX2TDB sumaho@loganlinn.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/IGTiUT57yPpsCHcSo0FUUBY7uTZL87vdr7EqE+fS+6FQFZbhXuzy63Y13+ssN1Cbwy7hE3I4u0HgaXnhe8Ogr+buvBYqcSCajbN8j2vVVy/WUuGRPKyczk0bZpL1V7LUt98jBMnctirVeY0YoBgEk9POWHZ4NTTK0Bsr2WAwpWUkdYPcHpEIW+ABNX4YqxZdq7ETMy18ELfE/IJz04/+9rGHvpsDLL2SXDJCj+hxofW28SaqncOv/GvTN9gpkQGpUfHbxMyHz8Xj3faiguCN70dFEUb1FVL5ilxePSp/hOYx039idGT+K5oojutT6gH8p1K2uQ12rO+auvmKVSrh logan@loganlinn.com"
    ];

    publicKeys = mkOpt (attrsOf str) { };

    # TODO make resemble pkgs.stdenv.{isLinux, isDarwin, isx86_32, ...}
    hints.isWSL = mkOpt bool (builtins.pathExists /usr/lib/wsl/lib);

    fonts = mkOpt (attrsOf fontType) {
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

    fontPackages = mkOpt (listOf package) (with pkgs; [
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
      cfg.nerdfonts.package
    ]);
    nerdfonts.fonts = mkOpt (listOf str) [
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
    nerdfonts.package = mkOption {
      type = package;
      readOnly = true;
      default = pkgs.nerdfonts.override { inherit (cfg.nerdfonts) fonts; };
    };
  };
}
