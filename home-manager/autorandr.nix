{ config, pkgs, lib, ... }:

let
  edids = {
    DellU3818DW = "00ffffffffffff0010acf3a04c5446300e1e0104b55825783eee95a3544c99260f5054a54b00714f81008180a940d1c00101010101014c9a00a0f0402e6030203a00706f3100001a000000ff0039374638503034323046544c0a000000fc0044454c4c20553338313844570a000000fd001855197328000a20202020202001bf02031af14d9005040302071601141f12135a2309070783010000023a801871382d40582c4500706f3100001e565e00a0a0a0295030203500706f3100001acd4600a0a0381f4030203a00706f3100001a2d5080a070402e6030203a00706f3100001a134c00a0f040176030203a00706f3100001a000000000000000000000053";
    LGDualUp = "00ffffffffffff001e6df55bc9df03000a200104b52f34789e2405af4f42ab250f5054210800d1c06140010101010101010101010101c5bc00a0a04052b030203a00d10b1200001a000000fd003b3d1eb231000a202020202020000000fc004c472053445148440a20202020000000ff003231304e54484d37463839370a01550203207123090707480103049012131f2283010000e305c000e60605015252510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d7";
  };
in
{
  programs.autorandr.enable = true;
  programs.autorandr = {
    profiles = {
      home = {
        fingerprint = with edids; {
          DP-0 = DellU3818DW;
          DP-2 = LGDualUp;
        };
        config = {
          DP-0 = {
            enable = true;
            primary = true;
            mode = "3840x1600";
            position = "+2560+980";
            rate = "59.99";
          };
          DP-2 = {
            enable = true;
            mode = "2560x2880";
            rate = "59.98";
          };
        };
      };
    };
    # hooks.predetect = { };
    # hooks.preswitch = { };
    hooks.postswitch = lib.optionalAttrs config.modules.desktop.i3.enable {
      "notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
    };
  };
}
