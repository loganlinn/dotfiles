{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    home.packages = with pkgs; [
      xclip
    ];

    services.clipmenu.enable = true;
    services.clipmenu.launcher = lib.mkIf config.programs.rofi.enable "rofi";

    # Additional configuration for clipmenud.
    # Override Service.Environment to set additional environment variables + add xdotool to PATH.
    # see: https://github.com/nix-community/home-manager/blob/43ed7048f670661d1ae2ea0d2f7655e87e7b0461/modules/services/clipmenu.nix#L52C1-L55
    systemd.user.services.clipmenu.Service.Environment = lib.mkForce [
      "PATH=${
        lib.makeBinPath
        (with pkgs; [coreutils findutils gnugrep gnused systemd xdotool])
      }"
      "CM_IGNORE_WINDOW=1Password" # disable recording the clipboard in windows where the windowname matches the given regex
    ];
  };
}
