{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.my;

let
  generateNpmrc = cfg: generators.toINIWithGlobalSection { } { globalSection = cfg; };

  userConfig = {
    fund = false;
    git-tag-version = true;
    init-author-email = config.my.email;
    init-author-name = config.my.github.username;
    init-author-url = config.my.homepage;
    sign-git-commit = true;
    sign-git-tag = true;
    strict-ssl = true;
    unicode = true;
    update-notifier = false;
    usage = false;
  };
in
{
  config = mkMerge [
    {
      home.packages = with pkgs; [
        nodejs
        yarn
        yarn-bash-completion
        # nodePackages.pnpm
        # nodePackages.typescript-language-server
        # nodePackages.typescript
      ];

      home.sessionVariables = {
        # Privacy, please
        GRAPHITE_DISABLE_TELEMETRY = "1";
        APOLLO_TELEMETRY_DISABLED = "1";
        NEXT_TELEMETRY_DISABLED = "1";
        GATSBY_TELEMETRY_DISABLED = "1";
      };

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

      my.shellInitExtra = ''
        # Ensure PNPM_HOME is on path
        if [ -n "$PNPM_HOME" ]; then
          case :$PATH: in
            *:$PNPM_HOME:*) ;;
            *) export PATH=$PNPM_HOME:$PATH
          esac
        fi
      '';
    }
    (mkIf (!config.xdg.enable) {
      home.file.".npmrc".text = generateNpmrc userConfig;
    })
    (mkIf config.xdg.enable {
      # NPM refuses to adopt XDG conventions upstream, so I enforce it myself.
      home.sessionVariables = mkDefault {
        PNPM_HOME = "$XDG_DATA_HOME/pnpm";
        NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/config";
        NPM_CONFIG_CACHE = "$XDG_CACHE_HOME/npm";
        NPM_CONFIG_PREFIX = "$XDG_CACHE_HOME/npm";
        NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
        NODE_REPL_HISTORY = "$XDG_CACHE_HOME/node/repl_history";
      };

      home.sessionPath = [
        "${config.xdg.dataHome}/npm/bin"
      ];

      xdg.configFile."npm/config".text = generateNpmrc (
        userConfig
        // {
          cache = "$${XDG_CACHE_HOME}/npm";
          prefix = "$${XDG_DATA_HOME}/npm";
          tmp = "$${XDG_RUNTIME_DIR}/npm";
        }
      );
    })
  ];
}
