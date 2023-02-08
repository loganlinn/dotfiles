{ pkgs, ... }:
{
  env = {
    NIX_USER_CONF_FILES = toString ../../nix.conf;
  };

  languages.nix.enable = true;

  scripts."repl".exec = ''exec nix repl repl.nix "$@"'';

  scripts."reload".exec = ''direnv reload'';
}
