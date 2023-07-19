{
  inputs ? (builtins.getFlake (builtins.toString ../..)).inputs,
  nixpkgs ? inputs.nixpkgs,
  home-manager ? inputs.home-manager,
  ...
}: {
  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
    "home-manager=${home-manager}"
  ];
}
