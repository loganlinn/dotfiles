{ config, options, lib, home-manager, pkgs, ... }:
with lib;
let
  mkOpt = type: default: mkOption { inherit type default; };

  mkOpt' = type: default: description:
    mkOption { inherit type default description; };

  mkBoolOpt = default:
    mkOption {
      inherit default;
      type = types.bool;
      example = true;
    };
in {
  options = with types; {
    dotfiles = let t = either str path;
    in {

      # Allow for dotfile location flexibility, defaulting to parent dir.
      dir = mkOpt t (findFirst pathExists (toString ../../.)
        [ "${config.user.home}/.dotfiles" ]);
      configDir = mkOpt t "${config.dotfiles.dir}/config";
      modulesDir = mkOpt t "${config.dotfiles.dir}/nix/modules";
      themesDir = mkOpt t "${config.dotfiles.modulesDir}/themes";
    };

    home = {
      file = mkOpt' attrs { } "Files to place directly in $HOME";
      configFile = mkOpt' attrs { } "Files to place in $XDG_CONFIG_HOME";
      dataFile = mkOpt' attrs { } "Files to place in $XDG_DATA_HOME";
      defaultApplications = mkOpt' attrs { } "XDG/MIME default applications";
      services = mkOpt' attrs { } "Home-manager provided user services";
      programs = mkOpt' attrs { } "Home-manager provided programs";
      activation = mkOpt' attrs { } "Home-manager provided activation";
    };

    user = mkOpt' attrs { } "Personal user management";
    work = mkOpt' attrs { } "Business user management";

    env = mkOption {
      type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
      apply = mapAttrs (n: v:
        # Handle an array of items separated by `:` e.g. PATH.
        if isList v then
          concatMapStringsSep ":" (x: toString x) v
        else
          (toString v));
      default = { };
      description = "Global environment variables";
    };

    # Elaborate the current system for convenience elsewhere.
    targetSystem = mkOpt' attrs
      (systems.elaborate { system = pkgs.stdenv.targetPlatform.system; })
      "Elaborated description of the target system";
  };

  config = {
    user = let
      user = builtins.getEnv "USER";
      name = if elem user [ "" "root" ] then "logan" else user;
    in {
      inherit name;
      description = "Logan Linn";
    } // optionalAttrs config.targetSystem.isLinux {
      uid = 1000;
      extraGroups = [ "wheel" ];
      group = "users";
      home = "/home/${name}";
      isNormalUser = true;
    }
    // optionalAttrs config.targetSystem.isDarwin { home = "/Users/${name}"; };

    users.users.${config.user.name} = mkAliasDefinitions options.user;
    nix = let users = [ "root" config.user.name ];
    in {
      settings = {
        trusted-users = users;
        allowed-users = users;
      };
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      # NOTE: Home-manager shortened maps are as follows:
      # home.file        ->  home-manager.users.<user>.home.file
      # home.configFile  ->  home-manager.users.<user>.home.xdg.configFile
      # home.dataFile    ->  home-manager.users.<user>.home.xdg.dataFile
      # home.services    ->  home-manager.users.<user>.home.services
      # home.programs    ->  home-manager.users.<user>.home.programs
      users.${config.user.name} = {
        home = {
          file = mkAliasDefinitions options.home.file;
          activation = mkAliasDefinitions options.home.activation;
          stateVersion = "21.11";
        };
        xdg = {
          enable = true;
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile = mkAliasDefinitions options.home.dataFile;
        } // optionalAttrs config.targetSystem.isLinux {
          mime.enable = true;
          mimeApps = {
            enable = true;
            defaultApplications =
              mkAliasDefinitions options.home.defaultApplications;
          };
        };
        services = mkAliasDefinitions options.home.services;
        programs = mkAliasDefinitions options.home.programs;
      };
    };

    # Ensure any existing PATH managed outside of Nix gets respected.
    env.PATH = [ "$PATH" ];

    # Merge Nix environment variables declared by modules.
    environment.extraInit = concatStringsSep "\n"
      (mapAttrsToList (n: v: ''export ${n}="${v}"'') config.env);

    # Secrets.
    # TODO: Evaluate `agenix` and other Nix store encryption options.
    secrets = let path = "${(builtins.getEnv "XDG_DATA_HOME")}/secrets.nix";
    in if pathExists path then import path else { };
  };
}
