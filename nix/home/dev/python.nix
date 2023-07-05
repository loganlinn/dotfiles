{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.dev.python; in
{

  options.modules.dev.python = {
    package = mkOption {
      type = types.package;
      default = pkgs.python3;
    };

    # TODO:
    # pythonPackages = mkOption {
    #   type =
    #     let
    #       strToPackage = key:
    #         let
    #           packagePath = filter isString (builtins.split "\\." key);
    #           toPackage = p: attr: p.${attr} or (throw "package \"${key}\" not found");
    #         in
    #         foldl' toPackage pkgs.python3Packages packagePath;
    #     in
    #     types.coercedTo types.str strToPackage types.package;
    # };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = cfg.package.withPackages (ps:
        with ps; [
          black
          isort # used by editors
          pipx
          setuptools
        ] ++ optionals config.programs.neovim.enable [
          pynvim
        ] ++ optionals stdenv.isLinux [
          # pybluez
          dbus-python
          pygobject3
          pyxdg
        ] ++ optionals config.xsession.windowManager.i3.enable [
          i3ipc
        ]);
    };
  };

  config = {
    home.packages = with pkgs; [
      cfg.finalPackage
      poetry
      pyright
    ];

    programs.zsh.initExtra = readFile ./python.bash; # shell helpers
  };
}
