{ inputs, config, lib, pkgs, ... }:

with lib;

let
  systemdSupport = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.systemd;
in
{
  imports = [ ../../options.nix ];

  users.defaultUserShell = pkgs.zsh;
  users.users.${config.my.user.name} = {
    inherit (config.my.user) shell;
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
  services.openssh.settings.X11Forwarding =
    mkDefault config.services.xserver.enable;
  services.openssh.startWhenNeeded = mkDefault true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  programs.tmux.enable = true;

  programs.git.enable = mkDefault true;
  programs.git.package = mkDefault pkgs.gitFull;

  programs.bash.enableCompletion = true;
  programs.bash.enableLsColors = true;
  programs.gnupg.agent.enable = mkDefault true;
  programs.gnupg.agent.enableSSHSupport = mkDefault true;
  programs.usbtop.enable = true;
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableLsColors = true;
  programs.zsh.syntaxHighlighting.enable = true;

  programs.vim = {
    defaultEditor = true;
    package = pkgs.vim-full.customize {
      name = "vim";
      vimrcConfig.packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          editorconfig-vim
          fzf-vim
          vim-commentary
          vim-eunuch
          vim-fugitive
          vim-gitgutter
          vim-lastplace
          vim-nix
          vim-repeat
          vim-sensible
          vim-sleuth
          vim-surround
          vim-unimpaired
        ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        let mapleader = "\<Space>"

        " system clip
        set clipboard=unnamed

        " yank to system clipboard without motion
        nnoremap <Leader>y "+y

        " yank line to system clipboard
        nnoremap <Leader>yl "+yy

        " yank file to system clipboard
        nnoremap <Leader>yf gg"+yG

        " paste from system clipboard
        nnoremap <Leader>p "+p
      '';
    };
  };

  environment.homeBinInPath = mkDefault true; # Add ~/bin to PATH
  environment.localBinInPath = mkDefault true; # Add ~/.local/bin to PATH
  environment.systemPackages = with pkgs; [
    curl
    fd
    killall
    nixos-option
    qmk-udev-rules
    ripgrep
    ssh-copy-id
    tree
    xdg-utils
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
