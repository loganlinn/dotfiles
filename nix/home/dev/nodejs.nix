{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  npmrcFormat = let
    ini = pkgs.formats.iniWithGlobalSection {};
  in {
    type = (ini.type.getSubOptions []).globalSection.type;
    generate = name: value: ini.generate name {globalSection = value;};
  };
in {
  options = {
    programs.npm = {
      settings = mkOption {
        # use same type constraints as global section of INI format,
        type = npmrcFormat.type;
        default = {};
      };
    };

    programs.fnm = {
      # enable = mkEnableOption "fnm (node.js version manager)"; # TODO
      settings = mkOption {
        type = types.attrs;
        default = {
          use-on-cd = false;
          version-file-strategy = "recursive";
          corepack-enabled = true;
        };
      };
    };
  };

  config = {
    home.packages = with pkgs; [
      # nodejs
      fnm
      bun
    ];

    programs.zsh.initExtra = ''
      # initialize fnm (node.js version manager)
      eval "$(fnm env --shell zsh ${
        concatStringsSep " " (cli.toGNUCommandLine {} config.programs.fnm.settings)
      })"
    '';

    programs.bash.initExtra = ''
      # initialize fnm (node.js version manager)
      eval "$(fnm env --shell bash ${
        concatStringsSep " " (cli.toGNUCommandLine {} config.programs.fnm.settings)
      })"
    '';

    programs.npm.settings = {
      fund = false;
      update-notifier = false; # suppress the update notification when using an older version of npm than the latest.
      usage = false;
      userconfig = "${config.xdg.configHome}/npm/config";
      prefix = "${config.xdg.dataHome}/npm";
      cache = "${config.xdg.cacheHome}/npm";
    };

    home.sessionVariables = {
      # XDG, please
      NPM_CONFIG_USERCONFIG = config.programs.npm.settings.userconfig;
      # Privacy, please
      GRAPHITE_DISABLE_TELEMETRY = "1";
      APOLLO_TELEMETRY_DISABLED = "1";
      NEXT_TELEMETRY_DISABLED = "1";
      GATSBY_TELEMETRY_DISABLED = "1";
    };

    home.sessionPath = [
      "${config.programs.npm.settings.prefix}/bin"
    ];

    # i.e. userconfig file (aka npmrc)
    xdg.configFile."npm/config".source = npmrcFormat.generate "npmrc" config.programs.npm.settings;
  };
}
