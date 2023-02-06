{ system ? builtins.currentSystem }:

with builtins;

let
  inherit (self.inputs.flake-parts.lib) evalFlakeModule;
  inherit (self.inputs.nixpkgs) lib;
  inherit (lib) fold recursiveUpdate;

  self = getFlake (toString ./.);

  flakeModule = evalFlakeModule { inherit (self) inputs; } { };

  inputs' = mapAttrs (_: flakeModule.config.perInput system) self.inputs;

  inputs = lib.fold lib.recursiveUpdate { } [ self.inputs inputs' ];

  config = flakeModule.config.perInput system self;

  pkgs = import self.inputs.nixpkgs {
    inherit system;
    overlays = attrValues self.overlays;
  };

  user = getEnv "USER";
  hostname =
    if pathExists "/etc/hostname"
    then head (match "([a-zA-Z0-9\\-]+)\n" (readFile "/etc/hostname"))
    else "";
in

builtins // self // rec {
  inherit config self inputs system pkgs lib user hostname;

  homeConfigurations = self.outputs.legacyPackages.${system}.homeConfigurations;

  hm = homeConfigurations."${user}@${hostname}";
}
