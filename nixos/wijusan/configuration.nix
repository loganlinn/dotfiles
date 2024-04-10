{ inputs, self, config , pkgs , lib , nix-colors, ...  }:

with lib;

{
  imports = [
    # self.nixosModules.common
    self.nixosModules.wsl
  ];

  networking.hostName = "wijusan";

  home-manager.users.logan = import ../home-manager/wijusan.nix;

  system.stateVersion = "23.11";
}