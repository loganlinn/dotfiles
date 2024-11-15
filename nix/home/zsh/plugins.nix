{
  config,
  pkgs,
  lib ? pkgs.lib,
  ...
}:

[
  {
    name = "forgit";
    src = pkgs.fetchFromGitHub {
      owner = "wfxr";
      repo = "forgit";
      rev = "9bb53dc455d09096cca066627adbf41eb7766f28";
      hash = "sha256-fhRQuyheNqdu/YHOffmaa+J9il2kmwyM7QKXRXmbPrQ=";
    };
  }
  {
    name = "fzf-tab";
    src = pkgs.fetchFromGitHub {
      owner = "Aloxaf";
      repo = "fzf-tab";
      rev = "5a81e13792a1eed4a03d2083771ee6e5b616b9ab";
      hash = "sha256-dPe5CLCAuuuLGRdRCt/nNruxMrP9f/oddRxERkgm1FE=";
    };
  }
  {
    name = "colored-man-pages";
    src = ./plugins/colored-man-pages;
  }
]
++ lib.optional config.programs.starship.enable or false {
  name = "spaceship-vi-mode";
  src = pkgs.fetchFromGitHub {
    owner = "spaceship-prompt";
    repo = "spaceship-vi-mode";
    rev = "31a5ac45eb9dcb84b968e1515e8a0074dbc4d1a8";
    hash = "sha256-NZCfgpLKUsvFLFQnrQdGDaEVwvD5TM14QtbQnkmClXU=";
  };
}
