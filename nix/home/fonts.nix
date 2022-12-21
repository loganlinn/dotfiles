{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    cascadia-code
    dejavu_fonts
    fantasque-sans-mono
    fira-code
    fira-code-symbols
    iosevka
    jetbrains-mono
    terminus-nerdfont
    victor-mono
    ankacoder
    (nerdfonts.override {
      fonts = [
        "DejaVuSansMono"
        "DroidSansMono"
        "FiraCode"
        "JetBrainsMono"
      ];
    })
  ];
}
