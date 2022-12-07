{pkgs, ...}: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    (nerdfonts.override {
      fonts = [
        "DroidSansMono"
        "FiraCode"
        "JetBrainsMono"
      ];
    })
  ];
}
