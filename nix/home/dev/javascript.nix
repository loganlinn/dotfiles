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
  imports = [
    ../bun
    ../fnm
    ../yarn
  ];

  options = {
    my.npm = {
      settings = mkOption {
        type = npmrcFormat.type;
        default = {};
      };
    };
  };

  config = {
    programs.bun.enable = true;

    programs.zsh = {
      shellAliases = {
        npx = "command npx --ignore-scripts=true";
        ystage = ''${pkgs.fd}/bin/fd yarn.lock "$(git rev-parse --show-toplevel)" -X git add {}'';
        yw = "yarn workspace";
        ywf = "yarn workspaces focus";
        ywl = "yarn workspaces list";
        yws = "yarn workspaces foreach";
      };
    };

    my.npm.settings = {
      fund = false;
      update-notifier = false; # suppress the update notification when using an older version of npm than the latest.
      usage = false;
      userconfig = "${config.xdg.configHome}/npm/config";
      prefix = "${config.xdg.dataHome}/npm";
      cache = "${config.xdg.cacheHome}/npm";
      ignore-scripts = true;
    };

    home.sessionVariables = {
      NPM_CONFIG_USERCONFIG = config.my.npm.settings.userconfig;
    };

    home.sessionPath = [
      "${config.my.npm.settings.prefix}/bin"
    ];

    # i.e. userconfig file (aka npmrc)
    xdg.configFile."npm/config".source = npmrcFormat.generate "npmrc" config.my.npm.settings;
  };
}
