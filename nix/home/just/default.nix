{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    home.packages = [pkgs.just];

    home.shellAliases = {
      j = "just";
      J = "just --justfile '${config.home.homeDirectory}/.dotfiles/justfile'";
    };

    programs.zsh.initContent = lib.mkBefore ''
      compdef _just j
      compdef _just J
    '';

    programs.bash.initExtra = ''
      complete -F _just -o bashdefault -o default j
      complete -F _just -o bashdefault -o default J
    '';
  };
}
