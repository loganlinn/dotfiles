with builtins;

{ system ? currentSystem
, user ? (getEnv "USER")
, hostname ? (
    if pathExists "/etc/hostname"
    then head (match "^([^#].*)\n$" (readFile "/etc/hostname"))
    else (getEnv "HOSTNAME")
  )
}:

let

  flake = getFlake (toString ./.);

  lib = import ./lib/extended.nix flake.currentSystem.allModuleArgs.pkgs.lib;

in

builtins // flake.currentSystem.allModuleArgs // lib // {
  inherit lib;

  hm = let inherit (flake.currentSystem.legacyPackages) homeConfigurations; in
    homeConfigurations."${user}@${hostname}" or
      homeConfigurations'.${hostname} or
        null;

  nixos = let inherit (flake) nixosConfigurations; in
    nixosConfigurations."${user}@${hostname}" or
      nixosConfigurations.${hostname} or
        null;
}
