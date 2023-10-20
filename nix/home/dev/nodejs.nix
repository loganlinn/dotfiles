{ config, lib, pkgs, ... }:

with lib;
with lib.my;

{
  options = {
    my.npm = {
      name = mkOption {
        type = types.str;
        default = config.my.github.username;
      };
      email = mkOption {
        type = types.str;
        default = config.my.email;
      };
      url = mkOption {
        type = types.str;
        default = config.my.homepage;
      };
    };
  };

  config = {

    home.packages = with pkgs; [
      nodejs
      yarn
      yarn-bash-completion
      nodePackages.pnpm
      nodePackages.typescript-language-server
      # nodePackages.typescript
    ];

    home.sessionVariables = {
      # XDG, please
      PNPM_HOME = "${config.xdg.dataHome}/pnpm";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
      NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/npm"; # written to by `npm install --global ...`
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      NODE_REPL_HISTORY = "${config.xdg.stateHome}/nodejs/repl_history";

      # Privacy, please
      GRAPHITE_DISABLE_TELEMETRY = "1";
      APOLLO_TELEMETRY_DISABLED = "1";
      NEXT_TELEMETRY_DISABLED = "1";
      GATSBY_TELEMETRY_DISABLED = "1";
    };

    home.sessionPath = [
      "${config.home.sessionVariables.NPM_CONFIG_PREFIX}/bin"
    ];

    my.shellInitExtra = ''
      # Ensure PNPM_HOME is on path
      if [ -n "$PNPM_HOME" ]; then
        case :$PATH: in
          *:$PNPM_HOME:*) ;;
          *) export PATH=$PNPM_HOME:$PATH
        esac
      fi
    '';

    # https://docs.npmjs.com/cli/v8/using-npm/config
    # $ npm config ls -l
    # $ xh -F 'https://docs.npmjs.com/cli/v8/using-npm/config' | html2text -width 999 | grep DEPRECATED: -B3 | sed -n '/^--$/{n;p}'
    xdg.configFile."npm/config".text = ''
      cache = "${config.xdg.cacheHome}/npm"
      color = true
      fund = false
      git = "${toExe config.programs.git}"
      git-tag-version = true
      init-author-email = "${config.my.npm.email}"
      init-author-name = "${config.my.npm.name}"
      init-author-url = "${config.my.npm.url}"
      sign-git-commit = true
      sign-git-tag = true
      strict-ssl = true
      unicode = true
      update-notifier = false
      usage = false
      user-agent = "npm/{npm-version} node/{node-version}"
    '';
  };
}
