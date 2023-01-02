{pkgs, ...}: {
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
      # betterthantomorrow.joyride
      bungcip.better-toml
      coolbear.systemd-unit-file
      editorconfig.editorconfig
      golang.go
      hashicorp.terraform
      kamadorueda.alejandra
      ms-vscode.cpptools
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-pyright.pyright
      ms-python.python
      ms-vscode-remote.remote-ssh
      redhat.java
      redhat.vscode-yaml
      skellock.just
      sumneko.lua
      timonwong.shellcheck
      vscodevim.vim
      zxh404.vscode-proto3
    ];

    userSettings = {
      "workbench.colorTheme" = "Nord";
      "aws.telemetry" = false;
      "redhat.telemetry.enabled" = false;
      "editor.formatOnSaveMode" = "modifications";
      "editor.lineNumbers" = "relative";
      "editor.minimap.enabled" = false;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "files.associations" = {
        "*.config" = "shellscript";
        "*.hcl" = "terraform";
        "*.variant" = "terraform";
      };
      "git.autofetch" = true;
      "markdownlint.ignore" = [
        "MD033"
      ];
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
      "telemetry.enableCrashReporter" = false;
      "telemetry.enableTelemetry" = false;
      "tms.autoRefresh" = false;
      "typescript.updateImportsOnFileMove.enabled" = "always";
      "workbench.activityBar.visible" = true;
      "workbench.editor.revealIfOpen" = true;
      "workbench.enableExperiments" = false;
      "workbench.sideBar.location" = "right";
      "workbench.preferredDarkColorTheme" = "Nord";
      "shellcheck.customArgs" = [
        "-x"
      ];
      "window.openFilesInNewWindow" = "default";
      "explorer.incrementalNaming" = "smart";
      "shellcheck.useWorkspaceRootAsCwd" = true;
      "files.exclude" = {
        "**/node_modules" = true;
      };
      "workbench.startupEditor" = "newUntitledFile";
      "window.newWindowDimensions" = "inherit";
      "terminal.integrated.tabs.location" = "left";
      "telemetry.telemetryLevel" = "off";
      "calva.paredit.defaultKeyMap" = "strict";
      "calva.prettyPrintingOptions" = {
        "enabled" = true;
        "width" = 120;
        "maxLength" = 50;
        "printEngine" = "pprint";
      };
      "editor.fontFamily" = "'FiraCode Nerd Font', 'UbuntuMono Nerd Font', 'Ubuntu Mono', 'monospace', monospace, 'Droid Sans Fallback'";
      "editor.rulers" = [99];
      "vim.easymotion" = true;
      "vim.enableNeovim" = true;
      "vim.hlsearch" = true;
      "vim.incsearch" = true;
      "vim.smartRelativeLine" = true;
      "vim.useCtrlKeys" = true;
      "vim.useSystemClipboard" = true;
      "vim.normalModeKeyBindings" = [
        {
          "before" = ["g" "h"];
          "commands" = ["cursorHome"];
        }
        {
          "before" = ["g" "j"];
          "commands" = ["cursorBottom"];
        }
        {
          "before" = ["g" "k"];
          "commands" = ["cursorTop"];
        }
        {
          "before" = ["g" "l"];
          "commands" = ["cursorEnd"];
        }
      ];
      "vim.visualModeKeyBindings" = [
        {
          "before" = [">"];
          "commands" = ["editor.action.indentLines"];
        }
        {
          "before" = ["<"];
          "commands" = ["editor.action.outdentLines"];
        }
      ];
      "vs-kubernetes" = {
        "vs-kubernetes.crd-code-completion" = "disabled";
      };
    };
  };
}
