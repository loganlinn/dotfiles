# USAGE: nix repl ./repl.nix --argstr username <username> --argstr hostname <hostname>
with builtins;

let
  currentUsername = getEnv "USER";
  currentHostname = import ../lib/currentHostname.nix;
  self = getFlake (toString ./..);
  inherit (self.inputs.nixpkgs) lib;
in

{ hostname ? currentHostname
, username ? currentUsername
, system ? currentSystem
}:

self.legacyPackages.${system}.darwinConfigurations."${username}@${hostname}" // {
  inherit self lib;
  currentUsername = username;
  currentHostname = hostname;
}
