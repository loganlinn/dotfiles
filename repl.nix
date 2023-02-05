{ system ? builtins.currentSystem }:
let
  self = builtins.getFlake (toString ./.);

  flakeModule = self.inputs.flake-parts.lib.evalFlakeModule { inherit (self) inputs; } { };

  inputs' = builtins.mapAttrs (_: flakeModule.config.perInput system) self.inputs;

  inputs = lib.fold lib.recursiveUpdate { } [ self.inputs inputs' ];

  config = flakeModule.config.perInput system self;

  pkgs = import self.inputs.nixpkgs {
    inherit system;
    overlays = builtins.attrValues self.overlays;
  };

  inherit (self.inputs.nixpkgs) lib;
in

builtins // self // { inherit config self inputs system pkgs lib; }
