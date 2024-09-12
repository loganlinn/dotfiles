{ ... }:

{
  services.tailscale = {
    enable = false;

    # https://login.tailscale.com/admin/dns
    domain = "royal-bee.ts.net";

    magicDNS.enable = true;
  };
}
