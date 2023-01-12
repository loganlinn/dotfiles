let
  flake = builtins.getFlake (toString ./.);
in
{ inherit flake; } // flake // builtins // flake.inputs.nixpkgs.lib
