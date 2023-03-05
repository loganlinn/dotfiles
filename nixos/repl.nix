# USAGE: nix repl ./repl.nix --argstr hostname <hostname>
with builtins;

let
  currentHostname = import ../lib/currentHostname.nix;
  self = getFlake (toString ./..);
  inherit (self.inputs.nixpkgs) lib;
in

{ hostname ? currentHostname }:

self.nixosConfigurations.${hostname} // {
  inherit self lib;
  currentHostname = hostname;
}
