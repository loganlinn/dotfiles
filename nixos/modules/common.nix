{ inputs, config, lib, pkgs, ... }:

with lib;

{
  users.users.${config.my.user.name} = {
    shell = config.my.shell;
    isNormalUser = true;
    home = "/home/${config.my.user.name}";
    createHome = true;
    extraGroups = [ "wheel" "audio" "video" ]
      ++ optional config.networking.networkmanager.enable "networkmanager"
      ++ optional config.programs._1password.enable "op"
      ++ optional config.programs._1password-gui.enable "onepassword"
      ++ optional config.virtualisation.docker.enable "docker"
      ++ optional config.programs.corectrl.enable "corectrl"
      ++ optional config.services.davfs2.enable
      "${config.services.davfs2.davGroup}";
    openssh.authorizedKeys.keys = config.my.authorizedKeys;
  };

  services.openssh.enable = mkDefault true;
  services.openssh.settings.X11Forwarding = mkDefault config.services.xserver.enable;
  services.openssh.startWhenNeeded = mkDefault true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  programs.git.enable = mkDefault true;
  programs.less.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent.enable = mkDefault true;
  programs.gnupg.agent.enableSSHSupport = mkDefault true;

  environment.homeBinInPath = mkDefault true; # Add ~/bin to PATH
  environment.localBinInPath = mkDefault true; # Add ~/.local/bin to PATH
  environment.systemPackages = with pkgs; [
    curl
    fd
    ripgrep
    tree
  ];

  time.timeZone = mkDefault "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  fonts.fontconfig.enable = mkDefault true;
  fonts.enableDefaultPackages = mkDefault true;

  documentation.enable = mkDefault true;
  documentation.dev.enable = mkDefault config.documentation.enable;

  security.sudo.enable = mkDefault true;

  nix.enable = true;
  nix.package = pkgs.nixFlakes;
  nix.settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];
  nix.settings.warn-dirty = false;
  nix.settings.show-trace = mkDefault true;
  nix.settings.trusted-users = [ config.my.user.name ];
  nix.settings.auto-optimise-store = mkDefault true;
  nix.gc.automatic = mkDefault true;
  nix.nixPath =
    [ "nixpkgs=${inputs.nixpkgs}" "home-manager=${inputs.home-manager}" ];
  nix.sshServe.keys = config.my.authorizedKeys;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
  };
}
