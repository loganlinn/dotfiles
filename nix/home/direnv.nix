{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.direnv = {
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    mise.enable = true;
    silent = false;
    stdlib = '''';
    # https://github.com/direnv/direnv/blob/master/man/direnv.toml.1.md
    config = {
      global = {
        warn_timeout = "10s";
      };
      whitelist = {
        prefix = [
          "${config.my.flakeDirectory}"
          "~/src/github.com/${config.my.github.username}"
        ];
      };
    };
  };

}
