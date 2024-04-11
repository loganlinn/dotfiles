{ inputs, pkgs, lib, config, ...  }:

with lib;

{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl.enable = true;
  wsl.defaultUser = config.my.user.name;

  environment.systemPackages = with pkgs; [
    wslu # programs: wslclip wslsys wslupath wslact wslvar wslusc wslgsu wslfetch wslview
  ];
}