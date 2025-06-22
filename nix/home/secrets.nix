{
  self,
  config,
  pkgs,
  ...
}:
let
  inherit (config.home) homeDirectory;
in
{
  imports = [
    ./passage.nix
    ./age-op.nix
  ];

  home.packages = with pkgs; [
    age
    age-plugin-yubikey
    # pass
  ];
}
