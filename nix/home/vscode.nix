{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    mutableExtensionsDir = true;

    # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/editors/vscode/extensions
    extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
      bbenoist.nix
      betterthantomorrow.calva
      bungcip.better-toml
      coolbear.systemd-unit-file
      # davidanson.vscode-markdownlint
      editorconfig.editorconfig
      golang.go
      hashicorp.terraform
      kahole.magit
      kamadorueda.alejandra
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.python
      ms-vscode-remote.remote-ssh
      redhat.java
      redhat.vscode-yaml
      skellock.just
      # sumneko.lua
      timonwong.shellcheck
      vscodevim.vim
      zhuangtongfa.material-theme # One Dark Pro
      zxh404.vscode-proto3
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "isort";
        publisher = "ms-python";
        version = "2022.8.0";
        sha256 = "l7mXTKdAE56DdnSaY1cs7sajhG6Yzz0XlZLtHY2saB0=";
      }
    ];

    userSettings = {
      # Appearance
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Victor Mono', Hack, 'Ubuntu Mono', monospace";
      "editor.ligatures" = true;
      "editor.lineNumbers" = "relative";
      "editor.minimap.enabled" = false;
      "editor.rulers" = [ 99 ];
      "terminal.integrated.tabs.location" = "left";
      "window.newWindowDimensions" = "inherit";
      "window.openFilesInNewWindow" = "default";
      "workbench.activityBar.visible" = true;
      "workbench.colorTheme" = "One Dark Pro";
      "workbench.preferredDarkColorTheme" = "One Dark Pro";
      "workbench.sideBar.location" = "right";
      "workbench.startupEditor" = "newUntitledFile";

      # Behavior
      "editor.formatOnSaveMode" = "modifications";
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "workbench.editor.revealIfOpen" = true;
      "explorer.incrementalNaming" = "smart";

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

      # "git.autofetch" = true;


      "files.exclude" = { "**/node_modules" = true; };

      # markdown
      "markdownlint.ignore" = [ "MD033" ];

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

      "tms.autoRefresh" = false;

      "typescript.updateImportsOnFileMove.enabled" = "always";

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
      "vim.enableNeovim" = true;
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
