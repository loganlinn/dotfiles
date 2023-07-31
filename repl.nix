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
  self = getFlake (toString ./.);

  inherit (self.currentSystem.allModuleArgs) pkgs; # TODO match overlays used in (home|nixos)Configurations

  lib = self.lib.mkHmLib pkgs.lib;
in

builtins // lib // rec {
  inherit self lib;
  inherit (self) inputs;
  inherit (self.currentSystem.allModuleArgs) inputs' self' config options system pkgs;

  hm = let inherit (self.currentSystem.legacyPackages) homeConfigurations; in
    homeConfigurations."${user}@${hostname}" or
      homeConfigurations'.${hostname} or
        null;

  nixos = 
    self.nixosConfigurations."${user}@${hostname}" or
      self.nixosConfigurations.${hostname} or
        null;
}
