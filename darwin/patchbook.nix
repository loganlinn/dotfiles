{self, ...}: {
  imports = [
    self.darwinModules.common
    self.darwinModules.home-manager
  ];

  homebrew.enable = true;
  homebrew.prefix = "/opt/homebrew";

  home-manager.users.logan = import ../home-manager/patchbook.nix;
}
