{ inputs, pkgs, lib, ...  }:

with lib;

{
  environment.systemPackages = with pkgs; [
    wslu # programs: wslclip wslsys wslupath wslact wslvar wslusc wslgsu wslfetch wslview
  ];

}