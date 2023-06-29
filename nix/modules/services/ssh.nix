{ options, config, lib, ... }:

with lib;

let cfg = config.modules.services.ssh;
in
{
  options.modules.services.ssh = {
    enable = mkEnableOption "ssh service";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      kbdInteractiveAuthentication = false;
      passwordAuthentication = false;
    };

    user.openssh.authorizedKeys.keys =
      if config.user.name == "logan"
      then [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa ${config.user.name}@loganlinn.com" ]
      else [ ];
  };
}
