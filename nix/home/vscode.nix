{ config, pkgs, lib, ... }:
{

  home.sessionVariables.VSCODE_TELEMETRY_DISABLED = "1";

  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/config/Code/User/settings.json";

  xdg.configFile."Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/config/Code/User/keybindings.json";

  xdg.configFile."Code/User/snippets".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.dotfiles/config/Code/User/snippets";

  programs.vscode = {
    # enableUpdateCheck = true;
    # enableExtensionUpdateCheck = true;
    # mutableExtensionsDir = true;

    # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/editors/vscode/extensions
    extensions = with pkgs.vscode-extensions; [
      # arcticicestudio.nord-visual-studio-code
      # bbenoist.nix
      # betterthantomorrow.calva
      # coolbear.systemd-unit-file
      # davidanson.vscode-markdownlint
      # dracula-theme.theme-dracula
      eamodio.gitlens
      editorconfig.editorconfig
      golang.go
      # github.copilot
      # github.codespaces
      github.github-vscode-theme
      github.vscode-pull-request-github
      # hashicorp.terraform
      # kahole.magit
      # kamadorueda.alejandra
      # mskelton.one-dark-theme
      # ms-kubernetes-tools.vscode-kubernetes-tools
      # ms-python.python
      # ms-vscode-remote.remote-ssh
      # redhat.java
      # redhat.vscode-yaml
      # skellock.just
      # sumneko.lua
      timonwong.shellcheck
      # vscodevim.vim
      # zhuangtongfa.material-theme # One Dark Pro
      # zxh404.vscode-proto3
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "isort";
        publisher = "ms-python";
        version = "2022.8.0";
        sha256 = "l7mXTKdAE56DdnSaY1cs7sajhG6Yzz0XlZLtHY2saB0=";
      }
      {
        name = "intellij-idea-keybindings";
        publisher = "k--kato";
        version = "1.5.5";
        # nix-prefetch-url https://vscodevim.gallery.vsassets.io/_apis/public/gallery/publisher/k--kato/extension/intellij-idea-keybindings/1.5.5/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage
        sha256 = "1l5fs47wnc0mfl95ibv823zlrzij99a7m5v7i2bgm5b7krwf9p4n";
      }
    ];
  };
}
