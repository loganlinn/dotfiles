{self, ...}: {
  imports = [
    self.darwinModules.common
    self.darwinModules.home-manager
  ];

  homebrew.enable = true;
  homebrew.brewPrefix = "/opt/homebrew/bin";

  home-manager.users.logan = {
    options,
    config,
    ...
  }: {
    imports = [
      self.homeModules.common
      self.homeModules.nix-colors
      ../nix/home/dev
      ../nix/home/pretty.nix
    ];
    home.stateVersion = "22.11";
  };
}
