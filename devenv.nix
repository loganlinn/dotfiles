{ pkgs, ... }:
{
  env = {
    NIX_USER_CONF_FILES = toString ../../nix.conf;
    HOME_MANAGER_OPTS = "--flake ~/.dotfiles -b backup --impure";
  };

  languages.nix.enable = true;

  enterShell = ''
    devenv started.

    printenv | grep '^DEVENV'

    export FLAKE_CONFIG_URI=$PWD
  '';

  scripts."repl".exec = ''exec nix repl repl.nix "$@"'';

  scripts."hm".exec = ''exec home-manager $HOME_MANAGER_OPTS "$@"'';

  scripts."reload".exec = ''direnv reload'';

  pre-commit.hooks = {
    shellcheck.enable = true;
  };

}
