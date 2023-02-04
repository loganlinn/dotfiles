{ withSystem, ... }:

{
  # perSystem = ...;

  # nixosConfigurations.nijusan = withSystem "x86_64-linux" (ctx@{ pkgs, ... }:
  #   pkgs.nixos ({ config, lib, packages, pkgs, ... }: {
  #     _module.args.packages = ctx.config.packages;
  #     imports = [ ./nijusan.nix ];
  #   }));
}
