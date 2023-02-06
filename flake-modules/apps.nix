{ self, ... }:

{
  perSystem = { pkgs, ... }: {
    apps = self.lib.importDirToAttrs ../apps;
  };
}
