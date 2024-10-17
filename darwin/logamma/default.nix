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
    ../modules/aerospace.nix
    ../modules/emacs-plus
    ../modules/karabiner-elements
    # 1password
    {
      homebrew.casks = [
        # "1password"
        "1password-cli"
      ];
    }
    # postgresql
    {
      environment.systemPackages = with pkgs; [
        postgresql
      ];
    }
    # clickhouse
    {
      environment.systemPackages = with pkgs; [
        clickhouse
        clickhouse-cli
      ];
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
  ];

  homebrew.brews = [
    "nss" # used by mkcert
    "terminal-notifier"
  ];

  homebrew.casks = [
    "obs"
    "tailscale"
  ];

  services.karabiner-elements.enable = false;

  home-manager.users.logan = {
    imports = [
      self.homeModules.common
      self.homeModules.nix-colors
      inputs.nixvim.homeManagerModules.nixvim
      ../../nix/home/dev
      ../../nix/home/dev/nodejs.nix
      ../../nix/home/pretty.nix
      ../../nix/home/kitty
      ../../nix/home/doom
      ../../nix/modules/programs/nixvim
      # aws
      {
        home.packages = with pkgs; [
          awscli2
        ];
        # TODO should we need to configure completion?
        programs.bash.initExtra = ''
          complete -C '${pkgs.awscli2}/bin/aws_completer' aws
        '';
        programs.zsh.initExtra = ''
          complete -C '${pkgs.awscli2}/bin/aws_completer' aws
        '';
      }
    ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
    };

    programs.kitty.enable = true;

    home.packages = with pkgs; [
      mkcert
      nodePackages.typescript-language-server
      nodejs
      pls
      yarn
    ];

    home.stateVersion = "22.11";
  };
}
