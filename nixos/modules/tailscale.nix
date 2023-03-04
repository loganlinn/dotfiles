{ config, pkgs, ... }:

{
  # Tailscale
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/tailscale.nix

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale.enable = true;

  # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups.
  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # systemd.services.tailscale-autoconnect = {
  #   description = "Automatic connection to Tailscale";
  #   after = [ "network-pre.target" "tailscale.service" ];
  #   wants = [ "network-pre.target" "tailscale.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig.Type = "oneshot";
  #   script = with pkgs; ''
  #     # wait for tailscaled to settle
  #     sleep 2
  #     # check if we are already authenticated to tailscale
  #     status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
  #     if [ $status = "Running" ]; then # if so, then do nothing
  #       exit 0
  #     fi
  #     key=$(<${config.age.secrets.tailscaleKey.path})
  #     # otherwise authenticate with tailscale
  #     ${tailscale}/bin/tailscale up -authkey $key ${lib.optionalString cfg.exitNode "--advertise-exit-node"} ${cfg.extraUpCommands}
  #     '';
  # };
}

