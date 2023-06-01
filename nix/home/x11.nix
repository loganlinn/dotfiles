{pkgs, ...}: {
  imports = [
    ./autorandr.nix
  ];

  home.packages = with pkgs; [
    arandr
    xdotool
    wmctrl
  ];
}
