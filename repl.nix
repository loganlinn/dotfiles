{ system ? builtins.currentSystem }:
let
  inherit (builtins) getFlake mapAttrs attrValues;
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

in

builtins // self // {
  inherit config self inputs system pkgs lib;
}
