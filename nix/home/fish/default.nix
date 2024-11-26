{ pkgs, lib, ... }:
{
  config = {
    programs.fish = {
      enable = lib.mkDefault true;
      plugins = with pkgs.fishPlugins; [
        # fzf # https://github.com/PatrickF1/fzf.fish
        # pisces # https://github.com/laughedelic/pisces
        # puffer # https://github.com/nickeb96/puffer-fish
        # bass # https://github.com/edc/bass
        # plugin-sudope # https://github.com/oh-my-fish/plugin-sudope
      ];
    };
  };
}
