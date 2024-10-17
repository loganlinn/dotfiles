{ pkgs, lib, ... }:
{
  homebrew = {
    brews = [
      "nss" # used by mkcert
      "terminal-notifier"
    ];

    casks = [
      "obs"
      "tailscale"
      "1password-cli"
    ];
  };
}
