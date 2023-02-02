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
      fonts = [
        "DejaVuSansMono"
        "DroidSansMono"
        "Inconsolata"
        "InconsolataGo"
        "FiraCode"
        "Hack"
        "MesloLG"
        "Noto"
        "JetBrainsMono"
        "Roboto"
        "SauceCodePro"
        "Lekton"
        "LiberationMono"
        "Lilex"
      ];
    })
  ];
}
