{ config, pkgs, lib, ... }:

let cfg = config.modules.tailscale; in
{
  options.modules.tailscale = with lib; {
    enable = mkEnableOption "tailscale";

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
    };

    autoconnect = {
      enable = mkEnableOption "Automatically authenticate with Tailscale at startup. Requires authkey.";
      authkey = mkOption {
        type = types.str;
        default = "/var/root/tailscale/authkey";
      };
    };

    ssh = {
      enable = mkEnableOption "Allow SSH in over the public internet";
      ports = mkOption {
        type = with types; listOf port;
        default =
          if config.services.openssh.enable
          then config.services.openssh.ports
          else [ 22 ];
      };
    };

    advertiseExitNode = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    services.tailscale.enable = true;

    # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups.
    networking.firewall.checkReversePath = lib.mkDefault "loose";
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.ssh.enable cfg.ssh.ports;

    # create a oneshot job to authenticate to Tailscale
    systemd.services.tailscale-autoconnect = lib.mkIf cfg.autoconnect.enable {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${cfg.package.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${cfg.package.tailscale}/bin/tailscale up -authkey "$(cat "${cfg.autoconnect.authkey}")"${
          lib.optionalString cfg.advertiseExitNode " --advertise-exit-node"}
      '';
    };
  };
}
