{
  inputs',
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  fennel = pkgs.lua54Packages.fennel;
  fennel-lua = ''
    --{{{fennel
    debug = { traceback = function() end } -- workaround for https://github.com/wez/wezterm/issues/5323#issuecomment-2095316976
    package.path = "${fennel}/share/lua/${fennel.lua.luaversion}/?.lua;" .. package.path
    --}}}fennel
  '';
  dracula = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "wezterm";
    rev = "0db525a46b5242ee15fd4a52f887e172fbde8e51";
    hash = "sha256-sEoXqIAqedezT7cA0HhPsIfu1bWWxJS5+cd7nwK/Aps=";
  };
  _30log = pkgs.fetchFromGitHub {
    owner = "Yonaba";
    repo = "30log";
    rev = "173f45756d99426d89990388e5d8c8e38b9695b9";
    hash = "sha256-FojMuBbyw/XyQIMF8PeQFF3GbO55Nz3/05yXGYdz4dY=";
  };
in {
  config = mkIf config.programs.wezterm.enable {
    programs.wezterm = {
      package = inputs'.wezterm.packages.default;

      enableBashIntegration = mkDefault true;
      enableZshIntegration = mkDefault true;
      extraConfig = ''
        ${fennel-lua}

        local config = require('dotfiles.wezterm')

        config.front_end    = config.front_end or "WebGpu" -- https://github.com/wez/wezterm/issues/6005
        config.color_scheme = config.color_scheme or "Dracula (Official)"

        return config
      '';
    };

    home.shellAliases.set-user-var = ''printf "\033]1337;SetUserVar=%s=%s\007"'';

    my.shellScripts.wezterm-pane-info = {
      runtimeInputs = [pkgs.jq];
      text = ''
        pane_id=''${1:-''${WEZTERM_PANE}}
        wezterm cli list --format=json | jq --argjson pane_id "''${pane_id?}" '.[] | select(.pane_id == $pane_id)'
      '';
    };

    xdg.configFile = {
      "wezterm/dotfiles".source =
        mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/wezterm/dotfiles";
      "wezterm/colors/dracula".source = dracula;
      "wezterm/lib/30log.lua".source = "${_30log}/30log.lua";
      "wezterm/lib/30log-global.lua".source = "${_30log}/30log-global.lua";
      "wezterm/lib/30log-singleton.lua".source = "${_30log}/30log-singleton.lua";
    };
  };
}
