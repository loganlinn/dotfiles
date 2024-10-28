{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = {
    home.packages = [ pkgs.just ];

    home.shellAliases = {
      j = "just";
      J = "just --global-justfile"; # use ~/justfile
    };

    home.activation.checkGlobalJustfile = hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -f "$HOME/justfile" ]; then
        run touch "$HOME/justfile"
      fi
    '';

    programs.zsh.initExtra = ''
      compdef _just j
      compdef _just J
    '';

    programs.bash.initExtra = ''
      complete -F _just -o bashdefault -o default j
      complete -F _just -o bashdefault -o default J
    '';
  };
}
