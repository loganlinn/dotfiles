{ self
, inputs
, withSystem
, ...
}: {
  flake.nixosModules = import ./modules;

  flake.nixosConfigurations.nijusan = withSystem "x86_64-linux" (system:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs; # TODO remove
        inherit (inputs) nixpkgs home-manager;
        # inherit (system.config) packages; # needed?
      };
      modules = (with inputs.nixos-hardware.outputs.nixosModules; [
        common-cpu-intel
        common-gpu-nvidia-nonprime
        common-pc-ssd
      ]) ++ (with self.nixosModules; [
        bluetooth
        docker
        fonts
        networking
        nix-path
        nix-registry
        nvidia
        pipewire
        printing
        security
        steam
        tailscale
        thunderbolt
      ] ++ [
        # inputs.home-manager.nixosModules.home-manager
        # inputs.sops-nix.nixosModules.sops
        # inputs.grub2-themes.nixosModules.default
        ./nijusan/configuration.nix
        {
          options.my = system.options.my;
          config.my = system.config.my;
        }
      ]);
    });
}
