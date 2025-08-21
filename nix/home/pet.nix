{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.pet = {
    settings = {
      General = {
        snippetdirs = [
          "${config.my.flakeDirectory}/config/pet"
        ];
        selectcmd = ''${config.programs.fzf.package}/bin/fzf --ansi'';
        backend = "gist";
        cmd = [
          "/usr/bin/env"
          "bash"
          "-c"
        ];
      };
      Gist = {
        public = false; # public or priate
        auto_sync = false; # sync automatically when editing snippets
      };
    };
    snippets = [
      {
        description = "Interactively select docker images to remove (forcibly).";
        command = ''docker images | fzf --header-lines=1 --accept-nth=3 | xargs docker rmi -f'';
        tag = [ "docker" ];
      }
    ];
  };
}
