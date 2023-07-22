{
  services.avahi = {
    enable = true;
    nssmdns = true; # resolve .local domains of printers
    openFirewall = true; # for a WiFi printer
  };

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
