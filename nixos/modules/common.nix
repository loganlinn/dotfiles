{ inputs, config, lib, pkgs, ... }:

with lib;

let
  systemdSupport = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.systemd;
in
{
  imports = [
    ../../options.nix
  ];

  networking.networkmanager.enable = mkDefault true;

  users.defaultUserShell = pkgs.zsh;
  users.users.${config.my.user.name} = {
    shell = config.my.user.shell or config.users.defaultUserShell;
    home = "/home/${config.my.user.name}";
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" "audio" "video" ]
      ++ (config.my.user.groups or [ ])
      ++ optional config.networking.networkmanager.enable "networkmanager"
      ++ optional config.programs._1password-gui.enable "onepassword"
      ++ optional config.programs._1password.enable "op"
      ++ optional config.programs.corectrl.enable "corectrl"
      ++ optional config.virtualisation.docker.enable "docker"
      ++ optional config.virtualisation.libvirtd.enable "libvirtd"
      ++ optional config.services.davfs2.enable
      "${config.services.davfs2.davGroup}";
    openssh.authorizedKeys.keys = config.my.authorizedKeys;
  };

  services.openssh.enable = mkDefault true;
  services.openssh.settings.X11Forwarding =
    mkDefault config.services.xserver.enable;
  services.openssh.startWhenNeeded = mkDefault true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  services.udev.packages = [ pkgs.qmk-udev-rules ];

  programs.bash.completion.enable = true;
  programs.bash.enableLsColors = true;
  programs.git.enable = mkDefault true;
  programs.git.package = mkDefault pkgs.gitFull;
  programs.gnupg.agent.enable = mkDefault true;
  programs.gnupg.agent.enableSSHSupport = mkDefault true;
  programs.tmux.enable = true;
  programs.usbtop.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableLsColors = true;
  programs.zsh.syntaxHighlighting.enable = true;

  environment.homeBinInPath = mkDefault true; # Add ~/bin to PATH
  environment.localBinInPath = mkDefault true; # Add ~/.local/bin to PATH
  environment.systemPackages = with pkgs; [
    cachix
    curl
    fd
    killall
    nixos-option
    ripgrep
    ssh-copy-id
    tree
    xdg-utils
    mupdf # Simple PDF/EPUB/etc viewer
    ntfs3g # NTFS filesystems (e.g. USB drives, etc)
  ] ++ optional systemdSupport sysz;

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
}
