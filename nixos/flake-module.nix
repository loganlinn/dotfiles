{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosModules = import ./modules;

  flake.nixosConfigurations.nijusan = withSystem "x86_64-linux" (system:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs; # TODO remove
        inherit (inputs) nixpkgs home-manager;
        # inherit (system.config) packages; # needed?
      };
      modules = [
        # inputs.home-manager.nixosModules.home-manager
        # inputs.sops-nix.nixosModules.sops
        # inputs.grub2-themes.nixosModules.default
        inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
        inputs.nixos-hardware.outputs.nixosModules.common-gpu-nvidia-nonprime
        inputs.nixos-hardware.outputs.nixosModules.common-pc-ssd
        # self.nixosModules.minecraft-server
        self.nixosModules.bluetooth
        self.nixosModules.docker
        self.nixosModules.fonts
        self.nixosModules.networking
        self.nixosModules.nix-path
        self.nixosModules.nix-registry
        self.nixosModules.nvidia
        self.nixosModules.pipewire
        self.nixosModules.printing
        self.nixosModules.security
        self.nixosModules.steam
        self.nixosModules.tailscale
        self.nixosModules.thunar
        self.nixosModules.thunderbolt
        ./nijusan/configuration.nix
        {
          options.my = system.options.my;
          config.my = system.config.my;
        }
      ];
    });
}
