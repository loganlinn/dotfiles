{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      cmd + ctrl - return : open -n -a kitty.app
      cmd + ctrl + shift - return : open -n -a Google\ Chrome.app
      cmd + ctrl - e : open -n -a Emacs.app
    '';
    # https://gist.github.com/Krever/74d43fa38c57c42c355df55faa0a00ee
    # skhdConfig = ''
    #   ctrl - e : yabai -m space --layout bsp
    #   ctrl - s : yabai -m space --layout stack

    #   ctrl - down : yabai -m window --focus stack.next || yabai -m window --focus south
    #   ctrl - up : yabai -m window --focus stack.prev || yabai -m window --focus north
    #   ctrl + alt - left : yabai -m window --focus west
    #   ctrl + alt - right : yabai -m window --focus east

    #   ctrl - 1 : yabai -m space --focus 1
    #   ctrl - 2 : yabai -m space --focus 2
    #   ctrl - 3 : yabai -m space --focus 3
    #   ctrl - 4 : yabai -m space --focus 4
    #   ctrl - 5 : yabai -m space --focus 5
    #   ctrl - 6 : yabai -m space --focus 6

    #   ctrl + shift - 1 : yabai -m window --space 1
    #   ctrl + shift - 2 : yabai -m window --space 2
    #   ctrl + shift - 3 : yabai -m window --space 3
    #   ctrl + shift - 4 : yabai -m window --space 4
    #   ctrl + shift - 5 : yabai -m window --space 5
    #   ctrl + shift - 6 : yabai -m window --space 6

    #   ctrl - f : yabai -m window --toggle float
    #   '';
  };
}
