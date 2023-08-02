{ config, lib, pkgs, ... }:

{
  programs.kakoune = {
    config.numberLines.relative = true;
    plugins = with pkgs.kakounePlugins; [
      auto-pairs-kak
      connect-kak
      fzf-kak
      kak-lsp
      kak-ansi
      kakoune-rainbow
      prelude-kak
      rep
    ];
  };
}
