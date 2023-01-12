{ inputs, lib, pkgs, ... }:
let
  inherit (lib) attrValues makeExtensible mergeAttrs foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib pkgs;
    self.attrs = import ./attrs.nix {
      inherit lib;
      self = { };
    };
  };

  mylib = makeExtensible (self:
    with self;
    mapModules ./. (file:
      import file {
        inherit self lib pkgs inputs;
      }));
in
mylib.extend (self: super: foldr mergeAttrs { } (attrValues super))
