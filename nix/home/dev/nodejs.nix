{ config, lib, pkgs, ... }:

with lib;
with lib.my;

let

  shellInit = ''
    if [ -z "$NPM_CONFIG_TMP" ] || ! [ -d "$NPM_CONFIG_TMP" ]; then
      if [ -n "$XDG_RUNTIME_DIR" ]; then
        export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"
      elif [ -d "/run/user/$UID" ]; then
        export NPM_CONFIG_TMP="/run/user/$UID"
      fi
    fi
  '';

in

{
  options = {
    my.npm = {
      name = mkOption {
        type = types.str;
        default = config.my.github.user;
      };
      email = mkOption {
        type = types.str;
        default = config.my.email;
      };
      url = mkOption {
        type = types.str;
        default = config.my.website;
      };
    };
  };

  config = {
    home.sessionVariables = {
      GRAPHITE_DISABLE_TELEMETRY = "1";
      APOLLO_TELEMETRY_DISABLED = "1";
      NEXT_TELEMETRY_DISABLED = "1";
      GATSBY_TELEMETRY_DISABLED = "1";

      # XDG... ya heard of it?
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
      NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/npm"; # written to by `npm install --global ...`
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      NODE_REPL_HISTORY = "${config.xdg.stateHome}/nodejs/repl_history";
    };

    home.sessionPath = [ "${config.home.sessionVariables.NPM_CONFIG_PREFIX}/bin" ];

    my.shell.initExtra = shellInit;

    # https://docs.npmjs.com/cli/v8/using-npm/config
    # $ npm config ls -l
    # $ xh -F 'https://docs.npmjs.com/cli/v8/using-npm/config' | html2text -width 999 | grep DEPRECATED: -B3 | sed -n '/^--$/{n;p}'
    xdg.configFile."npm/config".text = ''
      cache = "${config.xdg.cacheHome}/npm"
      color = true
      fund = false
      git = "${getPackageExe config.programs.git}"
      git-tag-version = true
      init-author-email = "${config.my.npm.email}"
      init-author-name = "${config.my.npm.name}"
      init-author-url = "${config.my.npm.url}"
      init-module = "${config.xdg.configHome}/npm/init.js"
      prefix = "${config.xdg.dataHome}/npm"
      shell = "${getPackageExe config.programs.zsh}"
      sign-git-commit = true
      sign-git-tag = true
      strict-ssl = true
      unicode = true
      update-notifier = false
      usage = false
      user-agent = "npm/{npm-version} node/{node-version}"
      userconfig = "${config.xdg.configHome}/npm/config"
    '';
  };
}