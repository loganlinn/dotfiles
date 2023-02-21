{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOptionDefault;
in
{

  config = {

    users.users.logan = mkOptionDefault {
      name = "logan";
      description = "Logan Linn";
      shell = pkgs.zsh;
      home = "/Users/logan";
    };

    modules.fonts.enable = mkOptionDefault true;

    services.nix-daemon.enable = mkOptionDefault true;

    home-manager = mkOptionDefault {
      # By default, Home Manager uses a private pkgs instance that is configured via the home-manager.users.<name>.nixpkgs options.
      # Instead, use the global pkgs that is configured via the system level nixpkgs options.
      # This saves an extra Nixpkgs evaluation, adds consistency, and removes the dependency on NIX_PATH, which is otherwise used for importing Nixpkgs.
      useGlobalPkgs = true;

      # By default, user packages will be ignored in favor of environment.systemPackages.
      # Instead install to /etc/profiles/per-user/$USERNAME
      useUserPackages = true;
    };

    nix = mkOptionDefault {
      configureBuildUsers = true;
      gc = {
        automatic = true;
        interval = { Hour = 4; Minute = 15; };
      };
      extraOptions = ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
    };
  };
}
