{pkgs, lib, ...}: {

  imports = [
    ./system.nix
    ./security.nix
    ./homebrew.nix
    ./skhd.nix
    ./yabai.nix
    ./tailscale.nix
  ];

  users.users.logan = {
    name = "logan";
    description = "Logan Linn";
    shell = pkgs.zsh;
    home = "/Users/logan";
  };

  environment = {
    darwinConfig = "$HOME/.dotfiles/nix/darwin/configuration.nix";

    systemPackages = with pkgs; [
      curl
      du-dust
      fd
      fzf
      htop
      lsd
      moreutils
      nixfmt
      ripgrep
      tree
      vim_configurable
      wget
    ];
    # profiles = [];
    # extraInit = "";
    # etc = {};
    variables = {
      # EDITOR = "vim";
      LANG = "en_US.UTF-8";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
  };

  programs.nix-index.enable = true;

  services.nix-daemon.enable = true;

  # services.cachix-agent = {
  #   enable = true;
  #   credentialsFile = "/etc/cachix-agent.token";
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
