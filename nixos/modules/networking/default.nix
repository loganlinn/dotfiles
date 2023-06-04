{
  services.avahi = {
    enable = true;
    nssmdns = true; # resolve .local domains of printers
    openFirewall = true; # for a WiFi printer
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
