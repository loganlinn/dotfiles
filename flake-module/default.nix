top@{
  self,
  inputs,
  moduleWithSystem,
  withSystem,
  getSystem,
  ...
}:

let
  nix-colors = import ../nix-colors/extended.nix inputs;

  mkLib =
    let
      withMy = import ../lib/extended.nix;
      withHm = import "${inputs.home-manager}/modules/lib/stdlib-extended.nix";
    in
    lib: withHm (withMy lib);

  mkSpecialArgs =
    {
      inputs',
      self',
      pkgs,
      lib ? pkgs.lib,
      ...
    }:
    {
      inherit self inputs nix-colors;
      inherit inputs' self';
      lib = mkLib lib;
    };

  mkNixosSystem =
    system: modules:
    withSystem system (
      systemArgs@{
        self,
        self',
        inputs',
        config,
        pkgs,
        ...
      }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = mkSpecialArgs systemArgs;
        modules = [
          ../options.nix
          {
            nixpkgs.config = pkgs.config;
            nixpkgs.overlays = pkgs.overlays;
          }
        ] ++ modules;
      }
    );

  # Home Manager "Standalone" setup
  mkHomeConfiguration =
    system: modules:
    withSystem system (
      ctx@{
        options,
        config,
        self',
        inputs',
        pkgs,
        ...
      }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ../options.nix ] ++ modules;
        extraSpecialArgs = mkSpecialArgs ctx;
      }
    );

  mkDarwinSystem =
    system: modules:
    withSystem system (
      systemArgs@{
        self,
        self',
        inputs',
        config,
        pkgs,
        ...
      }:
      inputs.nix-darwin.lib.darwinSystem {
        inherit pkgs;
        modules = [ ../options.nix ] ++ modules;
        specialArgs = mkSpecialArgs systemArgs;
      }
    );

  # Inputs
  #
  # `system`
  #
  # : The system triple (string). Defaults to currentSystem.
  #
  # `hostname`
  #
  # : The name of host for locating nixos/darwin config.
  #
  # `user`
  #
  # : The name of user for locating home-manager config. Defaults to value of USER env.
  #
  mkReplAttrs =
    {
      system ? null,
      hostname ? import ../lib/currentHostname.nix,
      user ? (builtins.getEnv "USER"),
    }:
    assert hostname != null;
    assert user != null;
    let
      perSys =
        if system == null then
          self.currentSystem
        else if builtins.isString system then # from system triple string (i.e. builtins.currentSystem)
          getSystem system
        else
          system;
      nixos = self.nixosConfigurations.${hostname} or null;
      darwin = self.darwinConfigurations.${hostname} or null;
      hm =
        let
          standalone =
            let
              homeConfigurations = perSys.legacyPackages.homeConfigurations or null;
            in
            homeConfigurations."${user}@${hostname}" or homeConfigurations.${user}
              or homeConfigurations.${hostname} or null;
          cfg = nixos.config.home-manager or darwin.config.home-manager or null;
          opt = nixos.options.home-manager or darwin.options.home-manager or null;
        in
        if standalone != null then
          standalone
        else if (cfg.users.${user} or null) != null then
          {
            config = cfg.users.${user};
            options = opt.users.type.getSubOptions [ ]; # hack
          }
        else
          null;
    in
    builtins
    // rec {
      inherit
        self
        inputs
        nixos
        darwin
        hm
        ;
      inherit (perSys) legacyPackages;
      inherit (perSys.allModuleArgs)
        inputs'
        self'
        config
        options
        system
        pkgs
        ;
      lib = mkLib pkgs.lib;
    };
in
{
  imports = [
    {
      flake.nixosModules = import ../nixos/modules;
      # flake.darwinModules = import ../darwin/modules;
    }
  ];

  flake.lib = {
    inherit
      mkSpecialArgs
      mkNixosSystem
      mkHomeConfiguration
      mkDarwinSystem
      mkReplAttrs
      ;
    my = (mkLib top.lib).my;
  };

  flake.nixosModules.home-manager = moduleWithSystem (
    systemArgs@{
      inputs',
      self',
      options,
      config,
      pkgs,
    }:
    ctx: {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = self.lib.mkSpecialArgs systemArgs;
        home-manager.users.${config.my.user.name} =
          { options, config, ... }:
          {
            options.my = ctx.options.my;
            config.my = ctx.config.my;
          };
        home-manager.backupFileExtension = "backup"; # i.e. `home-manager --backup ...`
      };
    }
  );

  # NB: 'homeModules' preferred over 'homeManagerModules', see https://github.com/NixOS/nix/blob/af26fe39344faff70e009d980820b8667c319cb2/src/nix/flake.cc#L810-L811
  flake.homeModules = {
    common = import ../nix/home/common.nix;
    nix-colors =
      { lib, ... }:
      {
        imports = [ nix-colors.homeManagerModule ];
        colorScheme = lib.mkDefault nix-colors.colorSchemes.doom-one;
      };
    # secrets = inputs.agenix.homeManagerModules.default;
  };

  flake.darwinModules = {
    common = import ../darwin/modules/common.nix;
    home-manager = moduleWithSystem (
      ctx@{
        inputs',
        self,
        self',
        options,
        config,
        pkgs,
      }:
      { config, lib, ... }:
      {
        imports = [
          inputs.home-manager.darwinModules.home-manager
        ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = mkSpecialArgs ctx;
          home-manager.backupFileExtension = "backup";
          home-manager.users.${config.my.user.name} = import ../options.nix;
        };
      }
    );
  };
}
