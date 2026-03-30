{
  self,
  ...
}: {
  imports = [
    self.homeModules.common
    self.homeModules.nix-colors
    ../nix/home/dev
    ../nix/home/pretty.nix
  ];
  home.username = "logan";
  home.homeDirectory = "/Users/logan";
  home.stateVersion = "22.11";
}
