let
  flake = builtins.getFlake (toString ./.);
in
flake // builtins // flake.inputs.nixpkgs.lib
