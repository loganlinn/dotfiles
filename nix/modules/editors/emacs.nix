{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.editors.emacs; in
{
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    doom = rec {
      enable = mkBoolOpt false;
      forgeUrl = mkOpt types.str "https://github.com";
      repoUrl = mkOpt types.str "${forgeUrl}/doomemacs/doomemacs";
      configRepoUrl = mkOpt types.str "${forgeUrl}/loganlinn/.doom.d";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.emacs.overlay ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacsNativeComp;
      extraPackages = epkgs:
        with epkgs; [
          vterm
        ];
    };

    services.emacs = {
      enable = true;
    };

    user.packages = with pkgs; [
      ## Emacs itself
      binutils       # native-comp needs 'as', provided by this
      # 28.2 + native-comp
      # ((emacsPackagesFor emacsNativeComp).emacsWithPackages
      #   (epkgs: [ epkgs.vterm ]))

      ## Doom dependencies
      git
      (ripgrep.override {withPCRE2 = true;})
      gnutls              # for TLS connectivity

      ## Optional dependencies
      fd                  # faster projectile indexing
      imagemagick         # for image-dired

      (mkIf (config.programs.gnupg.agent.enable)
        pinentry_emacs)   # in-emacs gnupg prompts

      zstd                # for undo-fu-session/undo-tree compression

      ## Module dependencies
      # :checkers spell
      (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
      # :tools editorconfig
      editorconfig-core-c # per-project style config
      # :tools lookup & :lang org +roam
      sqlite
      # :lang latex & :lang org (latex previews)
      texlive.combined.scheme-medium
    ];

    env.PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];

    # modules.shell.zsh.rcFiles = [ "${configDir}/emacs/aliases.zsh" ];

    fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];

    system.userActivationScripts = mkIf cfg.doom.enable {
      installDoomEmacs = ''
        [ -d "$XDG_CONFIG_HOME/emacs" ] ||
           git clone --depth=1 --single-branch "${cfg.doom.repoUrl}" "$XDG_CONFIG_HOME/emacs"

        [ -d "$XDG_CONFIG_HOME/doom" ] ||
           git clone "${cfg.doom.configRepoUrl}" "$XDG_CONFIG_HOME/doom"
      '';
    };
  };

}
# Acknowledgements
# - https://github.com/hlissner/dotfiles/blob/089f1a9da9018df9e5fc200c2d7bef70f4546026/modules/editors/emacs.nix
