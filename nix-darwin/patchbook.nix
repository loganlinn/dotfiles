{ inputs, pkgs, lib, ... }: {

  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./modules/system.nix
    ./modules/security.nix
    ./modules/homebrew.nix
    ./modules/skhd.nix
    ./modules/yabai.nix
    ./modules/tailscale.nix
  ];

  users.users.logan = {
    name = "logan";
    description = "Logan Linn";
    shell = pkgs.zsh;
    home = "/Users/logan";
  };

  home-manager.users.logan = {
    imports = [
      ../nix/home/common.nix
      ../nix/home/dev
      ../nix/home/fonts.nix
      ../nix/home/pretty.nix
      ../nix/home/zsh
    ];
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.home.stateVersion = "22.11";

  environment = {
    darwinConfig = ./patchbook.nix;
    # darwinConfig = "$HOME/.dotfiles/nix-darwin/patchbook.nix";
    variables = {
      LANG = "en_US.UTF-8";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  services.nix-daemon.enable = true;

  # services.cachix-agent = {
  #   enable = true;
  #   agentName = "patchbook";
  #   # credentialsFile = "/etc/cachix-agent.token";
  # };

  nix = {
    configureBuildUsers = true;
    gc = {
      automatic = true;
      interval = { Hour = 3; Minute = 15; };
    };
    extraOptions =
      ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      ''
      + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
  };
}
