args@{
  self,
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = self.lib.mkSpecialArgs args;
    home-manager.users.${config.my.user.name} =
      { options, config, ... }:
      {
        options.my = args.options.my;
        config.my = args.config.my;
      };
    home-manager.backupFileExtension = "backup"; # i.e. `home-manager --backup ...`
  };
}
