{ pkgs, ... }: {
  home.packages = with pkgs; [
    cascadia-code
    dejavu_fonts
    fantasque-sans-mono
    fira-code
    fira-code-symbols
    font-awesome
    font-awesome_5
    material-icons
    material-design-icons # https://materialdesignicons.com/
    hack-font
    iosevka
    jetbrains-mono
    terminus-nerdfont
    victor-mono
    ankacoder
    liberation_ttf
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ubuntu_font_family
    recursive
    (nerdfonts.override {
      # https://www.nerdfonts.com/font-downloads
      # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/data/fonts/nerdfonts/shas.nix
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
        # "IBMPlexMono"
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
        # "Monoid"
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
        # "SpaceMono"
        "Terminus"
        # "Tinos"
        "Ubuntu"
        "UbuntuMono"
        "VictorMono"
      ];
    })
  ];
}
