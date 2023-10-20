{ config, lib, pkgs, ... }:

let user = config.my.user.name; in
{
  config = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = user;
      dataDir = "/home/${user}/.local/share/syncthing";
      configDir = "/home/${user}/.config/syncthing";
      group = "users";
      guiAddress = "127.0.0.1:8384";
      overrideFolders = true;
      overrideDevices = true;
      settings.options.globalAnnounceEnabled = false; # Only sync on LAN
      settings.gui.insecureSkipHostcheck = true;
      settings.gui.insecureAdminAccess = true;
      settings.devices = {
        nijusan = {
          id = "ACCDQEP-QCDDRA6-KXGKOCG-DIF7ASM-MH5N6C7-H3LOPKZ-ZTBCYNH-2JSPNQG";
          allowedNetwork = "192.168.0.0/16";
          addresses = ["tcp://nijusan.lan:51820"];
        };
        framework = {
          id = "BQYPZY5-AO2IWIB-4AMJPV3-7UKTGHE-IJFU3TB-ZCFZQOO-XSP7GJP-6J537QE";
          allowedNetwork = "192.168.0.0/16";
          addresses = ["tcp://framework.lan:51820"];
        };
        patchbook = {
          id = "GHE7MGV-PKT6424-MTQXY3I-6PFDPTN-OFH7B26-5U2YJLV-B5KJ6WV-SPD4JQQ";
          allowedNetwork = "192.168.0.0/16";
          addresses = ["tcp://patchbook.lan:51820"];
        };
        reMarkable = {
          id = "ZDWPXZX-K7HF7CF-LVIIVSL-63YDRNR-A73LZY4-SLWMQUM-UTXDSME-YWQFMAV";
          allowedNetwork = "192.168.0.0/16";
          addresses = ["tcp://remarkable.lan:51820"];
        };
      };
    };
  };
}
