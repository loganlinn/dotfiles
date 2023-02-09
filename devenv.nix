{ pkgs, ... }:
{
  env = {
    NIX_USER_CONF_FILES = toString ../../nix.conf;
  };

  languages.nix.enable = true;

  scripts = {
    "repl".exec = ''exec nix repl --file repl.nix "$@"'';
    "switch".exec = ''hm switch "$@"'';
    "option".exec = ''home-manager option "$@"'';
    "reload".exec = ''direnv reload'';
    # "config".exec = ''hm config'';
  };
}
