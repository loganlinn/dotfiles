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
      "--help" = ''--help 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain --paging=never'';
      "-h" = ''-h 2>&1 | ${pkgs.bat}/bin/bat --language=help --style=plain --paging=never'';
    };

    sessionVariables = mkOptionDefault config.home.sessionVariables;

    dirHashes = mergeAttrsList [
      (mapAttrs (name: input: "${input}") inputs) # ~nixpkgs, ~home-manager, etckj:W
      ({
        cfg = ''''${XDG_CONFIG_HOME:-$HOME/.config}'';
        cache = ''''${XDG_CACHE_HOME:-$HOME/.cache}'';
        data = ''''${XDG_DATA_HOME:-$HOME/.local/share}'';
        state = ''''${XDG_DATA_HOME:-$HOME/.local/state}'';
        bin = ''$HOME/.local/bin'';

        dot = ''''${DOTFILES_DIR:-$HOME/.dotfiles}'';
        src = ''''${SRC_HOME:-$HOME/src}'';
        gh = ''~src/github.com'';
        nvim = ''''${XDG_CONFIG_HOME:-$HOME/.config}/nvim''${NVIM_APPNAME:+"_$NVIM_APPNAME"}'';
        emacs = ''''${EMACSDIR:-~cfg/emacs}'';
        doom = ''''${DOOMDIR:-~cfg/doom}'';
        wez = ''''${WEZTERM_CONFIG_DIR:-~cfg/wezterm}'';
        kitty = ''~cfg/kitty'';
      })
      (optionalAttrs config.xdg.enable {
        dl = config.xdg.userDirs.download;
        docs = config.xdg.userDirs.documents;
        pics = config.xdg.userDirs.pictures;
        vids = config.xdg.userDirs.videos;
      })
      (optionalAttrs pkgs.stdenv.targetPlatform.isDarwin {
        apps = ''$HOME/Applications'';
        appdata = ''$HOME/Library/Application Support'';
        chromedata = ''~appdata/Google/Chrome'';
        ffdata = ''~appdata/Firefox'';
      })
    ];

    plugins = [
      {
        name = "forgit";
        src = inputs.forgit;
      }
      {
        name = "fzf-tab";
        src = inputs.fzf-tab;
      }
      {
        name = "colored-man-pages";
        src = ./plugins/colored-man-pages;
      }
      {
        name = "nvim-appname";
        src = ./plugins/nvim-appname;
      }
    ];
    envExtra = ''
      [[ ! -f ~/.zshenv.local ]] || source ~/.zshenv.local
    '';

    profileExtra = ''
      [[ ! -f ~/.zprofile.local ]] || source ~/.zprofile.local
    '';

    initExtraFirst = readFile ./initExtraFirst.zsh;

    initExtraBeforeCompInit = ''
      ${readFile ./line-editor.zsh}
      ${readFile ./initExtraBeforeCompInit.zsh}
    '';

    initExtra =
      let
        functionsDir = toString ./functions;
        functionNames = attrNames (builtins.readDir functionsDir);
      in
      ''
        : "''${DOTFILES_DIR:=$HOME/.dotfiles}"

        fpath+=(
          "$DOTFILES_DIR/nix/home/zsh/functions"
          "$XDG_DATA_HOME/zsh/functions"
        )

        autoload -Uz ${concatStringsSep " " functionNames}

        bindkey -s '^G^G' ' git status^M' # ctrl-space (^M is accept line)
        bindkey -s '^G^S' ' git snapshot^M'
        bindkey -s '^G^_' ' "$(git rev-parse --show-toplevel)"\t' # i.e. C-g C-/
        bindkey -s '^G.' ' "$(git rev-parse --show-prefix)"\t'
        bindkey -s '^G,' ' $(git rev-parse --show-cdup)\t'

        ${readFile ./nixpkgs.zsh}

        ${readFile ./initExtra.zsh}

        ${readFile ./wezterm.zsh}

        wezterm::init

        [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
      '';

    loginExtra = ''
      [[ ! -f ~/.zlogin.local ]] || source ~/.zlogin.local
    '';

    logoutExtra = ''
      [[ ! -f ~/.zlogout.local ]] || source ~/.zlogout.local
    '';

  };
}
