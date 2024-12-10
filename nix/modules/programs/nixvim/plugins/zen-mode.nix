{ lib, ... }:
let
  inherit (import ../helpers.nix { inherit lib; }) mkKeymap;
in
{
  programs.nixvim = {
    plugins.zen-mode = {
      enable = true;
      settings = {
        plugins.gitsigns.enabled = true;
        plugins.wezterm.enabled = true;
        plugins.twilight.enabled = true;

      };
    };
    plugins.twilight = {
      enable = true;
      settings = { };
    };
    keymaps = [
      (mkKeymap "nv" "<leader>tz" "Toggle zen mode" {
        __raw = ''function() require("zen-mode").toggle() end'';
      })
    ];
  };
}
