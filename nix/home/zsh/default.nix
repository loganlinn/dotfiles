{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
with lib;
{
  imports = [
    ./options.nix
  ];

  home.packages = [
    (pkgs.writeScriptBin "zshi" (builtins.readFile ./bin/zshi))
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      size = 100000;
      save = 100000;
    };

    shellAliases = {
      sudo = "sudo ";
      commands = ''${pkgs.coreutils}/bin/basename -a "''${commands[@]}" | sort | uniq'';
      commandz = ''commands | fzf'';
      aliasez = ''alias | fzf'';
    };

    shellGlobalAliases = {
      "..." = "../..";
      "...." = "../../..";
      "....." = "../../../..";
      "......" = "../../../../..";
      # https://github.com/sharkdp/bat/blob/master/README.md#highlighting---help-messages
      "-?" = ''--help 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain'';
      "-h" = ''-h 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain --paging=never'';
    };

    dirHashes = mergeAttrsList [
      (mapAttrs (_: input: "${input}") inputs) # ~nixpkgs, ~home-manager, etc
      (filterAttrs (_: value: value != null) config.my.userDirs)
      rec {
        doom = ''''${DOOMDIR:-${cfg}/doom}'';
        dot = ''''${DOTFILES_DIR:-$HOME/.dotfiles}'';
        emacs = ''''${EMACSDIR:-${cfg}/emacs}'';
        gh = ''${src}/github.com'';
        nvim = ''${cfg}/nvim''${NVIM_APPNAME:+"_$NVIM_APPNAME"}'';
        src = ''''${SRC_HOME:-$HOME/src}'';
        wez = ''''${WEZTERM_CONFIG_DIR:-${cfg}/wezterm}'';
        # xdg
        cfg = ''''${XDG_CONFIG_HOME:-$HOME/.config}'';
        cache = ''''${XDG_CACHE_HOME:-$HOME/.cache}'';
        data = ''''${XDG_DATA_HOME:-$HOME/.local/share}'';
        dl = ''''${XDG_DOWNLOADS_DIR:-$HOME/Downloads}'';
        state = ''''${XDG_DATA_HOME:-$HOME/.local/state}'';
      }
      (optionalAttrs pkgs.stdenv.targetPlatform.isDarwin rec {
        apps = ''$HOME/Applications'';
        appdata = ''$HOME/Library/Application Support'';
        chromedata = ''${appdata}/Google/Chrome'';
        firefoxdata = ''${appdata}/Firefox'';
      })
    ];

    ## Replaced by antidote
    # plugins = [
    #   { name = "fzf-tab"; src = inputs.fzf-tab; }
    #   { name = "colored-man-pages"; src = ./plugins/colored-man-pages; }
    #   { name = "nvim-appname"; src = ./plugins/nvim-appname; }
    # ];

    antidote = {
      enable = true;
      plugins = [
        "aloxaf/fzf-tab"
        "mehalter/zsh-nvim-appname" # nvapp
        "wfxr/forgit"

        ## Things to look into from https://github.com/getantidote/zdotdir/blob/main/.zsh_plugins.txt
        # "belak/zsh-utils path:completion/functions kind:autoload post:compstyle_zshzoo_setup"
        # "belak/zsh-utils path:editor"
        # "belak/zsh-utils path:history"
        # "belak/zsh-utils path:utility"
        # "mattmc3/ez-compinit"
        # "ohmyzsh/ohmyzsh path:plugins/extract"
        # "romkatv/zsh-bench kind:path"
        # "zsh-users/zsh-completions kind:fpath path:src"
        # zdharma-continuum/fast-syntax-highlighting
        # zsh-users/zsh-history-substring-search
      ];
    };

    envExtra = ''
      # Ensure path arrays do not contain duplicates.
      typeset -gU path fpath

      [[ ! -f ~/.zshenv.local ]] || source ~/.zshenv.local
    '';

    profileExtra = ''
      [[ ! -f ~/.zprofile.local ]] || source ~/.zprofile.local
    '';

    initContent = mkMerge [
      (mkBefore ''
        ${readFile ./line-editor.zsh}
        ${readFile ./initExtraBeforeCompInit.zsh}
      '')
      (mkAfter ''
        autoload -Uz ${concatStringsSep " " (attrNames (readDir (toString ./functions)))}

        ## nixpkgs.zsh
        ${readFile ./nixpkgs.zsh}

        ## wezterm.zsh
        ${readFile ./wezterm.zsh}

        ## initExtra.zsh
        ${readFile ./initExtra.zsh}
      '')
    ];

    loginExtra = ''
      [[ ! -f ~/.zlogin.local ]] || source ~/.zlogin.local
    '';

    logoutExtra = ''
      [[ ! -f ~/.zlogout.local ]] || source ~/.zlogout.local
    '';

    sessionVariables = mkOptionDefault config.home.sessionVariables;
  };
}
