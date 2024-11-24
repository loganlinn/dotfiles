{
  self,
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    self.darwinModules.common
    self.darwinModules.home-manager
    ../modules/aerospace
    ../modules/aws.nix
    ../modules/emacs-plus
    ../modules/karabiner-elements
    ../modules/sunbeam
    ../modules/xcode.nix
    {
      homebrew.taps = [ "TylerBrock/saw" ];
      homebrew.brews = [ "TylerBrock/saw/saw" ];
    }
    # dbeaver
    {
      homebrew.casks = [ "dbeaver-community" ];
    }
    # atlas
    {
      homebrew.taps = [ "ariga/tap" ];
      homebrew.brews = [ "ariga/tap/atlas" ];
      environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "atlas-shell-completion";
          version = "0.0.1";
          dontUnpack = true; # no src
          nativeBuildInputs = [ pkgs.installShellFiles ];
          postInstall = ''
            installShellCompletion --cmd atlas \
            --bash <(${config.homebrew.brewPrefix}/atlas completion bash) \
            --fish <(${config.homebrew.brewPrefix}/atlas completion fish) \
            --zsh <(${config.homebrew.brewPrefix}/atlas completion zsh)
          '';
        })
      ];
    }
    # terraform 
    {
      homebrew.taps = [ "hashicorp/tap" ];
      homebrew.brews = [
        # "tfenv"
        "hashicorp/tap/terraform-ls"
      ];
      home-manager.users.logan = {
        home.packages = with pkgs; [
          tenv
          # terraform-ls
          tflint
          terraformer
          terraform-docs
          terraform-local
          tfsec
          tf-summarize
          iam-policy-json-to-terraform
        ];
        programs.zsh.plugins = [
          # ~/.zsh/plugins/tenv/tenv.plugin.zsh:14: no such file or directory: /completions/_tenv
          # {
          #   name = "tenv";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "tofuutils";
          #     repo = "zsh-tenv";
          #     rev = "2357d868d1e14917a18dfd51bf61ac739d856279";
          #     hash = "sha256-sQNxoffHXTketr4PdTeVFMhJl239Wa7UoVcCR7wB2kw=";
          #   };
          # }
        ];
      };
    }
  ];

  environment.systemPackages = with pkgs; [
    postgresql
    devenv
    plistwatch
    libplist
  ];

  homebrew.brews = [
    "grafana"
    "nss" # used by mkcert
    # "terminal-notifier" # like notify-send
  ];

  homebrew.casks = [
    # "1password" # currently installed manually
    "1password-cli"
    "clickhouse" # newer version than from nixpkgs
    "discord"
    "obs"
    "tailscale"
  ];

  programs.aerospace = {
    enable = true;
    terminal.id = "com.github.wez.wezterm";
    editor.id = "org.gnu.Emacs";
  };

  programs.xcode.enable = true;

  programs.sunbeam.enable = true;

  programs.emacs-plus.enable = true;

  services.karabiner-elements.enable = false;

  home-manager.users.logan = {
    imports = [
      self.homeModules.common
      self.homeModules.nix-colors
      inputs.nixvim.homeManagerModules.nixvim
      ../../nix/home/dev
      ../../nix/home/dev/lua.nix
      ../../nix/home/dev/nodejs.nix
      ../../nix/home/doom
      ../../nix/home/just
      ../../nix/home/kitty
      ../../nix/home/pretty.nix
      ../../nix/home/tmux.nix
      ../../nix/home/wezterm
      ../../nix/home/yazi
      ../../nix/home/yt-dlp.nix
      ../../nix/modules/programs/nixvim
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
    };

    programs.kitty.enable = true;

    programs.wezterm.enable = true;

    home.packages = with pkgs; [
      flyctl
      google-cloud-sdk
      goose
      kcat
      mkcert
      nodejs
      pls
      process-compose
    ];

    home.stateVersion = "22.11";

    xdg.enable = true;

    manual.html.enable = true;
    manual.json.enable = true;
  };

  system.stateVersion = 4;
}
