{pkgs, ...}: {
  home.packages = with pkgs; [
    crystal
    icr # crystal repl
    shards # package-manager
  ];
}
