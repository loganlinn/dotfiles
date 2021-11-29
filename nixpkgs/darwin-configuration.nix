{ pkgs,  ... }: {

  # imports = [ ~/.config/nixpkgs/darwin/local-configuration.nix ];

  # system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  # system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
    system.defaults.NSGlobalDomain.InitialKeyRepeat = 28;
    system.defaults.NSGlobalDomain.KeyRepeat = 7;
  # system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  # system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  # system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  # system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  # system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  # system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  # system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
  # system.defaults.NSGlobalDomain._HIHideMenuBar = false;

  system.defaults.dock.autohide = false;
  system.defaults.dock.mru-spaces = false;
  # system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;
  # system.defaults.dock.tilesize = 48;
  system.defaults.dock.tilesize = 64;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  # system.keyboard.enableKeyMapping = true;
  # system.keyboard.remapCapsLockToControl = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  environment.systemPackages = with pkgs; [
    bat
    cmake
    coreutils
    ctags
    curl
    entr
    fd
    fzf
    gettext
    git
    glow
    gnupg
    gnuplot
    gnused
    grpcurl
    htop
    jq
    kitty
    lsd
    mosh
    pinentry_mac
    rcm
    rlwrap
    shellcheck
    shellharden
    shfmt
    silver-searcher
    stow
    tmux
    tree
    wget

    darwin-zsh-completions
  ];

  # services.yabai.enable = true;
  # services.yabai.package = pkgs.yabai;
  # services.skhd.enable = true;

  nix.extraOptions = ''
    gc-keep-derivations = true
    gc-keep-outputs = true
    min-free = 17179870000
    max-free = 17179870000
    log-lines = 128
  '';

  programs.nix-index.enable = true;
  
  # programs.vim.defaultEditor = true;

  programs.zsh.enable = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableSyntaxHighlighting = true;

  # programs.gnupg.agent.enable = true;
  # programs.gnupg.agent.enableSSHSupport = true;
  
  # programs.tmux.enable = true;
  # programs.tmux.enableSensible = true;
  # programs.tmux.enableMouse = true;
  # programs.tmux.enableFzf = true;
  # programs.tmux.enableVim = true;

  programs.zsh.interactiveShellInit = ''
    setopt AUTOCD AUTOPUSHD
    autoload -U down-line-or-beginning-search
    autoload -U up-line-or-beginning-search
    bindkey '^[[A' down-line-or-beginning-search
    bindkey '^[[A' up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    zle -N up-line-or-beginning-search
  '';

  programs.zsh.loginShellInit = ''
    reexec() {
        unset __NIX_DARWIN_SET_ENVIRONMENT_DONE
        unset __ETC_ZPROFILE_SOURCED __ETC_ZSHENV_SOURCED __ETC_ZSHRC_SOURCED
        exec $SHELL -c 'echo >&2 "reexecuting shell: $SHELL" && exec $SHELL -l'
    }
    reexec-tmux() {
        unset __NIX_DARWIN_SET_ENVIRONMENT_DONE
        unset __ETC_ZPROFILE_SOURCED __ETC_ZSHENV_SOURCED __ETC_ZSHRC_SOURCED
        exec tmux new-session -A -s _ "$@"
    }
    reexec-sandbox() {
        unset __NIX_DARWIN_SET_ENVIRONMENT_DONE
        unset __ETC_ZPROFILE_SOURCED __ETC_ZSHENV_SOURCED __ETC_ZSHRC_SOURCED
        export IN_NIX_SANDBOX=1
        exec /usr/bin/sandbox-exec -f /etc/nix/user-sandbox.sb $SHELL -l
    }
    ls() {
        ${pkgs.coreutils}/bin/ls --color=auto "$@"
    }
    install_name_tool() {
        ${pkgs.darwin.cctools}/bin/install_name_tool "$@"
    }
    nm() {
        ${pkgs.darwin.cctools}/bin/nm "$@"
    }
    otool() {
        ${pkgs.darwin.cctools}/bin/otool "$@"
    }
  '';

  environment.loginShell = "${pkgs.zsh}/bin/zsh -l";

  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
  environment.variables.LANG = "en_US.UTF-8";

  environment.shellAliases.g = "git log --pretty=color -32";
  environment.shellAliases.gb = "git branch";
  environment.shellAliases.gc = "git checkout";
  environment.shellAliases.gcb = "git checkout -B";
  environment.shellAliases.gd = "git diff --minimal --patch";
  environment.shellAliases.gf = "git fetch";
  environment.shellAliases.ga = "git log --pretty=color --all";
  environment.shellAliases.gg = "git log --pretty=color --graph";
  environment.shellAliases.gl = "git log --pretty=nocolor";
  environment.shellAliases.grh = "git reset --hard";
  environment.shellAliases.l = "ls -lh";

  environment.extraInit = ''
    # Load and export variables from environment.d.
    if [ -d /etc/environment.d ]; then
        set -a
        . /etc/environment.d/*
        set +a
    fi
  '';

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      bashInteractive = super.bashInteractive_5;

      darwin-zsh-completions = super.runCommandNoCC "darwin-zsh-completions-0.0.0"
        { preferLocalBuild = true; }
        ''
          mkdir -p $out/share/zsh/site-functions
          cat <<-'EOF' > $out/share/zsh/site-functions/_darwin-rebuild
          #compdef darwin-rebuild
          #autoload
          _nix-common-options
          local -a _1st_arguments
          _1st_arguments=(
            'switch:Build, activate, and update the current generation'\
            'build:Build without activating or updating the current generation'\
            'check:Build and run the activation sanity checks'\
            'changelog:Show most recent entries in the changelog'\
          )
          _arguments \
            '--list-generations[Print a list of all generations in the active profile]'\
            '--rollback[Roll back to the previous configuration]'\
            {--switch-generation,-G}'[Activate specified generation]'\
            '(--profile-name -p)'{--profile-name,-p}'[Profile to use to track current and previous system configurations]:Profile:_nix_profiles'\
            '1:: :->subcmds' && return 0
          case $state in
            subcmds)
              _describe -t commands 'darwin-rebuild subcommands' _1st_arguments
            ;;
          esac
          EOF
        '';

      vim_configurable = super.vim_configurable.override {
        guiSupport = "no";
      };
    })
  ];
}
