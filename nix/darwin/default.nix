{ ... }:

{
  imports = [
    ./system.nix
    ./security.nix
    ./configuration.nix
    ./homebrew.nix
  ];

  environment.darwinConfig = "$HOME/.dotfiles/nix/darwin";
}
