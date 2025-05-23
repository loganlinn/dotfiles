lib0: let
  lib = import ./.;
in
  lib0.extend (final: _: {my = lib {lib = final;};})
