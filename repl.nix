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
  # assumption: flake-parts debug is used (https://flake.parts/debug.html)
  mkScopeAttrs = flake:
    builtins // flake // {
      self = flake;

      inherit (flake.currentSystem.allModuleArgs)
        config options pkgs lib;

      hm = let inherit (flake.currentSystem.legacyPackages) homeConfigurations; in
        homeConfigurations."${user}@${hostname}" or
          homeConfigurations'.${hostname} or
            null;

      nixos = let inherit (flake) nixosConfigurations; in
        nixosConfigurations."${user}@${hostname}" or
          nixosConfigurations.${hostname} or
            null;
    };
in
mkScopeAttrs (getFlake (toString ./.))
