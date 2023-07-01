# USAGE: nix repl ./repl.nix --argstr username <username> --argstr hostname <hostname>
with builtins;
{ hostname ? import ../lib/currentHostname.nix
, username ? getEnv "USER"
, system ? currentSystem
}:
let
  self = getFlake (toString ./..);
  inherit (self.inputs) nixpkgs;
  homeConfiguration = self.legacyPackages.${system}.homeConfigurations."${username}@${hostname}";
in
builtins // nixpkgs.lib // homeConfiguration // {
  currentUsername = username;
  currentHostname = hostname;
}
