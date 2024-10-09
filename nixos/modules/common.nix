{
  self,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  systemdSupported = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.systemd;
  audioEnabled = config.hardware.pulseaudio.enable || config.services.pipewire.enable;
  graphicsEnabled = config.services.xserver.enable || config.services.displayManager.enable;
in
{
  imports = [
    ../../options.nix
    ./security
  ];

  config = {
    networking.networkmanager.enable = mkDefault true;
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;

    users.users.${config.my.user.name} = {
      shell = config.my.user.shell;
      home = mkDefault "/home/${config.my.user.name}";
      isNormalUser = true;
      createHome = mkDefault true;
      extraGroups =
        [ "wheel" ]
        ++ optional graphicsEnabled "video"
        ++ optional audioEnabled "audio"
        ++ optional config.networking.networkmanager.enable "networkmanager"
        ++ optional config.programs._1password-gui.enable "onepassword"
        ++ optional config.programs._1password.enable "op"
        ++ optional config.programs.corectrl.enable "corectrl"
        ++ optional config.virtualisation.docker.enable "docker"
        ++ optional config.virtualisation.podman.enable "podman"
        ++ optional config.virtualisation.libvirtd.enable "libvirtd"
        ++ optional config.services.davfs2.enable "${config.services.davfs2.davGroup}";
      openssh.authorizedKeys.keys = config.my.authorizedKeys;
      packages = with pkgs; [
          cachix
          gh
          ssh-copy-id
        ];
    };

    services.openssh.enable = mkDefault true;
    services.openssh.startWhenNeeded = mkDefault true;
    services.openssh.settings.X11Forwarding = mkDefault config.services.xserver.enable;
    services.openssh.settings.PrintMotd = mkDefault true;
    services.openssh.settings.PermitRootLogin = mkDefault "no";
    services.openssh.settings.PasswordAuthentication = mkDefault false;
    services.openssh.settings.KbdInteractiveAuthentication = mkDefault false;

    services.udev.packages = [ pkgs.qmk-udev-rules ];

    programs.bash.completion.enable = mkDefault true;
    programs.bash.enableLsColors = mkDefault true;

    programs.git.enable = true;
    programs.git.package = mkDefault pkgs.gitFull;

    programs.gnupg.agent.enable = mkDefault true;
    programs.gnupg.agent.enableSSHSupport = mkDefault true;

    programs.less.enable = mkDefault true;

    programs.tmux.enable = mkDefault true;

    programs.usbtop.enable = mkDefault true;
    programs.htop.enable = mkDefault true;

    programs.fzf.fuzzyCompletion = mkDefault true;
    programs.fzf.keybindings = mkDefault true;

    programs.zsh.enable = true;
    programs.zsh.autosuggestions.enable = mkDefault true;
    programs.zsh.enableCompletion = mkDefault true;
    programs.zsh.enableLsColors = mkDefault true;
    programs.zsh.syntaxHighlighting.enable = mkDefault true;
    programs.zsh.histSize = mkDefault 10000;

    environment.homeBinInPath = mkDefault true; # Add ~/bin to PATH
    environment.localBinInPath = mkDefault true; # Add ~/.local/bin to PATH
    environment.systemPackages =
      with pkgs;
      [
        bat
        curl
        dogdns
        fd
        killall
        nixos-option
        ntfs3g # NTFS filesystems (e.g. USB drives, etc)
        ripgrep
        tree
        vim
        wget
        xdg-utils
      ]
      ++ optionals graphicsEnabled [
        mupdf # Simple PDF/EPUB/etc viewer
      ]
      ++ optionals audioEnabled [ ]
      ++ optionals systemdSupported [ sysz ];

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
    nix.settings = config.my.nix.settings;
    nix.gc.automatic = mkDefault true;
    nix.nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
    nix.sshServe.keys = config.my.authorizedKeys;

    nixpkgs.config.allowUnfree = true;
  };
}
