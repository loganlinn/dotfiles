{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  npmrcFormat =
    let
      ini = pkgs.formats.iniWithGlobalSection { };
    in
    {
      type = (ini.type.getSubOptions [ ]).globalSection.type;
      generate = name: value: ini.generate name { globalSection = value; };
    };
in
{
  options = {
    programs.npm = {
      settings = mkOption {
        # use same type constraints as global section of INI format,
        type = npmrcFormat.type;
        default = { };
      };
    };
  };

  config = {
    programs.npm.settings = {
      fund = false;
      update-notifier = false; # suppress the update notification when using an older version of npm than the latest.
      usage = false;

      userconfig = "${config.xdg.configHome}/npm/config";
      prefix = "${config.xdg.dataHome}/npm";
      cache = "${config.xdg.cacheHome}/npm";
    };

    # i.e. userconfig file (aka npmrc)
    xdg.configFile."npm/config".source = npmrcFormat.generate "npmrc" config.programs.npm.settings;

    home.packages = with pkgs; [
      nodejs
      yarn
      yarn-bash-completion
    ];

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

    programs.zsh.plugins = [
      {
        name = "yarn-completions";
        src = pkgs.fetchFromGitHub {
          owner = "g-plane";
          repo = "zsh-yarn-autocompletions";
          rev = "12e282950d592f32648b980c9edcdf1fd4eefb28";
          hash = "sha256-6G0ace7ooeTAEyXPjU0HvbVjrp9Y/TbMS0xSon9P/P0=";
        };
      }
    ];
  };
}
