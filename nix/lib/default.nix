{ lib
, pkgs
, ...
} @ args:

let
  inherit (lib) attrValues makeExtensible mergeAttrs foldr;
  inherit (modules) mapModules;

  # Bootstrap with modules.nix...
  modules = import ./modules.nix {
    inherit lib pkgs;
    self.attrs = import ./attrs.nix {
      inherit lib;
      self = { };
    };
  };

  # Import the rest of ./*.nix
  mylib = makeExtensible
    (self:
      with self;
      mapModules ./. (file:
        import file (args // {
          inherit self lib pkgs inputs;
        })
      ));
in
mylib.extend (self: super: foldr mergeAttrs { } (attrValues super))
