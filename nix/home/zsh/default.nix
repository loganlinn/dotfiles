{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
with lib; {
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
      (mapAttrs (_: input: "${input}") inputs) # ~nixpkgs, ~home-manager, etc
      (filterAttrs (_: value: value != null) config.my.userDirs)
      rec {
        cfg = ''''${XDG_CONFIG_HOME:-$HOME/.config}'';
        cache = ''''${XDG_CACHE_HOME:-$HOME/.cache}'';
        data = ''''${XDG_DATA_HOME:-$HOME/.local/share}'';
        state = ''''${XDG_DATA_HOME:-$HOME/.local/state}'';

        dot = ''''${DOTFILES_DIR:-$HOME/.dotfiles}'';
        src = ''''${SRC_HOME:-$HOME/src}'';
        gh = ''${src}/github.com'';
        nvim = ''${cfg}/nvim''${NVIM_APPNAME:+"_$NVIM_APPNAME"}'';
        emacs = ''''${EMACSDIR:-${cfg}/emacs}'';
        doom = ''''${DOOMDIR:-${cfg}/doom}'';
        wez = ''''${WEZTERM_CONFIG_DIR:-${cfg}/wezterm}'';
      }
      (optionalAttrs pkgs.stdenv.targetPlatform.isDarwin rec {
        apps = ''$HOME/Applications'';
        appdata = ''$HOME/Library/Application Support'';
        chromedata = ''${appdata}/Google/Chrome'';
        firefoxdata = ''${appdata}/Firefox'';
      })
    ];

    plugins = [
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

    initExtraFirst = ''
      ${readFile ./initExtraFirst.zsh}
    '';

    initExtraBeforeCompInit = ''
      ${readFile ./line-editor.zsh}
      ${readFile ./initExtraBeforeCompInit.zsh}
    '';

    initExtra = let
      functionsDir = toString ./functions;
      functionNames = attrNames (builtins.readDir functionsDir);
    in ''
      if [[ -r ~/.znap/znap.zsh ]] || git clone --quiet --depth 1 --no-tags --filter=blob:none --revision=909e3842dc301ad3588cdb505f8ed9003a34d2bb https://github.com/marlonrichert/zsh-snap.git ~/.znap >/dev/null; then
       source ~/.znap/znap.zsh
      fi
      # znap function _hist hist "znap source marlonrichert/zsh-hist"
      # compctl -K    _hist hist

      : "''${DOTFILES_DIR:=$HOME/.dotfiles}"

      fpath+=(
        "$DOTFILES_DIR/nix/home/zsh/functions"
        "''${XDG_DATA_HOME:-$HOME/.local/share}/zsh/functions"
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
