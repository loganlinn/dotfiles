{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.kernelModules = ["hid-apple"];

  # hid_apple module options
  #
  # fnmode - Mode of top-row keys
  #   0 - disabled
  #   1 - normally media keys, switchable to function keys by holding Fn key (=auto on Apple keyboards)
  #   2 - normally function keys, switchable to media keys by holding Fn key (=auto on non-Apple keyboards)
  #   3 - auto (Default)
  # iso_layout - Enable/disable hardcoded ISO layout of the keyboard. Possibly relevant for international keyboard layouts
  #   0 - not ISO (=auto on ANSI keyboards)
  #   1 - ISO (=auto on ISO keyboards)
  #  -1 - auto (Default)
  # swap_opt_cmd - Swap the Option (Alt) and Command (Flag) keys
  #   0 - as silkscreened, Mac layout (Default)
  #   1 - swapped, PC layout
  # swap_fn_leftctrl - Swap the Fn and L_Control keys
  #   0 - as silkscreened, Mac layout (Default)
  #   1 - swapped, PC layout
  boot.extraModprobeConfig = "options hid_apple fnmode=2 swap_opt_cmd=1";
}
