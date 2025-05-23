{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  environment.systemPackages = with pkgs; [
    rmapi
    rmview
    # remarkable-mouse
    restream
    (makeDesktopItem {
      name = "reStream";
      desktopName = "reStream";
      exec = "${pkgs.restream}/bin/restream";
    })
  ];
}
