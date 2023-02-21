{ config, lib, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkIf mkOption;

  cfg = config.modules.fonts;

in
{
  options.modules.fonts = {
    enable = mkEnableOption "fonts";

    fonts = mkOption {
      type = with types; listOf package;
      default = [ ];
    };

    nerdfonts.package = mkOption {
      type = types.package;
      default = pkgs.nerdfonts.override {
        fonts = [
          # "3270"
          # "Agave"
          "AnonymousPro"
          # "Arimo"
          # "AurulentSansMono"
          # "BigBlueTerminal"
          # "BitstreamVeraSansMono"
          "CascadiaCode"
          # "CodeNewRoman"
          # "Cousine"
          # "DaddyTimeMono"
          "DejaVuSansMono"
          "DroidSansMono"
          # "FantasqueSansMono"
          "FiraCode"
          "FiraMono"
          # "FontPatcher"
          "Go-Mono"
          # "Gohu"
          "Hack"
          "Hasklig"
          # "HeavyData"
          # "Hermit"
          # "iA-Writer"
          "IBMPlexMono"
          "Inconsolata"
          "InconsolataGo"
          "InconsolataLGC"
          "Iosevka"
          "JetBrainsMono"
          "Lekton"
          "LiberationMono"
          "Lilex"
          "Meslo"
          # "Monofur"
          "Monoid"
          "Mononoki"
          # "MPlus"
          "NerdFontsSymbolsOnly"
          "Noto"
          # "OpenDyslexic"
          # "Overpass"
          "ProFont"
          # "ProggyClean"
          "RobotoMono"
          # "ShareTechMono"
          "SourceCodePro"
          "SpaceMono"
          "Terminus"
          # "Tinos"
          "Ubuntu"
          "UbuntuMono"
          "VictorMono"
        ];
      };
    };
  };

  config = {
    home.packages = with pkgs; [

      open-sans
      ankacoder
      cascadia-code
      dejavu_fonts
      fira # sans
      fira-code
      fira-code-symbols
      font-awesome
      font-awesome_5
      hack-font
      iosevka
      jetbrains-mono
      liberation_ttf
      material-design-icons # https://materialdesignicons.com/
      material-icons
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      recursive
      ubuntu_font_family
      victor-mono
    ] ++ cfg.fonts ++ lib.singleton cfg.nerdfonts.package;

    # fonts.fontconfig.enable = lib.mkOptionDefault true;
  };
}
