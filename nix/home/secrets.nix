{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./passage.nix
    ./age-op.nix
  ];

  home.packages = with pkgs; [
    age
    age-plugin-yubikey
  ];
}
