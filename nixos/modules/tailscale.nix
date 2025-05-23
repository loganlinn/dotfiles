{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.my.tailscale;

  tailscaleCfg = config.services.tailscale;
  tailscalePkg = tailscaleCfg.package;
  tailscaleExe = getExe tailscalePkg;
in {
  options.my.tailscale = {
    # autoconnect = {
    #   enable = mkEnableOption "Automatically authenticate with Tailscale at startup. Requires authkey.";
    #   authkey = mkOption {
    #     type = types.str;
    #     default = "/var/root/tailscale/authkey";
    #   };
    # };
    # advertiseExitNode.enable = mkEnableOption "advertise exit node?";

    ssh = {
      enable = mkEnableOption "Allow SSH in over the public internet";
      ports = mkOption {
        type = with types; listOf port;
        default =
          if config.services.openssh.enable
          then config.services.openssh.ports
          else [22];
      };
    };
  };

  config = mkIf tailscaleCfg.enable {
    environment.systemPackages = [
      tailscalePkg
    ];

    services.tailscale = {
      # useRoutingFeatures = "client";
      permitCertUid = config.my.user.name;
    };

    my.sudo.commands = [
      {
        command = tailscaleExe;
      }
    ];

    # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups.
    networking.firewall = {
      checkReversePath = mkDefault "loose";
      trustedInterfaces = [tailscaleCfg.interfaceName];
      allowedUDPPorts = [tailscaleCfg.port];
      allowedTCPPorts = mkIf cfg.ssh.enable cfg.ssh.ports;
    };

    # create a oneshot job to authenticate to Tailscale
    # systemd.services.tailscale-autoconnect = mkIf cfg.autoconnect.enable {
    #   description = "Automatic connection to Tailscale";

    #   # make sure tailscale is running before trying to connect to tailscale
    #   after = [ "network-pre.target" "tailscale.service" ];
    #   wants = [ "network-pre.target" "tailscale.service" ];
    #   wantedBy = [ "multi-user.target" ];

    #   # set this service as a oneshot job
    #   serviceConfig.Type = "oneshot";

    #   # have the job run this shell script
    #   script = ''
    #     # wait for tailscaled to settle
    #     sleep 2

    #     # check if we are already authenticated to tailscale
    #     status="$(${cfg.package.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
    #     if [ $status = "Running" ]; then # if so, then do nothing
    #       exit 0
    #     fi

    #     # otherwise authenticate with tailscale
    #     ${cfg.package.tailscale}/bin/tailscale up -authkey "$(cat "${cfg.autoconnect.authkey}")"${
    #       optionalString cfg.advertiseExitNode.enable " --advertise-exit-node"}
    #   '';
    # };
  };
}
