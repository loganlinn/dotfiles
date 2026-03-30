{self, ...}: {
  imports = [
    self.darwinModules.common
  ];

  homebrew.enable = true;
  homebrew.prefix = "/opt/homebrew";

  home-manager.users.logan = import ../home-manager/patchbook.nix;
}
