{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.ghostty = {
    package = lib.mkDefault (if pkgs.stdenv.isLinux then pkgs.ghostty else null);
    installVimSyntax = config.programs.ghostty.package != null;
    enableZshIntegration = config.programs.ghostty.package != null;
    installBatSyntax = config.programs.ghostty.package != null && config.programs.bat.enable;
    settings = {
      config-file = [
        "${config.my.flakeDirectory}/config/ghostty/options.config"
        "${config.my.flakeDirectory}/config/ghostty/keybind.config"
        "${config.my.flakeDirectory}/config/ghostty/keybind.config"
      ]
      ++ (lib.optional pkgs.stdenv.isLinux "${config.my.flakeDirectory}/config/ghostty/linux.config")
      ++ (lib.optional pkgs.stdenv.isDarwin "${config.my.flakeDirectory}/config/ghostty/macos.config")
      ++ [
        "?config.local"
      ];
    };
  };
}
