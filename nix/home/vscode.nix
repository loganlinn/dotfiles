{ pkgs, lib, ... }: {
  programs.vscode = {
    enable = lib.mkDefault true;
    package = lib.mkDefault pkgs.vscode; # TODO pkgs.vscodium

    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    mutableExtensionsDir = true;

    # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/editors/vscode/extensions
    extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
      bbenoist.nix
      betterthantomorrow.calva
      bungcip.better-toml
      # coolbear.systemd-unit-file
      # davidanson.vscode-markdownlint
      dracula-theme.theme-dracula
      eamodio.gitlens
      editorconfig.editorconfig
      golang.go
      github.github-vscode-theme
      # github.vscode-pull-request-github
      hashicorp.terraform
      kahole.magit
      kamadorueda.alejandra
      # mskelton.one-dark-theme
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.python
      ms-vscode-remote.remote-ssh
      redhat.java
      redhat.vscode-yaml
      # skellock.just
      # sumneko.lua
      timonwong.shellcheck
      vscodevim.vim
      # zhuangtongfa.material-theme # One Dark Pro
      zxh404.vscode-proto3
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

    userSettings = {
      # Appearance
      "editor.fontFamily" = "JetBrainsMono Nerd Font, JetBrains Mono";
      "editor.fontWeight" = "normal";
      # "editor.fontSize" = 13;
      "editor.highlightActiveIndentGuide" = true;
      # "editor.lineHeight" = 24;
      "editor.ligatures" = true;
      "editor.lineNumbers" = "relative";
      "editor.minimap.enabled" = false;
      "editor.renderControlCharacters" = true;
      "editor.rulers" = [ 99 ];
      "editor.zenMode.hideTabs" = true;
      "editor.zenMode.singleFile" = true;
      "terminal.integrated.tabs.location" = "left";
      "window.newWindowDimensions" = "inherit";
      "window.openFilesInNewWindow" = "default";
      "workbench.activityBar.visible" = true;
      "workbench.colorTheme" = "Nord";
      # "workbench.colorTheme" = "Dracula";
      # "workbench.colorTheme" = "GitHub Dark Dimmed";
      "workbench.sideBar.location" = "right";
      "workbench.startupEditor" = "newUntitledFile";

      # Behavior
      "editor.formatOnSaveMode" = "modifications";
      "editor.hover.delay" = 100;
      "editor.largeFileOptimizations" = true;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "explorer.incrementalNaming" = "smart";
      "workbench.editor.revealIfOpen" = true;

      # Privacy
      "Lua.telemetry.enable" = false;
      "aws.telemetry" = false;
      "go.survey.prompt" = false;
      "redhat.telemetry.enabled" = false;
      "telemetry.telemetryLevel" = "off";
      "typescript.surveys.enabled" = false;
      "workbench.enableExperiments" = false;

      "files.associations" = {
        "*.config" = "shellscript";
        "*.hcl" = "terraform";
        "*.variant" = "terraform";
      };
      "files.exclude" = { "**/node_modules" = true; };

      # "git.autofetch" = true;

      # eamodio.gitlens
      "gitlens.codeLens.enabled" = true;

      "typescript.updateImportsOnFileMove.enabled" = "always";

      # timonwong.shellcheck
      "shellcheck.ignorePatterns" = {
        "**/*.config" = true;
        "**/*.env" = true;
        "**/*.envrc" = true;
        "**/*.zlogin" = true;
        "**/*.zlogout" = true;
        "**/*.zprofile" = true;
        "**/*.zsh" = true;
        "**/*.zsh-theme" = true;
        "**/*.zshenv" = true;
        "**/*.zshrc" = true;
        "**/zlogin" = true;
        "**/zlogout" = true;
        "**/zprofile" = true;
        "**/zshenv" = true;
        "**/zshrc" = true;
      };
      "shellcheck.customArgs" = [ "-x" ];
      "shellcheck.useWorkspaceRootAsCwd" = true;

      # davidanson.vscode-markdownlint
      "markdownlint.ignore" = [ "MD033" ];

      "tms.autoRefresh" = false;

      # betterthantomorrow.calva
      "calva.paredit.defaultKeyMap" = "strict";
      "calva.prettyPrintingOptions" = {
        "enabled" = true;
        "width" = 120;
        "maxLength" = 50;
        "printEngine" = "pprint";
      };

      # vscodevim.vim
      "vim.easymotion" = true;
      # "vim.enableNeovim" = true;
      "vim.hlsearch" = true;
      "vim.incsearch" = true;
      "vim.smartRelativeLine" = true;
      "vim.useCtrlKeys" = true;
      "vim.useSystemClipboard" = true;
      "vim.normalModeKeyBindings" = [
        {
          "before" = [ "g" "h" ];
          "commands" = [ "cursorHome" ];
        }
        {
          "before" = [ "g" "j" ];
          "commands" = [ "cursorBottom" ];
        }
        {
          "before" = [ "g" "k" ];
          "commands" = [ "cursorTop" ];
        }
        {
          "before" = [ "g" "l" ];
          "commands" = [ "cursorEnd" ];
        }
      ];
      "vim.visualModeKeyBindings" = [
        {
          "before" = [ ">" ];
          "commands" = [ "editor.action.indentLines" ];
        }
        {
          "before" = [ "<" ];
          "commands" = [ "editor.action.outdentLines" ];
        }
      ];

      # ms-kubernetes-tools.vscode-kubernetes-tools
      "vs-kubernetes" = { "vs-kubernetes.crd-code-completion" = "disabled"; };

    };
    keybindings = [
      # https://github.com/kahole/edamagit/blob/916a4c808d213407233d68b2c814c82ca5dedb9d/README.md#vim-support-vscodevim
      {
        key = "g g";
        command = "cursorTop";
        when =
          "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
      }
      {
        key = "g r";
        command = "magit.refresh";
        when =
          "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
      }
      {
        key = "tab";
        command = "extension.vim_tab";
        when =
          "editorFocus && vim.active && !inDebugRepl && vim.mode != 'Insert' && editorLangId != 'magit'";
      }
      {
        key = "tab";
        command = "-extension.vim_tab";
        when =
          "editorFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'";
      }
      {
        key = "x";
        command = "magit.discard-at-point";
        when =
          "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
      }
      {
        key = "k";
        command = "-magit.discard-at-point";
      }
      {
        key = "-";
        command = "magit.reverse-at-point";
        when =
          "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
      }
      {
        key = "v";
        command = "-magit.reverse-at-point";
      }
      {
        key = "shift+-";
        command = "magit.reverting";
        when =
          "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
      }
      {
        key = "shift+v";
        command = "-magit.reverting";
      }
      {
        key = "shift+o";
        command = "magit.resetting";
        when =
          "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
      }
      {
        key = "shift+x";
        command = "-magit.resetting";
      }
      {
        key = "x";
        command = "-magit.reset-mixed";
      }
      {
        key = "ctrl+u x";
        command = "-magit.reset-hard";
      }
    ];
  };
}
