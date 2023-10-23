{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.wireguard.client;
in
{
  options.my.wireguard.client = {
    enable = mkEnableOption "wireguard client";
    networkInterfaceName = mkOption {
      type = types.str;
      default = "firewalla";
    };
    privateKeyFile = mkOption {
      type = with types; either path str;
    };
    endpoint = mkOption {
      type = types.str;
      default = "ddxl0ys86vr.d.firewalla.org:51820";
    };
    publicKey = mkOption {
      type = types.str;
      default = "MV3h9QahL9HctHUyu3TuT4I3KK7NUA6jpf6+Z3sNc1E=";
    };
    allowedIPs = mkOption {
      type = types.listOf types.str;
      # Or forward only particular subnets
      # allowedIPs = [ "10.100.0.1" "91.108.12.0/22" ];
      default = [ "0.0.0.0/0" ];
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
    };

    networking.wireguard.interfaces."${cfg.networkInterfaceName}" = {
      ips = [ "10.100.0.2/24" ];
      listenPort = 51820;
      privateKeyFile = cfg.privateKeyFile;
      peers = [{
        inherit (cfg) endpoint publicKey allowedIPs;
        persistentKeepalive = 25;
      }];
    };
  };
}
