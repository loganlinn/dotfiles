{
  conf,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  gitBin = "${pkgs.git}/bin/git";
  homeManagerBin = "${pkgs.home-manager}/bin/home-manager";
in {
  home.sessionVariables = {
    DOCKER_SCAN_SUGGEST = "false";
    NEXT_TELEMETRY_DISABLED = "1";
    HOMEBREW_NO_ANALYTICS = "1";
  };

  home.shellAliases = {
    "'..'" = "cd ..";
    "'...'" = "cd ...";

    "'?'" = "which";
    "'??'" = "which -a";

    l = "ls -lah";
    mkd = "mkdir -p";

    gc = "${gitBin} commit -v";
    gca = "${gitBin} commit -v -a";
    gco = "${gitBin} switch";
    gcm = "${gitBin} switch \"$(${gitBin} default-branch || echo .)\"";
    gcob = "${gitBin} switch -c";
    gcop = "${gitBin} checkout -p";
    gd = "${gitBin} diff --color";
    gdc = "${gitBin} diff --color --cached";
    gfo = "${gitBin} fetch origin";
    gl = "${gitBin} pull";
    glr = "${gitBin} pull --rebase";
    glrp = "glr && gp";
    gp = "${gitBin} push -u";
    gpa = "${gitBin} push all --all";
    gs = "${gitBin} status -sb";
    gsrt = "${gitBin} rev-parse --show-toplevel";
    gsw = "${gitBin} stash show --patch";
    gw = "${gitBin} show";
    grt = ''cd -- "$(${gitBin} rev-parse --show-top-level || echo .)"'';

    nix-gc = "${pkgs.nix}/bin/nix-collect-garbage -d";
    nixq = "${pkgs.nix}/bin/nix-env -qaP";
    hm = "${homeManagerBin}";

    switch =
      if pkgs.stdenv.isDarwin
      then "darwin-rebuild switch --impure --flake ~/.dotfiles#\${USER?}@\${HOST?}"
      else "${homeManagerBin} switch --flake ~/.dotfiles#\${USER?}@\${HOST?}";

    k = "${pkgs.kubectl}/bin/kubectl";
    kctx = "${pkgs.kubectx}/bin/kubectx";
    kusers = "k config get-users";
    kdesc = "k describe";
    kdoc = "k describe";
    kinfo = "k cluster-info";
    kcfg = "k config view --raw";
    kk = "${pkgs.kustomize}/bin/kustomize";
    kkb = "kk build";

    s = "${pkgs.kitty}/bin/kitty +kitten ssh";

    bbr = "${pkgs.rlwrap}/bin/rlwrap bb";
  };
}
