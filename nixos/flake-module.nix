{ self
, inputs
, withSystem
, ...
}: {
  # flake.nixosModules = import ./modules;

  # flake.nixosConfigurations.nijusan = withSystem "x86_64-linux" (system:
  #   inputs.nixpkgs.lib.nixosSystem {
  #     specialArgs = {
  #       inherit self inputs;
  #     };

  #     modules = (with inputs.nixos-hardware.outputs.nixosModules; [
  #       common-cpu-intel
  #       common-gpu-nvidia-nonprime
  #       common-pc-ssd
  #     ]) ++ (with self.nixosModules; [
  #       bluetooth
  #       docker
  #       networking
  #       nix-registry
  #       nvidia
  #       pipewire
  #       printing
  #       security
  #       steam
  #       tailscale
  #       thunar
  #       thunderbolt
  #     ] ++ [
  #       {
  #         nixpkgs.overlays = [self.overlays.default];
  #       }
  #       # inputs.home-manager.nixosModules.home-manager
  #       # inputs.grub2-themes.nixosModules.default
  #       ./nijusan/configuration.nix
  #       {
  #         options.my = system.options.my;
  #         config.my = system.config.my;
  #       }
  #     ]);
  #   });
}
