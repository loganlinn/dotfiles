{
  pkgs,
  lib,
  ...
}:
with lib;
{
  services.printing = {
    enable = mkDefault true;
    startWhenNeeded = mkDefault true;
    webInterface = mkDefault false;
    cups-pdf.enable = mkDefault false;

    # Share printers over the local network
    browsing = mkDefault true;
    listenAddresses = mkDefault ["*:631"];
    allowFrom = mkDefault [ "all" ];
    defaultShared = mkDefault true;

    drivers = with pkgs; [
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };

  # mDNS/Bonjour for printer discovery
  services.avahi = {
    enable = mkDefault true;
    nssmdns4 = mkDefault true; # resolve .local domains
    publish = {
      enable = mkDefault true;
      userServices = mkDefault true; # publish CUPS printers
    };
    openFirewall = mkDefault true;
  };

  networking.firewall.allowedTCPPorts = [ 631 ]; # IPP
}
