{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  programs.zsh = {
    antidote = {
      enable = true;
      plugins = [
        "aloxaf/fzf-tab"
        "mattmc3/zfunctions" # $ZDOTDIR/functions (see below)
        "mattmc3/zman"
        "mattmc3/zsh-safe-rm"
        "mehalter/zsh-nvim-appname" # nvapp
        "romkatv/zsh-bench kind:path"
        "wfxr/forgit"
        "zdharma-continuum/fast-syntax-highlighting kind:defer"
        "zsh-users/zsh-history-substring-search"
        "marlonrichert/zsh-edit"
        "marlonrichert/zcolors"

        "getantidote/use-omz" # handle OMZ dependencies
        "ohmyzsh/ohmyzsh path:lib" # load OMZ's library
        "ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
        "ohmyzsh/ohmyzsh path:plugins/copybuffer" # ctrl-o
        "ohmyzsh/ohmyzsh path:plugins/copyfile"
        "ohmyzsh/ohmyzsh path:plugins/copypath"
        "ohmyzsh/ohmyzsh path:plugins/extract"

        # "olets/zsh-abbr kind:defer"
        # "belak/zsh-utils path:completion/functions kind:autoload post:compstyle_zshzoo_setup"
        # "belak/zsh-utils path:editor"
        # "belak/zsh-utils path:history"
        # "belak/zsh-utils path:prompt"
        # "belak/zsh-utils path:utility"
        # "zsh-users/zsh-completions kind:fpath path:src"
      ];
    };

    localVariables = {
      # ABBR_AUTOLOAD = null;
      # ABBR_DEBUG = null;
      # ABBR_DEFAULT_BINDINGS = 0;
      # ABBR_DRY_RUN = null;
      # ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY = null;
      # ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY = null;
      # ABBR_EXPANSION_CURSOR_MARKER = null;
      # ABBR_FORCE = null;
      # ABBR_GET_AVAILABLE_ABBREVIATION = null;
      # ABBR_LINE_CURSOR_MARKER = null;
      # ABBR_LOG_AVAILABLE_ABBREVIATION = null;
      # ABBR_LOG_AVAILABLE_ABBREVIATION_AFTER = null;
      # ABBR_QUIET = null;
      # ABBR_QUIETER = null;
      # ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES = null;
      # ABBR_REGULAR_ABBREVIATION_SCALAR_PREFIXES = null;
      # ABBR_SET_EXPANSION_CURSOR = null;
      # ABBR_SET_LINE_CURSOR = null;
      # ABBR_TMPDIR = null;
      # ABBR_USER_ABBREVIATIONS_FILE = null;
    };

    initContent = mkBefore ''
      export FORGIT_NO_ALIASES=1
      export FORGIT_CHECKOUT_BRANCH_BRANCH_GIT_OPTS="--sort=-committerdate"
      export ANTIDOTE_HOME=${config.xdg.cacheHome}/antidote
      export ZFUNCDIR=${config.xdg.configHome}/zsh/functions
    '';
  };

  # home.file = {
  # };
  # xdg.configFile =
  #   let
  #     funcDir = ../../../config/zsh/functions;
  #     funcNames = attrNames (filterAttrs (name: type: type == "regular") (builtins.readDir funcDir));
  #   in
  #   listToAttrs (
  #     map (
  #       name:
  #       nameValuePair "zsh/functions/${name}" {
  #         source = config.lib.file.mkOutOfStoreSymlink "${funcDir}/${name}";
  #       }
  #     ) funcNames
  #   );
}
