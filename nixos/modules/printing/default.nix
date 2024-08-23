{ lib, ... }:

with lib;

{
  config = mkMerge [
    (mkIf config.services.printing.enable {
      services.printing.cups-pdf.enable = mkDefault true;
      services.printing.startWhenNeeded = mkDefault true;
      services.printing.webInterface = mkDefault false;
      services.printing.drivers = with pkgs; [
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
      ];
    })
    (mkIf (config.services.printing.enable && networking.networkmanager.enable) {
      services.avahi.enable = mkDefault true;
      services.avahi.nssmdns4 = true; # resolve .local domains of printers
      services.avahi.openFirewall = true; # for a WiFi printer
    })
  ];
}
