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
          pynvim
          setuptools
        ] ++ optionals stdenv.isLinux [
          dbus-python
          pygobject3
          pybluez
        ] ++ optionals config.xsession.windowManager.i3.enable [
          i3ipc
        ]);
    };
  };

  config = {
    home.packages = with pkgs; [
      cfg.finalPackage
      poetry
    ];

    home.shellAliases.venv = "${cfg.finalPackage}/bin/python3 -m venv";
  };
}
