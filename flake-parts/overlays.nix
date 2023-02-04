{ self
, inputs
, lib
, ...
}:

{
  flake.overlays = {
    default = import ../packages;
    fromInputs = lib.composeManyExtensions [
      inputs.emacs.overlays.default
      (_final: prev: {
        inherit (inputs.home-manager.packages.${prev.stdenv.hostPlatform.system}) home-manager;
      })
      (_final: prev: {
        inherit (inputs.devenv.packages.${prev.stdenv.hostPlatform.system}) devenv;
      })
    ];
  };
}
