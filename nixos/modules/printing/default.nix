{
  pkgs,
  lib,
  ...
}:
with lib; {
  services.printing.cups-pdf.enable = mkDefault true;
  services.printing.startWhenNeeded = mkDefault true;
  services.printing.webInterface = mkDefault false;
  services.printing.drivers = with pkgs; [
    brlaser
    brgenml1lpr
    brgenml1cupswrapper
  ];
  # services.avahi.enable = mkDefault config.networking.networkmanager.enable;
  # services.avahi.nssmdns4 = mkDefault config.networking.networkmanager.enable; # resolve .local domains of printers
  # services.avahi.openFirewall = mkDefault config.networking.networkmanager.enable; # for a WiFi printer
}
